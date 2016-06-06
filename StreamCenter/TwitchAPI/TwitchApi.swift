import Foundation

protocol TwitchApi {
    func getStreamsForChannel(channel : String, completionHandler: (streams: [TwitchStreamVideo]?, error: ServiceError?) -> ())
    func getTopGamesWithOffset(offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: ServiceError?) -> ())
    func getTopStreamsForGameWithOffset(game : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ())
    func getGamesWithSearchTerm(term: String, offset : Int, limit : Int, completionHandler: (games: [TwitchGame]?, error: ServiceError?) -> ())
    func getStreamsWithSearchTerm(term : String, offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ())
    func getStreamsThatUserIsFollowing(offset : Int, limit : Int, completionHandler: (streams: [TwitchStream]?, error: ServiceError?) -> ())

    func getEmoteUrlStringFromId(id : String) -> String
}