//
//  TwitchStreamsViewController.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import UIKit
import Foundation

class TwitchStreamsViewController: LoadingViewController {
    fileprivate let LOADING_BUFFER = 12
    
    override var NUM_COLUMNS: Int {
        get {
            return 3
        }
    }
    
    override var ITEMS_INSETS_X : CGFloat {
        get {
            return 45
        }
    }
    
    override var HEIGHT_RATIO: CGFloat {
        get {
            return 0.5625
        }
    }
    
    fileprivate var game : TwitchGame!
    fileprivate var streams = [TwitchStream]()
    fileprivate var twitchAPIClient : TwitchApi = TwitchApiClient.init() // FIXME: should be injected
    
    convenience init(game : TwitchGame){
        self.init(nibName: nil, bundle: nil)
        self.game = game
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViews()
    }
    
    /*
    * viewWillAppear(animated: Bool)
    *
    * Overrides the super function to reload the collection view with fresh data
    * 
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadContent() {
        self.removeErrorView()
        self.displayLoadingView("Loading Streams...")
        self.twitchAPIClient.getTopStreamsForGameWithOffset(self.game!.name, offset: 0, limit: 20) {
            (streams, error) in
            
            guard let streams = streams else {
                DispatchQueue.main.async(execute: {
                    self.removeLoadingView()
                    self.displayErrorView("Error loading streams list.\nPlease check your internet connection.")
                })
                return
            }
            
            self.streams = streams
            DispatchQueue.main.async(execute: {
                self.removeLoadingView()
                self.collectionView.reloadData()
            })
        }
    }
    
    fileprivate func configureViews() {
        super.configureViews("Live Streams - \(self.game.name!)", centerView: nil, leftView: nil, rightView: nil)
    }
    
    override func reloadContent() {
        loadContent()
        super.reloadContent()
    }
    
    override func loadMore() {
        self.twitchAPIClient.getTopStreamsForGameWithOffset(self.game!.name, offset: self.streams.count, limit: LOADING_BUFFER) {
            (streams, error) in
            
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
        }
    }
    
    override var itemCount: Int {
        get {
            return streams.count
        }
    }
    
    override func getItemAtIndex(_ index: Int) -> CellItem {
        return streams[index]
    }
}

////////////////////////////////////////////
// MARK - UICollectionViewDelegate interface
////////////////////////////////////////////

extension TwitchStreamsViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let selectedStream = streams[(indexPath as NSIndexPath).row]
        let videoViewController = TwitchVideoViewController(
            stream: selectedStream,
            twitchClient: TwitchApiClient.init(),
            mainQueueRunner: AsyncMainQueueRunnerImpl.init()
        )
        
        self.present(videoViewController, animated: true, completion: nil)
    }
    
}
