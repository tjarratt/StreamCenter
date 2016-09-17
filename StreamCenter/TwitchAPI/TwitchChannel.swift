//
//  TwitchChannel.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import Foundation

struct TwitchChannel {
    let id : Int!
    let name : String!
    let displayName : String!
    let links : [String : String]!
    let broadcasterLanguage : String?
    let language : String!
    let gameName : String!
    let logo : String?
    let status : String!
    let videoBanner : String?
    let lastUpdate : Date!
    let followers : Int!
    let views : Int!
    
    init(id : Int, name : String, displayName : String, links : [String : String], broadcasterLanguage : String?,
        language : String, gameName : String, logo : String?, status : String, videoBanner : String?,
        lastUpdate : Date, followers : Int, views : Int) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.links = links
        self.broadcasterLanguage = broadcasterLanguage
        self.language = language
        self.gameName = gameName
        self.logo = logo
        self.status = status
        self.videoBanner = videoBanner
        self.lastUpdate = lastUpdate
        self.followers = followers
        self.views = views
    }
    
    init?(dict: [String : AnyObject]) {
        guard let id = dict["_id"] as? Int else {
            return nil
        }
        guard let name = dict["name"] as? String else {
            return nil
        }
        guard let displayName = dict["display_name"] as? String else {
            return nil
        }
        guard let links = dict["_links"] as? [String : String] else {
            return nil
        }
        guard let language = dict["language"] as? String else {
            return nil
        }
        guard let gameName = dict["game"] as? String else {
            return nil
        }
        guard let status = dict["status"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.displayName = displayName
        self.links = links
        self.language = language
        self.gameName = gameName
        self.status = status
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        if let updateDateString = dict["updated_at"] as? String, let updateDate = dateFormatter.date(from: updateDateString) {
            self.lastUpdate = updateDate
        }
        else {
            self.lastUpdate = Date()
        }
        
        if let followers = dict["followers"] as? Int {
            self.followers = followers
        }
        else {
            self.followers = 0
        }
        
        if let views = dict["views"] as? Int {
            self.views = views
        }
        else {
            self.views = 0
        }
        
        self.broadcasterLanguage = dict["broadcaster_language"] as? String
        self.videoBanner = dict["video_banner"] as? String
        self.logo = dict["logo"] as? String
    }
    
    var displayLanguage: String? {
        get {
            if let display = (Locale(identifier: language) as NSLocale).displayName(forKey: NSLocale.Key.languageCode, value: language) {
                return display.lowercased()
            }
            return nil
        }
    }
}
