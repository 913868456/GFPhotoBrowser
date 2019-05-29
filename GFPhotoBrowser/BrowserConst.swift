//
//  BrowserConst.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/1/30.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos

class BrowserConst {
    
    //Size
    static var isFullScreen: Bool {
        if #available(iOS 11, *) {
            guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
                return false
            }
            
            if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                print(unwrapedWindow.safeAreaInsets)
                return true
            }
        }
        return false
    }
    static var kNavigationBarHeight: CGFloat {
        return isFullScreen ? 100 : 76
    }
    
    static var kStatusBarHeight: CGFloat {
        return isFullScreen ? 44 : 20
    }
    
    static var kBottomSafeHeight: CGFloat {
        return isFullScreen ? 34 : 0
    }
    
    static var kBootomBarHeight: CGFloat {
        return isFullScreen ? 83 : 49
    }
    static let kScreenWidth = UIScreen.main.bounds.width;
    static let kScreenHeight = UIScreen.main.bounds.height;
    
    //Notification
    static let kSelectedNotification = Notification.Name("kSelectedNotification");//选择完后的通知
    static let kPHAssetsKey = "kPHAssetsKey";
    
    //Color Width And Font
    static var titleColor = UIColor(red: 3/255.0, green: 3/255.0, blue: 3/255.0, alpha: 1.0)
    static var titleFont = UIFont.systemFont(ofSize: 18, weight: .medium)
    static var separatorWidth: CGFloat = 0.5;
    static var separatorColor: UIColor = UIColor(red: 223/255.0, green: 223/255.0, blue: 223/255.0, alpha: 1.0)
    static var toolBtnFont = UIFont.systemFont(ofSize: 14);
    static var toolBtnColor = UIColor(red: 93/255.0, green: 93/255.0, blue: 93/255.0, alpha: 1.0)
    static var lightTextBtnColor = UIColor(red: 166/255.0, green: 166/255.0, blue: 166/255.0, alpha: 1.0)
    
    //GFAssetGridViewController
    static var album = PHAssetCollectionSubtype.smartAlbumUserLibrary;//默认相册
    static var lineCount: CGFloat = 4;//每行显示结果item
    static var interSpacing: CGFloat = 5;
    static var lineSpacing: CGFloat = 5;
    static var gridContentInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static var badgeWidth = CGFloat(20);//角标宽
    static var badgeHeight = CGFloat(20);//角标高
    static var gridContentMode = UIView.ContentMode.scaleAspectFill;//item contentMode
    static var itemBgColor = UIColor.white;//item 背景色
    static var collectionBgColor = UIColor.white;//colletionView 背景色
    static var bgColor = UIColor.white;//view 背景色
    
    //GFBrowserController
    static var assetCollectionItemSize = CGSize(width: 44, height: 44);
    static var assetCollectionInterSpacing: CGFloat = 8;
    static var doneBtnColor = UIColor(red: 41/255.0, green: 192/255.0, blue: 147/255.0, alpha: 1.0);
    
}

