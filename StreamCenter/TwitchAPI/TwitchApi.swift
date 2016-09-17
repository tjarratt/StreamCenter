import Foundation

typealias StreamVideoCompletionHandler = (_ streams: [TwitchStreamVideo]?, _ error: ServiceError?) -> ()
typealias TwitchGameCompletionHandler = (_ games: [TwitchGame]?, _ error: ServiceError?) -> ()
typealias TwitchStreamCompletionHandler = (_ streams: [TwitchStream]?, _ error: ServiceError?) -> ()

protocol TwitchApi {
    func getStreamsForChannel(_ channel : String,
                      completionHandler : @escaping StreamVideoCompletionHandler)

    func getTopGamesWithOffset(_ offset : Int,
                                  limit : Int,
                       completionHandler: @escaping TwitchGameCompletionHandler)

    func getTopStreamsForGameWithOffset(_ game : String,
                                        offset : Int,
                                         limit : Int,
                              completionHandler: @escaping TwitchStreamCompletionHandler)

    func getGamesWithSearchTerm(_ term : String,
                                offset : Int,
                                 limit : Int,
                      completionHandler: @escaping TwitchGameCompletionHandler)

    func getStreamsWithSearchTerm(_ term : String,
                                  offset : Int,
                                   limit : Int,
                        completionHandler: @escaping TwitchStreamCompletionHandler)

    func getStreamsThatUserIsFollowing(_ offset : Int,
                                          limit : Int,
                               completionHandler: @escaping TwitchStreamCompletionHandler)

    func getEmoteUrlStringFromId(_ id : String) -> String
}
