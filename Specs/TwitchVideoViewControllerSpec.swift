import Quick
import Nimble
@testable import StreamCenter

class TwitchVideoViewControllerSpec: QuickSpec {
    override func spec() {
        describe("a view controller that presents twitch streams") {
            var subject : TwitchVideoViewController!
            var twitchStream : TwitchStream!
            var twitchChannel : TwitchChannel!
            var fakeTwitchAPI : FakeTwitchApi!

            beforeEach {
                fakeTwitchAPI = FakeTwitchApi.init()
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
                subject = TwitchVideoViewController.init(stream: twitchStream, twitchClient:fakeTwitchAPI)
            }

            context("when the view loads and appears") {
                beforeEach {
                    fakeTwitchAPI.getStreamsForChannelReturns(())

                    expect(subject.view).toNot(beNil());
                    subject.viewDidAppear(false)
                }

                it("should make a request to get the streams for the current channel") {
                    expect(fakeTwitchAPI.getStreamsForChannelCallCount).to(equal(1));

                    let args = fakeTwitchAPI.getStreamsForChannelArgsForCall(0)
                    expect(args.0).to(equal("MySpecialChannel"))
                }

                context("when the user presses the play/pause button") {
                    beforeEach {
                        let args = fakeTwitchAPI.getStreamsForChannelArgsForCall(0)
                        let cb = args.1
                        let twitchStreamVideo = TwitchStreamVideo.init(
                            quality: "whatevs",
                            url: NSURL.init(string: "https://this-that-url")!,
                            codecs: "some-pretend-codes"
                        )
                        cb(streams: [twitchStreamVideo], error: nil)
                    }

                    it("should dim the video view's opacity") {
                        expect(subject.videoView?.alpha).to(equal(0.4));
                    }

                    context("when the play/pause button is pressed again") {
                        beforeEach {

                        }

                        it("should un-dim the video view") {
                            expect(subject.videoView?.alpha).to(equal(1));
                        }
                    }
                }
            }
        }
    }
}