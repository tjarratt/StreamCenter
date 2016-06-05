import Quick
import Nimble
@testable import StreamCenter

class TwitchVideoViewControllerSpec: QuickSpec {
    override func spec() {
        describe("a view controller that presents twitch streams") {
            var subject : TwitchVideoViewController!
            var twitchStream : TwitchStream!
            var twitchChannel : TwitchChannel!

            beforeEach {
                twitchChannel = TwitchChannel.init(
                    id: 1,
                    name: "MySpecialChannel",
                    displayName: "MySpecialChannel",
                    links: [:],
                    broadcasterLanguage: nil,
                    language: "en",
                    gameName: "MySpecialGame",
                    logo: nil,
                    status: "yo-its-your-boy-status",
                    videoBanner: nil,
                    lastUpdate: NSDate.init(timeIntervalSinceNow: 0),
                    followers: 123,
                    views: 666)
                twitchStream = TwitchStream.init(
                    id: 1,
                    gameName: "MySpecialGame",
                    viewers: 5,
                    videoHeight: 60,
                    preview: ["key": "value"],
                    channel: twitchChannel)
                subject = TwitchVideoViewController.init(stream: twitchStream)
            }

            it("it should exist") {
                expect(subject).toNot(beNil())
            }
        }
    }
}