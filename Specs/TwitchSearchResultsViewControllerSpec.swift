import Quick
import Nimble
import UIKit_PivotalSpecHelperStubs
import UIKit_PivotalSpecHelper
@testable import StreamCenter

class TwitchSearchResultsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("a view controller that presents twitch search results") {

            var subject : TwitchSearchResultsViewController!
            var fakeTwitchAPI : FakeTwitchApi!
            var fakeAsyncMainQueueRunner : FakeAsyncMainQueueRunner!

            beforeEach {
                fakeAsyncMainQueueRunner = FakeAsyncMainQueueRunner.init()
                fakeAsyncMainQueueRunner.runOnMainQueueStub = {(cb : () -> ()) in cb() }
                fakeTwitchAPI = FakeTwitchApi.init()

                subject = TwitchSearchResultsViewController.init(
                    searchTerm: "garbage",
                    twitchClient:fakeTwitchAPI,
                    mainQueueRunner: fakeAsyncMainQueueRunner
                )
            }

            context("when the view loads and appears") {
                beforeEach {
                    fakeTwitchAPI.getGamesWithSearchTermStub = {(_ : String, _ : Int, _ : Int, cb : (games: [TwitchGame], error: ServiceError?) -> ()) in
                        let game = TwitchGame(id: 5, viewers: 66, channels: 0, name: "My-Game", thumbnails: [:], logos: [:])
                        cb(games: [game], error: nil)
                    }
                    fakeTwitchAPI.getStreamsWithSearchTermStub = {(_ : String, _ : Int, _ : Int, cb : (streams: [TwitchStream], error: ServiceError?) -> ()) in
                        let channel = TwitchChannel(id: 5, name: "My-Channel", displayName: "Name", links: [:], broadcasterLanguage: nil, language: "en", gameName: "My-Game", logo: nil, status: "My-Channel-Status", videoBanner: nil, lastUpdate: NSDate.init(timeIntervalSinceReferenceDate: 0), followers: 55, views: 555)
                        let stream = TwitchStream(id: 5, gameName: "My-Stream", viewers: 66, videoHeight: 60, preview: [:], channel: channel)
                        cb(streams: [stream], error: nil)
                    }

                    expect(subject.view).toNot(beNil());
                    subject.viewDidLoad()
                    subject.viewWillAppear(false)
                }

                it("should request streams matching the search term") {
                    expect(fakeTwitchAPI.getStreamsWithSearchTermCallCount).to(equal(1));
                }

                it("should request games matching the search term") {
                    expect(fakeTwitchAPI.getGamesWithSearchTermCallCount).to(equal(1));
                }

                it("should initially show the games results") {
                    let indexPath = NSIndexPath.init(forRow: 0, inSection: 0)
                    let firstCell = subject.collectionView.dataSource?.collectionView(
                        subject.collectionView,
                        cellForItemAtIndexPath: indexPath)

                    let titleLabel = firstCell?.contentView.subviews[1] as! ScrollingLabel
                    expect(titleLabel.text).to(equal("My-Game"))
                }

                context("when the user selects 'Streams'") {
                    beforeEach {
                        subject.searchTypeControl.selectSegmentAtIndex(1)
                    }

                    it("should show the stream results") {
                        let indexPath = NSIndexPath.init(forRow: 0, inSection: 0)
                        let firstCell = subject.collectionView.dataSource?.collectionView(
                            subject.collectionView,
                            cellForItemAtIndexPath: indexPath)

                        let titleLabel = firstCell?.contentView.subviews[1] as! ScrollingLabel
                        expect(titleLabel.text).to(equal("My-Channel-Status"))
                    }
                }
            }
        }
    }
}
