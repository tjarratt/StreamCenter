//
//  ViewController.swift
//  TestTVApp
//
//  Created by Olivier Boucher on 2015-09-13.

import UIKit

class TwitchGamesViewController : LoadingViewController {

    fileprivate let LOADING_BUFFER = 20
    
    override var NUM_COLUMNS: Int {
        get {
            return 5
        }
    }
    
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 25
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            return 1.39705882353
        }
    }
    
    fileprivate var searchField: UITextField!
    fileprivate var games = [TwitchGame]()
    fileprivate var twitchButton: UIButton?
    fileprivate var twitchAPIClient : TwitchApi = TwitchApiClient.init() // FIXME: should be injected

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
    }

    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Games...")
        self.twitchAPIClient.getTopGamesWithOffset(0, limit: 17) {
            (games, error) in
            
            guard let games = games else {
                DispatchQueue.main.async(execute: {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading game list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.games = games
            DispatchQueue.main.async(execute: {
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    func configureViews() {
        self.searchField = UITextField(frame: CGRect.zero)
        self.searchField.translatesAutoresizingMaskIntoConstraints = false
        self.searchField.placeholder = "Search Games or Streams"
        self.searchField.delegate = self
        self.searchField.textAlignment = .center

        if TokenHelper.getTwitchToken() == nil {
            self.twitchButton = UIButton(type: .system)
            self.twitchButton?.translatesAutoresizingMaskIntoConstraints = false
            self.twitchButton?.setTitleColor(UIColor.darkGray, for: UIControlState())
            self.twitchButton?.setTitle("Authenticate", for: UIControlState())
            self.twitchButton?.addTarget(self, action: #selector(TwitchGamesViewController.authorizeUser), for: .primaryActionTriggered)
        }
        
        let imageView = UIImageView(image: UIImage(named: "twitch"))
        imageView.contentMode = .scaleAspectFit
        
        super.configureViews("Top Games", centerView: imageView, leftView: self.searchField, rightView: nil)
    }
    
    func authorizeUser() {
        let qrController = TwitchAuthViewController()
        qrController.delegate = self
        present(qrController, animated: true, completion: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    override func loadMore() {
        self.twitchAPIClient.getTopGamesWithOffset(games.count, limit: LOADING_BUFFER) {
            (games, error) in
            
            guard let games = games , games.count > 0 else {
                return
            }
            
            var paths = [IndexPath]()
            
            let filteredGames = games.filter({
                let gameId = $0.id
                if let _ = self.games.index(where: {$0.id == gameId}) {
                    return false
                }
                return true
            })
            
            for i in 0..<filteredGames.count {
                paths.append(IndexPath(item: i + self.games.count, section: 0))
            }
            
            self.collectionView.performBatchUpdates({
                self.games.append(contentsOf: filteredGames)
                
                self.collectionView.insertItems(at: paths)
                
                }, completion: nil)
        }
    }
    
    override var itemCount: Int {
        get {
            return games.count
        }
    }
    
    override func getItemAtIndex(_ index: Int) -> CellItem {
        return games[index]
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////


extension TwitchGamesViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let selectedGame = games[(indexPath as NSIndexPath).row]
        let streamsViewController = TwitchStreamsViewController(game: selectedGame)
        
        self.present(streamsViewController, animated: true, completion: nil)
    }
    
}

//////////////////////////////////////////////
// MARK - UITextFieldDelegate interface
//////////////////////////////////////////////

extension TwitchGamesViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let term = textField.text , !term.isEmpty else {
            return
        }

        let searchViewController = TwitchSearchResultsViewController(
            searchTerm: term,
            twitchClient: self.twitchAPIClient,
            mainQueueRunner: AsyncMainQueueRunnerImpl()
        )
        present(searchViewController, animated: true, completion: nil)
    }
}

//////////////////////////////////////////////
// MARK - QRCodeDelegate interface
//////////////////////////////////////////////

extension TwitchGamesViewController: QRCodeDelegate {
    
    func qrCodeViewControllerFinished(_ success: Bool, data: [String : AnyObject]?) {
        DispatchQueue.main.async { () -> Void in
            if success {
                self.twitchButton?.removeFromSuperview()
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
