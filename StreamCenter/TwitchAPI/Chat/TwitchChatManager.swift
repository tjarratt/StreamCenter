//
//  TwitchChatManager.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-10-18.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import Foundation

class TwitchChatManager {
    
    static func generateAnonymousIRCCredentials() -> IRCCredentials {
        let rnd = Int(arc4random_uniform(99999))
        return IRCCredentials(username: nil, password: nil, nick: "justinfan\(rnd)")
    }
    
    fileprivate var connection : IRCConnection?
    fileprivate var credentials : IRCCredentials?
    fileprivate var capabilities = IRCCapabilities(capabilities: ["twitch.tv/tags"])
    fileprivate var messageQueue : TwitchChatMessageQueue?
    fileprivate var emotesDictionnary = [String : Data]() //Dictionnary that holds all the emotes (Acts as cache)
    fileprivate var consumer : ChatManagerConsumer?
    
    init(consumer : ChatManagerConsumer) {
        self.consumer = consumer
        self.messageQueue = TwitchChatMessageQueue(delegate: self)
        connection = IRCConnection(delegate: self)

        //Command handlers
        connection!.commandHandlers["PRIVMSG"] = handleMsg
        connection!.commandHandlers["433"] = handle433
    }
    
    func connectAnonymously() {
        credentials = TwitchChatManager.generateAnonymousIRCCredentials()
        connection!.connect(IRCEndpoint(host: "irc.twitch.tv", port: 6667), credentials: credentials!, capabilities: capabilities)
    }
    
    func disconnect() {
        connection?.disconnect()
    }
    
    func joinTwitchChannel(_ channel : TwitchChannel) {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.connection?.sendStringMessage("JOIN #\(channel.name!)", immediately: true)
        })
    }
    
/////////////////////////////////////////
// MARK - Command handlers
/////////////////////////////////////////
    
    fileprivate func handleMsg(_ message : IRCMessage) -> () {
        guard let _ = message.sender as String! else {
            return
        }
        
        guard message.parameters.count == 2 else {
            return
        }
        
        messageQueue?.addNewMessage(message)
    }
    
    fileprivate func handle433(_ message : IRCMessage) -> () {
        Logger.Warning("Received 433 from server, invalid nick")
        credentials = TwitchChatManager.generateAnonymousIRCCredentials()
        connection?.sendStringMessage("NICK \(credentials!.nick)", immediately: true)
    }
}

/////////////////////////////////////////
// MARK - TwitchChatMessageQueueDelegate
/////////////////////////////////////////

extension TwitchChatManager : TwitchChatMessageQueueDelegate {
    func handleProcessedAttributedString(_ message: NSAttributedString) {
        self.consumer!.messageReadyForDisplay(message)
    }
    func handleNewEmoteDownloaded(_ id: String, data : Data) {
        emotesDictionnary[id] = data
    }
    func hasEmoteInCache(_ id: String) -> Bool {
        return self.emotesDictionnary[id] != nil
    }
    func getEmoteDataFromCache(_ id: String) -> Data? {
        return self.emotesDictionnary[id]
    }
}

/////////////////////////////////////////
// MARK - IRCConnectionDelegate
/////////////////////////////////////////

extension TwitchChatManager : IRCConnectionDelegate {
    func IRCConnectionDidConnect() {
    }
    func IRCConnectionDidDisconnect() {
    }
    func IRCConnectionDidNotConnect() {
    }
}
