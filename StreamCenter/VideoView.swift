//
//  VideoView.swift
//  GamingStreamsTVApp
//
//  Created by Olivier Boucher on 2015-09-14.

import UIKit
import AVFoundation
import Foundation

class VideoView : UIView {
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    func getPlayer() -> AVPlayer? {
        let layer = self.layer as! AVPlayerLayer
        return layer.player
    }
    
    func setPlayer(_ player : AVPlayer?) {
        let layer = self.layer as! AVPlayerLayer
        layer.player = player
    }
    
    func setVideoFillMode(_ fillMode : String) {
        let layer = self.layer as! AVPlayerLayer
        layer.videoGravity = fillMode
    }
}
