//
//  IRCConnection.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-17.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}



class IRCConnection {
    
    typealias CommandHandlerFunc = ((_ message : IRCMessage) -> ())
    
    enum ChatConnectionStatus {
        case disconnected
        case serverDisconnected
        case connecting
        case connected
        case suspended
    }
    
    //Constants
    fileprivate let PING_SERVER_INTERVAL : Double = 120
    fileprivate let QUEUE_WAIT_BEFORE_CONNECTED : Double = 120
    fileprivate let MAXIMUM_COMMAND_LENGTH : Int = 510
    fileprivate let END_CAPABILITY_TIMEOUT_DELAY : Double = 45
    
    //GCD
    fileprivate var chatConnection : GCDAsyncSocket?
    fileprivate var connectionQueue : DispatchQueue
    fileprivate let sendQueueLock : DispatchSemaphore
    
    //Send queue
    fileprivate var sendQueue : [Data]
    fileprivate var sendQueueProcessing : Bool = false
    fileprivate var queueWait : Date?
    
    //Connection state
    fileprivate var status : ChatConnectionStatus
    fileprivate var connectedDate : Date?
    fileprivate var lastConnectAttempt : Date?
    fileprivate var lastCommand : Date?
    fileprivate var lastError : Error?
    
    //Capability request state
    fileprivate var capabilities : IRCCapabilities?
    fileprivate var sendEndCapabilityCommandAtTime : Date?
    fileprivate var sentEndCapabilityCommand : Bool = false
    
    //Ping - keep alive
    fileprivate var nextPingTimeInterval : Date?
    
    //Credentials
    fileprivate var credentials : IRCCredentials?
    
    //Server state
    fileprivate var server : String?
    fileprivate var realServer : String?
    
    //Commands
    var commandHandlers = [String : CommandHandlerFunc]()
    
    //Delegate
    let delegate : IRCConnectionDelegate
    
////////////////////////////////////////
// MARK - Computed properties
////////////////////////////////////////
    
    fileprivate var recentlyConnected : Bool {
        get {
            guard let connectedDate = connectedDate as Date! else {
                return false
            }
            return Date.timeIntervalSinceReferenceDate - connectedDate.timeIntervalSinceReferenceDate > 10
        }
    }
    
    fileprivate var minimumSendQueueDelay : Double {
        get {
            return self.recentlyConnected ? 0.5 : 0.25
        }
    }
    
    fileprivate var maximumSendQueueDelay : Double {
        get {
            return self.recentlyConnected ? 1.5 : 0.3
        }
    }
    
    fileprivate var sendQueueDelayIncrement : Double {
        get {
            return self.recentlyConnected ? 0.25 : 0.15
        }
    }
    
////////////////////////////////////////
// MARK - Lifecycle
////////////////////////////////////////
    
    init (delegate : IRCConnectionDelegate) {
        connectionQueue = DispatchQueue(label: "com.irc.connection",
                                        qos: .background,
                                        attributes: [])
        status = .disconnected
        sendQueue = [Data]()
        sendQueueLock = DispatchSemaphore(value: 1)
        self.delegate = delegate
        
        commandHandlers["PING"] = handlePing
    }
    
////////////////////////////////////////
// MARK - Public methods
////////////////////////////////////////
    
    func connect(_ endpoint : IRCEndpoint, credentials : IRCCredentials, capabilities : IRCCapabilities) {
        if status != .disconnected &&
           status != .serverDisconnected &&
           status != .suspended {
            Logger.Warning("Current status does not allow connection")
            return
        }
        
        self.credentials = credentials
        self.capabilities = capabilities
        lastConnectAttempt = Date()
        queueWait = Date(timeIntervalSinceNow: QUEUE_WAIT_BEFORE_CONNECTED)

        connect(endpoint)
    }
    
    func disconnect() {
        status = .disconnected
        sendStringMessage("QUIT", immediately: true)
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.chatConnection!.disconnectAfterWriting()
            Logger.Debug("Disconnected")
        })
    }
////////////////////////////////////////
// MARK - Connection
////////////////////////////////////////
    
    fileprivate func connect(_ endpoint : IRCEndpoint) {
        chatConnection = GCDAsyncSocket(delegate: self, delegateQueue: connectionQueue, socketQueue: connectionQueue)
        chatConnection?.isIPv6Enabled = true
        chatConnection?.isIPv4PreferredOverIPv6 = true
        
        do {
            try chatConnection?.connect(toHost: endpoint.host, onPort: endpoint.port)
            resetSendQueueInterval()
        }
        catch _ {
            DispatchQueue.main.async(execute: {
                self.didNotConnect()
            })
        }
    }
    
    fileprivate func didConnect() {
        Logger.Debug("Connected")
        status = .connected
        connectedDate = Date()
        queueWait = Date(timeIntervalSinceNow: 0.5)
        resetSendQueueInterval()
        delegate.IRCConnectionDidConnect()
    }
    
    fileprivate func didNotConnect() {
        Logger.Error("Could not connect to host")
        delegate.IRCConnectionDidNotConnect()
    }
    
    fileprivate func didDisconnect() {
        Logger.Warning("Did disconnect from host")
        delegate.IRCConnectionDidDisconnect()
    }
    
////////////////////////////////////////
// MARK - Send Queue
////////////////////////////////////////
    
    fileprivate func resetSendQueueInterval() {
        self.stopSendQueue()
        _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
        if (self.sendQueue.count > 0){
            startSendQueue()
        }
        sendQueueLock.signal()
    }
    
    fileprivate func startSendQueue() {
        if sendQueueProcessing {
            Logger.Warning("Send queue is already processing")
            return
        }
        
        sendQueueProcessing = true

        let timeInterval = (queueWait != nil && queueWait!.timeIntervalSinceNow > 0) ? queueWait!.timeIntervalSinceNow : minimumSendQueueDelay
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            Logger.Debug("Starting to process send queue")
            self.treatSendQueue()
        })
    }
    
    fileprivate func stopSendQueue() {
        sendQueueProcessing = false
    }
    
    fileprivate func treatSendQueue() {
        _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
        if (self.sendQueue.count <= 0){
            Logger.Debug("Send queue is empty, stopping to process")
            sendQueueProcessing = false
            return
        }
        sendQueueLock.signal()
        
        if queueWait != nil && queueWait?.timeIntervalSinceNow > 0 {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(queueWait!.timeIntervalSinceNow * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.treatSendQueue()
            })
            return
        }
        
        _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
        let data = sendQueue.first
        sendQueue.removeFirst()
        sendQueueLock.signal()
        
        if sendQueue.count > 0 {
            let calculatedQueueDelay = (minimumSendQueueDelay + (Double(sendQueue.count) * sendQueueDelayIncrement))
            let delay = calculatedQueueDelay > maximumSendQueueDelay ? maximumSendQueueDelay : calculatedQueueDelay
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.treatSendQueue()
            })
        }
        else {
            Logger.Debug("Send queue is empty, stopping to process")
            sendQueueProcessing = false
        }
        
        connectionQueue.async(execute: {
            self.lastCommand = Date()
            self.writeDataToServer(data!)
        })
    }
    
////////////////////////////////////////
// MARK - Outgoing data
////////////////////////////////////////
    
    fileprivate func writeDataToServer(_ data : Data) {
        // IRC messages are always lines of characters terminated with a CR-LF
        // (Carriage Return - Line Feed) pair, and these messages SHALL NOT
        // exceed 512 characters in length, counting all characters including
        // the trailing CR-LF. Thus, there are 510 characters maximum allowed
        // for the command and its parameters.
        var vdata = Data()
        
        if data.count > MAXIMUM_COMMAND_LENGTH {
            let range = Range(uncheckedBounds: (lower: 0, upper: MAXIMUM_COMMAND_LENGTH))
            let subdata = data.subdata(in: range)
            vdata = subdata
        } else {
            vdata = data
        }

        if vdata.hasSuffix(bytes: [0x0D]) {
            vdata.append(contentsOf: [0x0A])
        }
        else if !vdata.hasSuffix(bytes: [0x0D, 0x0A]){
            if vdata.hasSuffix(bytes: [0x0A]){
                let range = Range(uncheckedBounds: (vdata.count - 1, vdata.count))
                vdata.replaceSubrange(range, with: [0x0D, 0x0A])
            }
            else {
                vdata.append(contentsOf: [0x0D, 0x0A])
            }
        }
        
        chatConnection!.write(vdata, withTimeout: -1, tag: 0)
        
        Logger.Info("Wrote: \(String(data: vdata, encoding: String.Encoding.utf8)!)")
    }
    
    func sendStringMessage(_ message : String, immediately now : Bool) {
        sendRawMessage(message.data(using: String.Encoding.utf8)!, immediately: now)
    }
    
    fileprivate func sendRawMessage(_ raw : Data, immediately now : Bool) {
        Logger.Info("Queueing: \(String(data: raw, encoding: String.Encoding.utf8)!)")
        
        var nnow = now
        if !nnow {
            _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
            nnow = sendQueue.count == 0
            sendQueueLock.signal()
        }
        
        if nnow {
            nnow = queueWait == nil || queueWait!.timeIntervalSinceNow <= 0
        }
        
        if nnow {
            nnow = lastCommand == nil || lastCommand?.timeIntervalSinceNow <= (-minimumSendQueueDelay)
        }
        
        if nnow {
            connectionQueue.async(execute: {
                self.lastCommand = Date()
                self.writeDataToServer(raw)
            })
        }
        else {
            _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
            sendQueue.append(raw)
            sendQueueLock.signal()
            
            if !sendQueueProcessing {
                DispatchQueue.main.async(execute: {
                    self.startSendQueue()
                })
            }
        }
    }

////////////////////////////////////////
// MARK - Capability requests
////////////////////////////////////////

    fileprivate func cancelScheduledSendEndCapabilityCommand() {
        sendEndCapabilityCommandAtTime = nil
    }
    
    fileprivate func sendEndCapabilityCommandAfterTimeout() {
        cancelScheduledSendEndCapabilityCommand()
        
        sendEndCapabilityCommandAtTime = Date(timeIntervalSinceNow: END_CAPABILITY_TIMEOUT_DELAY)
        
        connectionQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64((UInt64(END_CAPABILITY_TIMEOUT_DELAY) * NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.sendEndCapabilityCommand(forcefully: false)
        })
        
    }
    
    fileprivate func sendEndCapabilityCommandSoon() {
        cancelScheduledSendEndCapabilityCommand()
        
        sendEndCapabilityCommandAtTime = Date(timeIntervalSinceNow: 1)
        
        connectionQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64((UInt64(END_CAPABILITY_TIMEOUT_DELAY) * NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.sendEndCapabilityCommand(forcefully: false)
        })
    }
    
    fileprivate func sendEndCapabilityCommand(forcefully force : Bool) {
        if sentEndCapabilityCommand { return }
        
        if !force && sendEndCapabilityCommandAtTime == nil { return }
        
        sentEndCapabilityCommand = true
        
        sendStringMessage("CAP END", immediately: true)
    }
    
////////////////////////////////////////
// MARK - Pinging
////////////////////////////////////////

    fileprivate func pingServer() {
        let server = realServer == nil ? self.server : realServer
        sendStringMessage("PING \(server)", immediately: true)
    }
    
    fileprivate func pingServerAfterInterval() {
        if status != .connecting &&
           status != .connected {
            Logger.Warning("Could not ping since we're not connected")
            return
        }
        
        nextPingTimeInterval = Date(timeIntervalSinceNow: PING_SERVER_INTERVAL)
        let delayInSeconds = UInt64(PING_SERVER_INTERVAL + 1)
        
        let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        
        connectionQueue.asyncAfter(deadline: popTime, execute: {
            let nowTimeInterval = Date.timeIntervalSinceReferenceDate
            
            if self.nextPingTimeInterval!.timeIntervalSinceReferenceDate < nowTimeInterval {
                self.nextPingTimeInterval = Date(timeIntervalSinceNow: self.PING_SERVER_INTERVAL)
                self.pingServer()
            }
        })
    }
    
////////////////////////////////////////
// MARK - Incoming data
////////////////////////////////////////

    fileprivate func readNextMessageFromServer() {
        // IRC messages end in \x0D\x0A, but some non-compliant servers only use \x0A during the connecting phase
        chatConnection?.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
    }
    
    fileprivate func processIncomingMessage(_ data : Data, fromServer : Bool) {

        if var messageString = String(data: data, encoding: String.Encoding.utf8) {
            var currentIndex = 0
            let len = messageString.characters.count
            var sender : String?
            var user : String?
            var host : String?
            var command : String?
            var intentOrTags : String?
            var parameters = [String]()
            
            var done : Bool = false
            
            func checkAndMarkIfDone() { if currentIndex == len - 1 { done = true } }
            func consumeWhitespace() { while(messageString[currentIndex] == " " && currentIndex != len - 1 && !done) { currentIndex += 1 } }
            func notEndOfLine() -> Bool { return currentIndex != len - 1 && !done }
            
            if len > 2 {
                if notEndOfLine() {
                    if messageString[currentIndex] == "@" {
                        currentIndex += 1
                        let startIndex = currentIndex
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex += 1 }
                        let endIndex = currentIndex
                        let length = endIndex - 1 - startIndex
                        intentOrTags = messageString.substring(startIndex, length: length)

                        checkAndMarkIfDone()
                        consumeWhitespace()
                    }
                }
                
                if notEndOfLine() && messageString[currentIndex] == ":" {
                    // prefix: ':' <sender> [ '!' <user> ] [ '@' <host> ] ' ' { ' ' }
                    currentIndex += 1
                    let senderStartIndex = currentIndex
                    while notEndOfLine() &&
                        messageString[currentIndex] != " " &&
                        messageString[currentIndex] != "!" &&
                        messageString[currentIndex] != "@"
                        { currentIndex += 1 }
                    let senderEndIndex = currentIndex
                    let length = senderEndIndex - 1 - senderStartIndex
                    sender = messageString.substring(senderStartIndex, length: length)

                    checkAndMarkIfDone()
                    
                    if !done && messageString[currentIndex] != "!" {
                        currentIndex += 1
                        let userStartIndex = currentIndex
                        while notEndOfLine() &&
                            messageString[currentIndex] != " " &&
                            messageString[currentIndex] != "@"
                            { currentIndex += 1 }
                        let userEndIndex = currentIndex
                        let length = userEndIndex - 1 - userStartIndex
                        user = messageString.substring(userStartIndex, length: length)

                        checkAndMarkIfDone()
                    }
                    
                    if !done && messageString[currentIndex] != "@" {
                        currentIndex += 1
                        let hostStartIndex = currentIndex
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex += 1 }
                        let hostEndIndex = currentIndex
                        let length = hostEndIndex - 1 - hostStartIndex
                        host = messageString.substring(hostStartIndex, length: length)
                        checkAndMarkIfDone()
                    }
                    
                    if !done { currentIndex += 1 }
                    consumeWhitespace()
                }
                
                if notEndOfLine() {
                    // command: <letter> { <letter> } | <number> <number> <number>
                    // letter: 'a' ... 'z' | 'A' ... 'Z'
                    // number: '0' ... '9'
                    let cmdStartIndex = currentIndex
                    while notEndOfLine() && messageString[currentIndex] != " " { currentIndex += 1 }

                    let cmdEndIndex = currentIndex
                    let length = cmdEndIndex - 1 - cmdStartIndex
                    command = messageString.substring(cmdStartIndex, length: length)
                    
                    checkAndMarkIfDone()
                    if !done { currentIndex += 1 }
                    consumeWhitespace()
                }
                
                while notEndOfLine() {
                    // params: [ ':' <trailing data> | <letter> { <letter> } ] [ ' ' { ' ' } ] [ <params> ]
                    var currentParameter : String?
                    
                    if messageString[currentIndex] == ":" {
                        currentIndex += 1
                        let currentParamStartIndex = currentIndex
                        let length = len - 1 - currentParamStartIndex
                        
                        currentParameter = messageString.substring(currentParamStartIndex,
                                                                   length: length)
                        currentIndex = len - 1
                    }
                    else {
                        let currentParamStartIndex = currentIndex
                        while notEndOfLine() && messageString[currentIndex] != " " { currentIndex += 1 }
                        let currentParamEndIndex = currentIndex
                        let subStringLength = currentParamEndIndex - 1 - currentParamStartIndex
                        currentParameter = messageString.substring(currentParamStartIndex,
                                                                   length: subStringLength)
                        
                        checkAndMarkIfDone()
                        if !done { currentIndex += 1 }
                    }
                    
                    if let param = currentParameter as String! {
                        parameters.append(param.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                    }
                    
                    consumeWhitespace()
                }
            }
            
            var intentOrTagDict = [String : String]()
            
            if let intentOrTags = intentOrTags as String! {
                for anItentOrTag in intentOrTags.components(separatedBy: ";") {
                    let intentOrTagPair = anItentOrTag.components(separatedBy: "=")
                    
                    if intentOrTagPair.count != 2 { continue }
                    
                    intentOrTagDict[intentOrTagPair[0]] = intentOrTagPair[1]
                }
            }
            
            if let handler = commandHandlers[command!] {
                let msg = IRCMessage(sender: sender, user: user, host: host, command: command, intentOrTags: intentOrTagDict, parameters: parameters)
                handler(msg)
            }
            else {
                Logger.Warning("No handler found for command: \(command!)")
            }
            
            pingServerAfterInterval()
        }
        else {
            //Could not convert data to utf8 string
            Logger.Error("Could not convert data to UTF8 String")
        }
    }
    
    fileprivate func handlePing(_ message : IRCMessage) -> () {
        //parameters[0] is the PONG response
        sendStringMessage("PONG \(message.parameters[0])", immediately: true)
    }
}

////////////////////////////////////////
// MARK - GCDAsyncSocketDelegate protocol
////////////////////////////////////////

extension IRCConnection : GCDAsyncSocketDelegate {
    @objc
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        if credentials?.password?.characters.count > 0 {
            sendStringMessage("PASS \(credentials!.password!)", immediately: true)
        }
        
        sendStringMessage("NICK \(credentials!.nick)", immediately: true)
        //TODO(Olivier): In with twitch we don't deal with the USER ... command. Implement it if necessary
        //[self sendRawMessageImmediatelyWithFormat:@"USER %@ 0 * :%@", username, ( _realName.length ? _realName : @"Anonymous User" )];
        
        sendEndCapabilityCommandAfterTimeout()
        
        let capabilitiesCommand = capabilities!.getIRCCommandString()
        if let cmd = capabilitiesCommand as String! {
            sendStringMessage(cmd, immediately: true)
        }
        
        DispatchQueue.main.async(execute: {
            self.didConnect()
        })

        pingServerAfterInterval()

        readNextMessageFromServer()
    }
    
    @objc
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        processIncomingMessage(data, fromServer: true)
        readNextMessageFromServer()
    }
    
    @objc
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        if sock != chatConnection { return }
        
        lastError = err
        
        DispatchQueue.main.async(execute: {
            self.stopSendQueue()
        })
        
        _ = sendQueueLock.wait(timeout: DispatchTime.distantFuture)
        self.sendQueue.removeAll()
        sendQueueLock.signal()
        
        if status == .connecting {
            if lastError == nil {
                DispatchQueue.main.async(execute: {
                    self.didNotConnect()
                })
            }
        }
        else {
            if lastError != nil && status != .disconnected {
                status = .disconnected
                DispatchQueue.main.async(execute: {
                    self.didDisconnect()
                })
            }
        }
    }
}
