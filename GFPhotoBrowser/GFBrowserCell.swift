//
//  GFBrowserCell.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/2/1.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class GFBrowserCell: UICollectionViewCell {
    
    var asset: PHAsset? {
        didSet{
            checkViewHidden();
            updateImage();
        }
    }
    var netResource: GFURLMediaType? {
        didSet{
            checkViewHidden();
            updateImage();
        }
    }
    
    var imageView: UIImageView!
    var livePhotoView: PHLivePhotoView!
    var playerLayer: AVPlayerLayer?
    var playButton: UIButton!
    
    var isPlayingHint = false
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        setupUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImage() {
        
        guard let asset = asset else {
            return
        }
        if asset.mediaSubtypes.contains(.photoLive) {
            updateLivePhoto()
        } else {
            updateStaticImage()
        }
    }
    
    func setupUI() {
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
        
        livePhotoView = PHLivePhotoView()
        livePhotoView.frame = contentView.bounds
        livePhotoView.delegate = self
        contentView.addSubview(livePhotoView)
        
        playButton = UIButton();
        playButton.frame = CGRect(x: contentView.bounds.width/2 - 20, y: contentView.bounds.height/2 - 20, width: 40, height: 40);
        playButton.setImage(UIImage(named: "videoPlay"), for: .normal);
        playButton.addTarget(self, action: #selector(play(_:)), for: .touchUpInside);
        contentView.addSubview(playButton);
    }
    
    func checkViewHidden() {
        guard let asset = asset else {
            return
        }
        switch asset.mediaType {
        case .image:
            if asset.mediaSubtypes.contains(.photoLive) {
                livePhotoView.isHidden = false;
                imageView.isHidden = true;
                playButton.isHidden = true;
                guard let layer = self.playerLayer else {return}
                layer.isHidden = true;
            }else{
                livePhotoView.isHidden = true;
                playButton.isHidden = true;
                imageView.isHidden = false;
                guard let layer = self.playerLayer else {return}
                layer.isHidden = true;
            }
        case .video:
            livePhotoView.isHidden = true;
            imageView.isHidden = true;
            playButton.isHidden = false;
            guard let layer = self.playerLayer else {return}
            layer.isHidden = false;
        default:
            break;
        }
    }
    
    @objc func play(_ sender: AnyObject) {
        
        if playerLayer != nil {
            // The app already created an AVPlayerLayer, so tell it to play.
            playerLayer?.player?.play();
        } else {
            playLocalVideo();
        }
    }
    
    func playLocalVideo() {
        
        guard let asset = asset else { return }
        
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .automatic
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                //                    self.progressView.progress = Float(progress)
            }
        }
        // Request an AVPlayerItem for the displayed PHAsset.
        // Then configure a layer for playing it.
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
            DispatchQueue.main.sync {
                guard self.playerLayer == nil else { return }
                
                // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
                let player = AVPlayer(playerItem: playerItem)
                player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.pause;
                let playerLayer = AVPlayerLayer(player: player)
                
                // Configure the AVPlayerLayer and add it to the view.
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                playerLayer.frame = self.contentView.layer.bounds
                self.contentView.layer.addSublayer(playerLayer)
                
                player.play()
                
                // Cache the player layer by reference, so you can remove it later.
                self.playerLayer = playerLayer
            }
        })
    }
    
    func updateLivePhoto() {
        
        guard let asset = asset else { return }
        // Prepare the options to pass when fetching the live photo.
        let options = PHLivePhotoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                //                self.progressView.progress = Float(progress)
            }
        }
        
        // Request the live photo for the asset from the default PHImageManager.
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                                  resultHandler: { livePhoto, info in
                                                    // PhotoKit finishes the request, so hide the progress view.
                                                    //                                                    self.progressView.isHidden = true
                                                    
                                                    // Show the Live Photo view.
                                                    guard let livePhoto = livePhoto else { return }
                                                    
                                                    // Show the Live Photo.
                                                    self.imageView.isHidden = true
                                                    self.livePhotoView.isHidden = false
                                                    self.livePhotoView.livePhoto = livePhoto
                                                    
                                                    if !self.isPlayingHint {
                                                        // Play back a short section of the Live Photo, similar to the Photos share sheet.
                                                        self.isPlayingHint = true
                                                        self.livePhotoView.startPlayback(with: .hint)
                                                    }
        })
    }
    
    func updateURLImage(url: URL?) {
//        self.imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
//            if image == nil {
//                assertionFailure()
//            }else{
//                self.resizeImageView()
//            }
//        }

    }
    
    func updateStaticImage() {
        
        guard let asset = asset else { return }
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            // The handler may originate on a background queue, so
            // re-dispatch to the main queue for UI work.
            DispatchQueue.main.sync {
                //                self.progressView.progress = Float(progress)
            }
        }
        
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                              resultHandler: { image, _ in
                                                // PhotoKit finished the request, so hide the progress view.
                                                //                                                self.progressView.isHidden = true
                                                
                                                // If the request succeeded, show the image view.
                                                guard let image = image else { return }
                                                
                                                // Show the image.
                                                self.livePhotoView.isHidden = true
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
        })
    }
    
    override func prepareForReuse() {
        imageView.image = nil;
        livePhotoView.livePhoto = nil;
        asset = nil;
        playerLayer?.removeFromSuperlayer();
        playerLayer = nil;
    }
}


// MARK: PHLivePhotoViewDelegate
extension GFBrowserCell: PHLivePhotoViewDelegate {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
}


