import AVKit
import UIKit
import Foundation

enum StreamSourceQuality: String {
    case Source
    case High
    case Medium
    case Low
}

class TwitchVideoViewController : UIViewController {
    internal var videoView : VideoView?
    private var videoPlayer : AVPlayer?
    private var chatView : TwitchChatView?

    internal var modalMenu : ModalMenuView?
    private var modalMenuOptions : [String : [MenuOption]]?

    internal var leftSwipe : UISwipeGestureRecognizer!
    internal var rightSwipe : UISwipeGestureRecognizer!
    internal var shortTap : UITapGestureRecognizer!
    internal var longTap : UILongPressGestureRecognizer!

    private var streams : [TwitchStreamVideo]?
    private var currentStream : TwitchStream?
    private var currentStreamVideo : TwitchStreamVideo?

    internal var twitchApiClient : TwitchApi!
    internal var mainQueueRunner : AsyncMainQueueRunner!
    
    convenience init(stream : TwitchStream, twitchClient : TwitchApi, mainQueueRunner : AsyncMainQueueRunner) {
        self.init(nibName: nil, bundle: nil)
        self.currentStream = stream
        self.twitchApiClient = twitchClient
        self.mainQueueRunner = mainQueueRunner
        
        self.view.backgroundColor = UIColor.blackColor()
        
        //Gestures configuration
        longTap = UILongPressGestureRecognizer(target: self, action: #selector(TwitchVideoViewController.handleLongPress(_:)))
        longTap.cancelsTouchesInView = true
        self.view.addGestureRecognizer(longTap)
        
        shortTap = UITapGestureRecognizer(target: self, action: #selector(TwitchVideoViewController.pause))
        shortTap.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(shortTap)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TwitchVideoViewController.handleMenuPress))
        gestureRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
        gestureRecognizer.cancelsTouchesInView = true
        self.view.addGestureRecognizer(gestureRecognizer)
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TwitchVideoViewController.swipe(_:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(leftSwipe)
        
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TwitchVideoViewController.swipe(_:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipe.enabled = false
        self.view.addGestureRecognizer(rightSwipe)
            
        //Modal menu options
        self.modalMenuOptions = [
            "Stream Quality" : [
                MenuOption(title: StreamSourceQuality.Source.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.High.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.Medium.rawValue, enabled: false, onClick: self.handleQualityChange),
                MenuOption(title: StreamSourceQuality.Low.rawValue, enabled: false, onClick: self.handleQualityChange)
            ]
        ]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.twitchApiClient.getStreamsForChannel(self.currentStream!.channel.name) {
            (streams, error) in
            
            if let streams = streams where streams.count > 0 {
                self.streams = streams
                self.currentStreamVideo = streams[0]
                let streamAsset = AVURLAsset(URL: self.currentStreamVideo!.url)
                let streamItem = AVPlayerItem(asset: streamAsset)
                
                self.videoPlayer = AVPlayer(playerItem: streamItem)
                
                self.mainQueueRunner.runOnMainQueue({ () -> () in
                    self.initializePlayerView()
                })
            } else {
                let alert = UIAlertController(title: "Uh-Oh!", message: "There seems to be an issue with the stream. We're very sorry about that.", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: { (action) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                
                self.mainQueueRunner.runOnMainQueue({ () -> () in
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    /*
    * viewWillDisappear(animated: Bool)
    *
    * Overrides the default method to shut off the chat connection if present
    * and the free video assets
    */
    override func viewWillDisappear(animated: Bool) {
        
        self.chatView?.stopDisplayingMessages()
        self.chatView?.removeFromSuperview()
        self.chatView = nil
        
        self.videoView?.removeFromSuperview()
        self.videoView?.setPlayer(nil)
        self.videoView = nil
        self.videoPlayer = nil

        super.viewWillDisappear(animated)
    }
    
    /*
    * initializePlayerView()
    *
    * Initializes a player view with the current video player
    * and displays it
    */
    func initializePlayerView() {
        self.videoView = VideoView(frame: self.view.bounds)
        self.videoView?.setPlayer(self.videoPlayer!)
        self.videoView?.setVideoFillMode(AVLayerVideoGravityResizeAspect)
        
        self.view.addSubview(self.videoView!)
        self.videoPlayer?.play()
    }
    
    /*
    * initializeChatView()
    *
    * Initializes a chat view for the current channel
    * and displays it
    */
    func initializeChatView() {
        self.chatView = TwitchChatView(frame: CGRect(x: 0, y: 0, width: 400, height: self.view!.bounds.height), channel: self.currentStream!.channel)
        self.chatView!.startDisplayingMessages()
        self.chatView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.chatView!)
    }
    
    /*
    * handleLongPress()
    *
    * Handler for the UILongPressGestureRecognizer of the controller
    * Presents the modal menu if it is initialized
    */
    func handleLongPress(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state == UIGestureRecognizerState.Began {
            if self.modalMenu == nil {
                modalMenu = ModalMenuView(frame: self.view.bounds,
                    options: self.modalMenuOptions!,
                    size: CGSize(width: self.view.bounds.width/3, height: self.view.bounds.height/1.5))
                
                modalMenu!.center = self.view.center
            }
            
            guard let modalMenu = self.modalMenu else {
                return
            }
            
            if modalMenu.isDescendantOfView(self.view) {
                dismissMenu()
            } else {
                modalMenu.alpha = 0
                self.view.addSubview(self.modalMenu!)
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.modalMenu?.alpha = 1
                    self.view.setNeedsFocusUpdate()
                })
            }
        }
    }
    
    /*
    * handleMenuPress()
    *
    * Handler for the UITapGestureRecognizer of the modal menu
    * Dismisses the modal menu if it is present
    */
    func handleMenuPress() {
        if dismissMenu() {
            return
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissMenu() -> Bool {
        if let modalMenu = modalMenu {
            if self.view.subviews.contains(modalMenu) {
                //bkirchner: for some reason when i try to animate the menu fading away, it just goes to the homescreen - really odd
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    modalMenu.alpha = 0
                }, completion: { (finished) -> Void in
                    Logger.Debug("Fade away animation finished: \(finished)")
                    if finished {
                        modalMenu.removeFromSuperview()
                    }
                })
//                modalMenu.removeFromSuperview()
                return true
            }
        }
        return false
    }
    
    /*
    * handleChatOnOff(sender : MenuItemView?)
    *
    * Handler for the chat option from the modal menu
    * Displays or remove the chat view
    */
    func handleChatOnOff(sender : MenuItemView?) {
        //NOTE(Olivier) : 400 width reduction at 16:9 is 225 height reduction
        self.mainQueueRunner.runOnMainQueue({ () -> () in
            if let menuItem = sender {
                if menuItem.isOptionEnabled() {     //                      Turn chat off
                    
                    self.hideChat()
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(false)
                }
                else {                              //                      Turn chat on
                    
                    self.showChat()
                    
                    //Set the menu option accordingly
                    menuItem.setOptionEnabled(true)
                }
            }
        })
    }
    
    func showChat() {
        //Resize video view
        var frame = self.videoView?.frame
        frame?.size.width -= 400
        frame?.size.height -= 225
        frame?.origin.y += (225/2)
        
        
        
        //The chat view
        self.chatView = TwitchChatView(frame: CGRect(x: self.view.bounds.width, y: 0, width: 400, height: self.view!.bounds.height), channel: self.currentStream!.channel)
        self.chatView!.startDisplayingMessages()
        if let modalMenu = modalMenu {
            
            self.view.insertSubview(self.chatView!, belowSubview: modalMenu)
        } else {
            self.view.addSubview(self.chatView!)
        }
        
        rightSwipe.enabled = true
        leftSwipe.enabled = false
        
        //animate the showing of the chat view
        UIView.animateWithDuration(0.5) { () -> Void in
            self.chatView!.frame = CGRect(x: self.view.bounds.width - 400, y: 0, width: 400, height: self.view!.bounds.height)
            if let videoView = self.videoView, frame = frame {
                videoView.frame = frame
            }
        }
    }
    
    func hideChat() {
        
        rightSwipe.enabled = false
        leftSwipe.enabled = true
        
        //animate the hiding of the chat view
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.videoView!.frame = self.view.frame
            self.chatView!.frame.origin.x = CGRectGetMaxX(self.view.frame)
        }) { (finished) -> Void in
                //The chat view
                self.chatView!.stopDisplayingMessages()
                self.chatView!.removeFromSuperview()
                self.chatView = nil
        }
    }
    
    func handleQualityChange(sender : MenuItemView?) {
        if let text = sender?.title?.text, quality = StreamSourceQuality(rawValue: text) {
            var qualityIdentifier = "chunked"
            switch quality {
            case .Source:
                qualityIdentifier = "chunked"
            case .High:
                qualityIdentifier = "high"
            case .Medium:
                qualityIdentifier = "medium"
            case .Low:
                qualityIdentifier = "low"
            }
            if let streams = self.streams {
                for stream in streams {
                    if stream.quality == qualityIdentifier {
                        currentStreamVideo = stream
                        let streamAsset = AVURLAsset(URL: stream.url)
                        let streamItem = AVPlayerItem(asset: streamAsset)
                        self.videoPlayer?.replaceCurrentItemWithPlayerItem(streamItem)
                        dismissMenu()
                        return
                    }
                }
            }
        }
    }
    
    func pause() {
        if let player = self.videoPlayer {
            if player.rate == 1 {
                videoView?.alpha = 0.40
                player.pause()
            } else {
                if let currentVideo = currentStreamVideo {
                    //do this to bring it back in sync
                    let streamAsset = AVURLAsset(URL: currentVideo.url)
                    let streamItem = AVPlayerItem(asset: streamAsset)
                    player.replaceCurrentItemWithPlayerItem(streamItem)
                }
                videoView?.alpha = 1.0
                player.play()
            }
        }
    }
    
    func swipe(recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .Ended {
            if recognizer.direction == .Left {
                showChat()
            } else {
                hideChat()
            }
        }
    }
}
