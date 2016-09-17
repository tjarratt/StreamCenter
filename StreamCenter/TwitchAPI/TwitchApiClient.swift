import Foundation
import Alamofire

struct TwitchApiClient : TwitchApi {
    func getStreamsForChannel(_ channel : String,
                       completionHandler: @escaping StreamVideoCompletionHandler) {
        let accessUrlString = String(format: "https://api.twitch.tv/api/channels/%@/access_token", channel)

        Alamofire.request(accessUrlString,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in

                if response.result.isSuccess {
                    if let accessInfoDict = response.result.value as? [String : AnyObject] {
                        if let sig = accessInfoDict["sig"] as? String {
                            if let token = accessInfoDict["token"] as? String {
                                let playlistUrlString  = String(format : "http://usher.twitch.tv/api/channel/hls/%@.m3u8", channel)

                                let parameters = ["player"            : "twitchweb",
                                                  "allow_audio_only"  : "true",
                                                  "allow_source"      : "true",
                                                  "type"              : "any",
                                                  "p"                 : Int(arc4random_uniform(99999)),
                                                  "token"             : token,
                                                  "sig"               : sig] as [String : Any]
                                Alamofire.request(playlistUrlString,
                                                  parameters : parameters,
                                                  headers: self.headers()).responseString { response in
                                        if response.result.isSuccess {
                                            guard let _ = response.result.value else {
                                                Logger.Error("Response had no value")
                                                completionHandler(nil, .dataError)
                                                return
                                            }
                                            if let streams = M3UParser.parseToDict(response.result.value!) {
                                                Logger.Debug("Returned \(streams.count) results")
                                                completionHandler(streams, nil)
                                                return
                                            }
                                            else {
                                                //Error parsing the .m3u8
                                                Logger.Error("Could not parse the .m3u8 file")
                                                completionHandler(nil, .otherError("Parser error"))
                                                return
                                            }

                                        }
                                        else {
                                            //Error retrieving the .m3u8
                                            Logger.Error("Could not get the .m3u8 file")
                                            completionHandler(nil, .urlError)
                                            return
                                        }
                                }
                                return
                            }
                        }
                    }
                    //Error with the access token json response
                    Logger.Error("Could not parse the access token response as JSON")
                    completionHandler(nil, .jsonError)
                    return

                }
                else {
                    //Error with access token request
                    Logger.Error("Could not request the access token")
                    completionHandler(nil, .urlError)
                    return

                }
        }

    }

    ///This is a method to retrieve the most popular Twitch games
    ///
    /// - parameters:
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    func getTopGamesWithOffset(_ offset : Int, limit : Int, completionHandler: @escaping TwitchGameCompletionHandler) {
        //First we build the url according to the game we desire to get infos
        let gamesUrlString = "https://api.twitch.tv/kraken/games/top"
        let parameters: [String: AnyObject] = ["limit"   : limit as AnyObject,
                                               "offset"  : offset as AnyObject]

        Alamofire.request(gamesUrlString,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in
                if response.result.isSuccess {
                    if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                        if let gamesDicts = gamesInfoDict["top"] as? [[String : AnyObject]] {
                            var games = [TwitchGame]()
                            for gameRaw in gamesDicts {
                                if let game = TwitchGame(dict: gameRaw) {
                                    games.append(game)
                                }
                            }
                            Logger.Debug("Returned \(games.count) results")
                            completionHandler(games, nil)
                            return
                        }
                    }
                    Logger.Error("Could not parse response as JSON")
                    completionHandler(nil, .jsonError)
                    return
                }
                else {
                    Logger.Error("Could not request top games")
                    completionHandler(nil, .urlError)
                    return
                }
        }
    }

    ///This is a method to retrieve the most popular Twitch streams for a given game
    ///
    /// - parameters:
    ///     - game: The game that we are attempting to get the streams for
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of streams to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    func getTopStreamsForGameWithOffset(_ game : String, offset : Int, limit : Int, completionHandler: @escaping TwitchStreamCompletionHandler) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams"
        let parameters: [String: AnyObject] = ["limit"      : limit as AnyObject,
                                               "offset"     : offset as AnyObject,
                                               "game"       : game as AnyObject,
                                               "stream_type": "live" as AnyObject]

        Alamofire.request(streamsUrlString,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in
                if response.result.isSuccess {
                    if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                        if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                            var streams = [TwitchStream]()
                            for streamRaw in streamsDicts {
                                if let channelDict = streamRaw["channel"] as? [String : AnyObject] {
                                    if let channel = TwitchChannel(dict: channelDict), let stream = TwitchStream(dict: streamRaw, channel: channel) {
                                        streams.append(stream)
                                    }
                                }
                            }
                            Logger.Debug("Returned \(streams.count) results")
                            completionHandler(streams, nil)
                            return
                        }
                    }
                    Logger.Error("Could not parse response as JSON")
                    completionHandler(nil, .jsonError)
                    return
                }
                else {
                    Logger.Error("Could not request top streams")
                    completionHandler(nil, .urlError)
                    return
                }
        }
    }

    ///This is a method to retrieve Twitch games based on a search term
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    func getGamesWithSearchTerm(_ term: String, offset : Int, limit : Int, completionHandler: @escaping TwitchGameCompletionHandler) {
        //First we build the url according to the game we desire to get infos
        let searchUrlString = "https://api.twitch.tv/kraken/search/games"
        let parameters: [String: AnyObject] = ["query"     : term as AnyObject,
                                               "type"      : "suggest" as AnyObject,
                                               "live"      : true as AnyObject]

        Alamofire.request(searchUrlString,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in
                if response.result.isSuccess {
                    if let gamesInfoDict = response.result.value as? [String : AnyObject] {
                        if let gamesDicts = gamesInfoDict["games"] as? [[String : AnyObject]] {
                            var games = [TwitchGame]()
                            for gameDict in gamesDicts {
                                if let game = TwitchGame(dict: gameDict) {
                                    games.append(game)
                                }
                            }
                            Logger.Debug("Returned \(games.count) results")
                            completionHandler(games, nil)
                            return
                        }
                    }
                    Logger.Error("Could not parse response as JSON")
                    completionHandler(nil, .jsonError)
                    return
                }
                else {
                    Logger.Error("Could not request games with search term")
                    completionHandler(nil, .urlError)
                    return
                }
        }
    }

    ///This is a method to retrieve Twitch streams based on a search term
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of streams to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    func getStreamsWithSearchTerm(_ term : String, offset : Int, limit : Int, completionHandler: @escaping TwitchStreamCompletionHandler) {
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/search/streams"
        let parameters: [String: AnyObject] = ["limit"     : limit as AnyObject,
                                               "offset"    : offset as AnyObject,
                                               "query"     : term as AnyObject]

        Alamofire.request(streamsUrlString,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in
            if response.result.isSuccess {
                if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                    if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                        var streams = [TwitchStream]()
                        for streamDict in streamsDicts {
                            if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                if let channel = TwitchChannel(dict: channelDict), let stream = TwitchStream(dict: streamDict, channel: channel) {
                                    streams.append(stream)
                                }
                            }
                        }
                        Logger.Debug("Returned \(streams.count) results")
                        completionHandler(streams, nil)
                        return
                    }
                }
                Logger.Error("Could not parse response as JSON")
                completionHandler(nil, .jsonError)
                return
            }
            else {
                Logger.Error("Could not request streams with search term")
                completionHandler(nil, .urlError)
                return
            }
        }
    }

    ///This is a method to retrieve Twitch streams that a user is following
    ///
    /// - parameters:
    ///     - term: A search term
    ///     - offset: An integer offset to load content after the primary results (useful when you reach the end of a scrolling list)
    ///     - limit: The number of games to return
    ///     - completionHandler: A closure providing results and an error (both optionals) to be executed once the request completes
    func getStreamsThatUserIsFollowing(_ offset : Int, limit : Int, completionHandler: @escaping TwitchStreamCompletionHandler) {

        guard let token = TokenHelper.getTwitchToken() else {
            completionHandler(nil, .authError)
            return
        }
        //First we build the url according to the game we desire to get infos
        let streamsUrlString = "https://api.twitch.tv/kraken/streams/followed"
        let parameters: [String: AnyObject] = ["limit"         : limit as AnyObject,
                                               "offset"        : offset as AnyObject,
                                               "oauth_token"   : token as AnyObject]

        Alamofire.request(streamsUrlString,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers()).responseJSON { response in
            if response.result.isSuccess {
                if let streamsInfoDict = response.result.value as? [String : AnyObject] {
                    if let streamsDicts = streamsInfoDict["streams"] as? [[String : AnyObject]] {
                        var streams = [TwitchStream]()
                        for streamDict in streamsDicts {
                            if let channelDict = streamDict["channel"] as? [String : AnyObject] {
                                if let channel = TwitchChannel(dict: channelDict), let stream = TwitchStream(dict: streamDict, channel: channel) {
                                    streams.append(stream)
                                }
                            }
                        }
                        Logger.Debug("Returned \(streams.count) results")
                        completionHandler(streams, nil)
                        return
                    }
                }
                Logger.Error("Could not parse response as JSON")
                completionHandler(nil, .jsonError)
                return
            }
            else {
                Logger.Error("Could not request followed streams by user")
                completionHandler(nil, .urlError)
                return
            }
        }
    }

    func getEmoteUrlStringFromId(_ id : String) -> String {
        return  "http://static-cdn.jtvnw.net/emoticons/v1/\(id)/1.0"
    }

    fileprivate func headers() -> [String: String] {
        let dictionary = Bundle.main.infoDictionary
        let rawClientId = dictionary!["SECRET_CLIENT_ID"] as! String
        let clientId = rawClientId.replacingOccurrences(of: "\\", with: "")

        return ["Client-ID": clientId]
    }
}
