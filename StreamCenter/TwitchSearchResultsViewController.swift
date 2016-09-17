import UIKit

private enum SearchType {
    case game
    case stream
}

class TwitchSearchResultsViewController: LoadingViewController {
    
    fileprivate let LOADING_BUFFER = 20
    
    override var NUM_COLUMNS: Int {
        switch searchType {
        case .game:
            return 5
        case .stream:
            return 3
        }
    }
    
    override var ITEMS_INSETS_X: CGFloat {
        get {
            switch searchType {
            case .game:
                return 25
            case .stream:
                return 45
            }
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            switch searchType {
            case .game:
                return 1.39705882353
            case .stream:
                return 0.5625
            }
        }
    }

    fileprivate var games = [TwitchGame]()
    fileprivate var streams = [TwitchStream]()

    internal var searchTypeControl: UISegmentedControl!
    fileprivate var searchType = SearchType.game

    fileprivate var searchTerm: String!
    fileprivate var twitchAPIClient : TwitchApi!
    fileprivate var mainQueueRunner : AsyncMainQueueRunner!
    
    convenience init(searchTerm term: String, twitchClient : TwitchApi, mainQueueRunner : AsyncMainQueueRunner) {
        self.init(nibName: nil, bundle: nil)
        self.searchTerm = term
        self.twitchAPIClient = twitchClient
        self.mainQueueRunner = mainQueueRunner
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.streams.count == 0 || self.games.count == 0 {
            loadContent()
        }
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Results...")
        self.twitchAPIClient.getGamesWithSearchTerm(searchTerm, offset: 0, limit: LOADING_BUFFER) { (games, error) -> () in
            guard let games = games else {
                self.mainQueueRunner.runOnMainQueue({
                    self.removeLoadingView()
                    self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.games = games
            self.mainQueueRunner.runOnMainQueue({
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
        self.twitchAPIClient.getStreamsWithSearchTerm(searchTerm, offset: 0, limit: LOADING_BUFFER) { (streams, error) -> () in
            guard let streams = streams else {
                self.mainQueueRunner.runOnMainQueue({
                    self.removeLoadingView()
                    self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.streams = streams
            self.mainQueueRunner.runOnMainQueue({
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    fileprivate func configureViews() {
        self.searchTypeControl = UISegmentedControl(items: ["Games", "Streams"])
        self.searchTypeControl.translatesAutoresizingMaskIntoConstraints = false
        self.searchTypeControl.selectedSegmentIndex = 0
        self.searchTypeControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(white: 0.45, alpha: 1)], for: UIControlState())
        self.searchTypeControl.addTarget(
            self,
            action: #selector(TwitchSearchResultsViewController.changedSearchType(_:forEvent:)),
            for: .valueChanged
        )
        
        super.configureViews("Search Results - \(searchTerm)", centerView: nil, leftView: self.searchTypeControl, rightView: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    func changedSearchType(_ control: UISegmentedControl, forEvent: UIEvent) {
        switch control.selectedSegmentIndex {
        case 0:
            searchType = .game
        case 1:
            searchType = .stream
        default:
            return
        }
        collectionView.reloadData()
    }
    
    override func loadMore() {
        if searchType == .stream {
            self.twitchAPIClient.getStreamsWithSearchTerm(self.searchTerm, offset: self.streams.count, limit: LOADING_BUFFER, completionHandler: { (streams, error) -> () in
                guard let streams = streams else {
                    return
                }
                var paths = [IndexPath]()
                
                let filteredStreams = streams.filter({
                    let streamId = $0.id
                    if let _ = self.streams.index(where: {$0.id == streamId}) {
                        return false
                    }
                    return true
                })
                
                for i in 0..<filteredStreams.count {
                    paths.append(IndexPath(item: i + self.streams.count, section: 0))
                }
                
                self.collectionView.performBatchUpdates({
                    self.streams.append(contentsOf: filteredStreams)
                    
                    self.collectionView.insertItems(at: paths)
                    
                    }, completion: nil)
            })
        }
    }
    
    override var itemCount: Int {
        get {
            switch searchType {
            case .game:
                return games.count
            case .stream:
                return streams.count
            }
        }
    }

    override func getItemAtIndex(_ index: Int) -> CellItem {
        switch searchType {
        case .game:
            return games[index]
        case .stream:
            return streams[index]
        }
    }

}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension TwitchSearchResultsViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        switch searchType {
        case .game:
            let selectedGame = games[(indexPath as NSIndexPath).row]
            let streamViewController = TwitchStreamsViewController(game: selectedGame)
            self.present(streamViewController, animated: true, completion: nil)
        case .stream:
            let selectedStream = streams[(indexPath as NSIndexPath).row]
            let videoViewController = TwitchVideoViewController(
                stream: selectedStream,
                twitchClient: TwitchApiClient.init(),
                mainQueueRunner: AsyncMainQueueRunnerImpl.init()
            )
            
            self.present(videoViewController, animated: true, completion: nil)
        }
    }
    
}
