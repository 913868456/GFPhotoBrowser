//
//  GFGridViewCell.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/1/30.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class GFGridViewCell: UICollectionViewCell {
    
    var thumbnailImageView: UIImageView!
    var badgeImageView: UIImageView!
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    var badgeImage: UIImage! {
        didSet {
            badgeImageView.image = badgeImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setupUI() {
        
        contentView.backgroundColor = BrowserConst.itemBgColor;
        let width = contentView.frame.size.width;
        
        thumbnailImageView = UIImageView();
        thumbnailImageView.frame = self.bounds;
        thumbnailImageView.contentMode = .scaleAspectFill;
        thumbnailImageView.layer.masksToBounds = true;
        contentView.addSubview(thumbnailImageView);
        
        badgeImageView = UIImageView();
        badgeImageView.layer.masksToBounds = true;
        badgeImageView.frame = CGRect(x: width - BrowserConst.badgeWidth - 4, y: 4, width: BrowserConst.badgeWidth, height: BrowserConst.badgeHeight);
        contentView.addSubview(badgeImageView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        thumbnailImageView.image = nil;
        badgeImageView.image = nil;
    }
}
