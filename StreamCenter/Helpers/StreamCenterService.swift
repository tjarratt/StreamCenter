//
//  StreamCenterService.swift
//  GamingStreamsTVApp
//
//  Created by Brendan Kirchner on 10/15/15.
//  Copyright © 2015 Rivus Media Inc. All rights reserved.
//

import UIKit
import Alamofire

enum ServiceError: Error {
    case urlError
    case jsonError
    case dataError
    case authError
    case noAuthTokenError
    case otherError(String)
    
    var errorDescription: String {
        get {
            switch self {
            case .urlError:
                return "There was an error with the request."
            case .jsonError:
                return "There was an error parsing the JSON."
            case .dataError:
                return "The response contained bad data"
            case .authError:
                return "The user is not authenticated."
            case .noAuthTokenError:
                return "There was no auth token provided in the response data."
            case .otherError(let message):
                return message
            }
        }
    }
    
    //only use this top log, do not present this to the user
    var developerSuggestion: String {
        get {
            switch self {
            case .urlError:
                return "Please make sure that the url is formatted correctly."
            case .jsonError, .dataError:
                return "Please check the request information and response."
            case .authError:
                return "Please make sure to authenticate with Twitch before attempting to load this data."
            case .noAuthTokenError:
                return "Please check the server logs and response."
            case .otherError: //change to case .OtherError(let message):if you want to be able to utilize an error message
                return "Sorry, there's no provided solution for this error."
            }
        }
    }
}

class StreamCenterService {
    
    static func authenticateTwitch(withCode code: String, andUUID UUID: String, completionHandler: @escaping (_ token: String?, _ error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/oauth/twitch/\(UUID)/\(code)"
        Alamofire.request(urlString)
            .responseJSON { response in
                
                if response.result.isSuccess {
                    if let dictionary = response.result.value as? [String : AnyObject] {
                        guard let token = dictionary["access_token"] as? String, let _ = dictionary["generated_date"] as? String else {
                            Logger.Error("Could not retrieve desired information from response:\naccess_token\ngenerated_date")
                            completionHandler(nil, .noAuthTokenError)
                            return
                        }
                        //NOTE: date is formatted: '2015-10-13 20:35:12'
                        
                        Logger.Debug("User sucessfully retrieved Oauth token")
                        completionHandler(token, nil)
                    }
                    else {
                        Logger.Error("Could not parse response as JSON")
                        completionHandler(nil, .jsonError)
                    }
                } else {
                    Logger.Error("Could not request Twitch Oauth service")
                    completionHandler(nil, .urlError)
                    return
                }
                
        }
    }
    
    static func getCustomURL(fromCode code: String, completionHandler: @escaping (_ url: String?, _ error: ServiceError?) -> ()) {
        let urlString = "http://streamcenterapp.com/customurl/\(code)"

        Alamofire.request(urlString).responseJSON { response in
            //here's a test url
//            completionHandler(url: "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8", error: nil)
//            return
            
            if response.result.isSuccess {
                if let dictionary = response.result.value as? [String : AnyObject] {
                    if let urlString = dictionary["url"] as? String {
                        Logger.Debug("Returned: \(urlString)")
                        completionHandler(urlString, nil)
                        return
                    }
                    if let errorMessage = dictionary["message"] as? String {
                        Logger.Error("Custom url service returned an error:\n\(errorMessage)")
                        completionHandler(nil, .otherError(errorMessage))
                        return
                    }
                }
                Logger.Error("Could not parse response as JSON")
                completionHandler(nil, .jsonError)
            } else {
                Logger.Error("Could not request the custom url service")
                completionHandler(nil, .urlError)
            }
        }
    }
    
}
