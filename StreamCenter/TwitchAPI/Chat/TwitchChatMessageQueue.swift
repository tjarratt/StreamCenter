//
//  TwitchChatMessageQueue.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-20.

import Alamofire
import UIKit
import Foundation

protocol TwitchChatMessageQueueDelegate {
    func handleProcessedAttributedString(_ message: NSAttributedString)
    func handleNewEmoteDownloaded(_ id: String, data : Data)
    func hasEmoteInCache(_ id: String) -> Bool
    func getEmoteDataFromCache(_ id: String) -> Data?
}

class TwitchChatMessageQueue {
    let opQueue : DispatchQueue
    var processTimer : DispatchSourceTimer?
    var timerPaused : Bool = true
    let delegate : TwitchChatMessageQueueDelegate
    let messageQueue : Queue<IRCMessage>
    let mqMutex : DispatchSemaphore

    fileprivate var twitchAPIClient : TwitchApi = TwitchApiClient.init() // FIXME: should be injected
    
    init(delegate : TwitchChatMessageQueueDelegate) {
        self.mqMutex = DispatchSemaphore(value: 1)
        self.opQueue = DispatchQueue(label: "com.twitch.chatmq",
                                     qos: .background,
                                     attributes: [.concurrent])
        self.delegate = delegate
        self.messageQueue = Queue<IRCMessage>()
    }
    
    func addNewMessage(_ message : IRCMessage) {
        // For the data integrity - multiple threads can be accessing at the same time
        _ = self.mqMutex.wait(timeout: DispatchTime.distantFuture)

        messageQueue.offer(message)
        self.mqMutex.signal()
        
        if self.processTimer == nil || self.timerPaused {
            self.startProcessing()
        }
    }
    
    func processAvailableMessages() {
        var messagesArray = [IRCMessage]()
        // For data integrity - We do not want any thread adding messages as
        // we are polling from the queue
        _ = self.mqMutex.wait(timeout: DispatchTime.distantFuture)
        while(true){
            if let message = self.messageQueue.poll() {
                messagesArray.append(message)
            }
            else {
                break
            }
        }
        self.mqMutex.signal()
        
        // We stop if there's not message to process, it will be reactivated when
        // we receive a new message
        if messagesArray.count == 0 {
            self.stopProcessing()
            return
        }
        
        for ircMessage : IRCMessage in messagesArray {
            if let twitchMessage = ircMessage.toTwitchChatMessage() {
                let downloadGroup = DispatchGroup()
                for emote in twitchMessage.emotes {
                    if !self.delegate.hasEmoteInCache(emote.0){
                        downloadGroup.enter()

                        let emoteURL = self.twitchAPIClient.getEmoteUrlStringFromId(emote.0)
                        let request : Alamofire.DataRequest = Alamofire.request(emoteURL)
                        request.response(completionHandler: { response in
                            if response.error != nil {
                                Logger.Error("Could not download emote image for id: \(emote.0)")
                            }
                            else {
                                self.delegate.handleNewEmoteDownloaded(emote.0, data: response.data!)
                            }
                            downloadGroup.leave()
                        })
                    }
                }
                
                _ = downloadGroup.wait(timeout: DispatchTime.distantFuture)
                let messageAttributedString = self.getAttributedStringForMessage(twitchMessage)
                delegate.handleProcessedAttributedString(messageAttributedString)
            }
        }
    }
    
    func startProcessing() {
        if self.processTimer == nil && self.timerPaused {
            Logger.Debug("Creating a new process timer")
            self.timerPaused = false
            self.processTimer = ConcurrencyHelpers.createDispatchTimer(queue: opQueue, block: {
                self.processAvailableMessages()
            })
            return
        }
        else if self.processTimer != nil && self.timerPaused {
            Logger.Debug("Resuming existing process timer")
            self.timerPaused = false
            self.processTimer!.resume()
            return
        }
        Logger.Error("Conditions not met, could not start processing")
    }
    
    func stopProcessing() {
        if processTimer != nil && !self.timerPaused {
            Logger.Debug("Suspending process timer")
            self.processTimer!.suspend()
            self.timerPaused = true
            return
        }
        Logger.Error("Could not stop processing since timer is either nil or already paused")
    }
    
    fileprivate func getAttributedStringForMessage(_ message : TwitchChatMessage) -> NSAttributedString {
        
        let attrMsg = NSMutableAttributedString(string: message.message)
        
        for (emoteID, emote) in message.emotes {
            let attachment = NSTextAttachment()
            guard let emoteData = self.delegate.getEmoteDataFromCache(emoteID) else {
                Logger.Warning("Could not find \(emoteID) in emote cache")
                continue
            }
            let emoteImage = UIImage(data: emoteData)
            attachment.image = emoteImage
            let emoteString = NSAttributedString(attachment: attachment)

            while true {
                let range = attrMsg.mutableString.range(of: emote)
                
                guard range.location != NSNotFound else {
                    break
                }
                
                attrMsg.replaceCharacters(in: range, with: emoteString)
            }
        }
        
        attrMsg.insert(NSAttributedString(string: "\(message.senderName): "), at: 0)
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#AAAAAA"), range: NSMakeRange(0, attrMsg.length))
        attrMsg.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: message.senderDisplayColor), range: NSMakeRange(0, message.senderName.characters.count))
        attrMsg.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, attrMsg.length))
        
        
        return attrMsg
    }
}
