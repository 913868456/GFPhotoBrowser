//
//  ViewController.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/1/30.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notify(_:)), name: BrowserConst.kSelectedNotification, object: nil);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func notify(_ notification: Notification) {
        let userInfo = notification.userInfo;
        if let assets = userInfo?[BrowserConst.kPHAssetsKey] as? [PHAsset] {
            print(assets.count);
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = GFAssetGridViewController()
        let navController = UINavigationController.init(rootViewController: vc);
        self.present(navController, animated: true, completion: nil);
    }

}

