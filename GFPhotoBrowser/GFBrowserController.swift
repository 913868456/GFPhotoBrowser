//
//  GFBrowserController.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/1/31.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

fileprivate let gridCell = "GFGridCell"
fileprivate let browserCell = "GFBrowserCell"

class GFBrowserController: UIViewController {
    
    //数据
    var resourceType: GFResourceType!
    var asset: PHAsset!
    var assets = [PHAsset]()
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var netResources: [GFURLMediaType]!
    
    //UI组件
    var navigationView: UIView!
    var scrollCollectionView: UICollectionView!
    var contentCollectionView: UICollectionView!
    var toolBar : UIView!
    var titleLabel: UILabel!
    
    //Data
    var statusBarHidden: Bool = false
    var selectIndex: Int = 1 {
        didSet{
            if resourceType == .local {
                titleLabel.text = "\(selectIndex)/\(assets.count)"
                scrollCollectionView.reloadData()
            } else {
                titleLabel.text = "\(selectIndex)/\(netResources.count)"
            }
        }
    }
    //缓存管理
    fileprivate let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = BrowserConst.bgColor
        
        if assets.isEmpty {
            resourceType = .url
        }else {
            resourceType = .local
        }
        if resourceType == .local {
            setConfig()
            setContentView()
            setNavigationView()
            setCollectionView()
            setToolBar()
            titleLabel.text = "\(selectIndex)/\(assets.count)"
        } else {
            setContentView()
            setNavigationView()
            titleLabel.text = "\(selectIndex)/\(netResources.count)"
        }
    }
    
    deinit {
        imageManager.stopCachingImagesForAllAssets();
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setConfig() {
        
        PHPhotoLibrary.shared().register(self)
        imageManager.stopCachingImagesForAllAssets();
//        if fetchResult == nil {
//            let allPhotosOptions = PHFetchOptions()
//            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
//        }
        
        let scale = UIScreen.main.scale;
        let assetSize = CGSize(width: BrowserConst.assetCollectionItemSize.width * scale, height: BrowserConst.assetCollectionItemSize.height * scale);
        imageManager.startCachingImages(for: assets, targetSize: assetSize, contentMode: .aspectFit, options: nil);
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden;
    }
    
    func setNavigationView() {
        
        self.navigationController?.navigationBar.isHidden = true;
        navigationView = UIView();
        navigationView.frame = CGRect(x: 0, y: 0, width: BrowserConst.kScreenWidth, height: BrowserConst.kNavigationBarHeight);
        navigationView.backgroundColor = BrowserConst.bgColor;
        view.addSubview(navigationView);
        
        let backBtn = UIButton();
        backBtn.frame = CGRect(x: 0, y: BrowserConst.kStatusBarHeight, width: 52, height: BrowserConst.kNavigationBarHeight - BrowserConst.kStatusBarHeight);
        backBtn.setImage(UIImage(named: "back"), for: .normal);
        backBtn.addTarget(self, action: #selector(pop), for: .touchUpInside);
        navigationView.addSubview(backBtn);
        
        titleLabel = UILabel();
        titleLabel.frame = CGRect(x: BrowserConst.kScreenWidth/2 - 50, y: BrowserConst.kStatusBarHeight, width: 100, height: BrowserConst.kNavigationBarHeight - BrowserConst.kStatusBarHeight);
        titleLabel.textColor = BrowserConst.titleColor;
        titleLabel.textAlignment = .center;
        titleLabel.font = BrowserConst.titleFont;
        navigationView.addSubview(titleLabel);
        
        let separator = UIView();
        separator.frame = CGRect(x: 0, y: BrowserConst.kNavigationBarHeight - BrowserConst.separatorWidth, width: BrowserConst.kScreenWidth, height: BrowserConst.separatorWidth);
        separator.backgroundColor = BrowserConst.separatorColor;
        navigationView.addSubview(separator);
    }
    
    @objc func pop() {
        self.navigationController?.popViewController(animated: true);
    }
    
    func setContentView() {
        
        let flowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = .horizontal;
        flowLayout.minimumLineSpacing = 0;//默认10,这里要设置为0
        flowLayout.itemSize = CGSize(width: BrowserConst.kScreenWidth, height: BrowserConst.kScreenHeight);
        contentCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: BrowserConst.kScreenWidth, height: BrowserConst.kScreenHeight), collectionViewLayout: flowLayout);
        if #available(iOS 11.0, *) {
            contentCollectionView.contentInsetAdjustmentBehavior = .never;
        }else{
            self.automaticallyAdjustsScrollViewInsets = false
        }
        contentCollectionView.register(GFBrowserCell.self, forCellWithReuseIdentifier: browserCell);
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
        contentCollectionView.isPagingEnabled = true;//打开页面滚动
        view.addSubview(contentCollectionView);
        
        let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(showOrHideToolBar));
        contentCollectionView.addGestureRecognizer(tapGuesture);
    }
    
    func setCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal;
        flowLayout.minimumLineSpacing = BrowserConst.assetCollectionInterSpacing
        flowLayout.itemSize = BrowserConst.assetCollectionItemSize
        scrollCollectionView = UICollectionView(frame: CGRect(x: 0, y: BrowserConst.kScreenHeight - 68 - BrowserConst.kBootomBarHeight, width: BrowserConst.kScreenWidth, height: 68), collectionViewLayout: flowLayout)
        scrollCollectionView.backgroundColor = BrowserConst.collectionBgColor
        scrollCollectionView.register(GFGridViewCell.self, forCellWithReuseIdentifier: gridCell)
        scrollCollectionView.dataSource = self
        scrollCollectionView.delegate = self
        scrollCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16);
        scrollCollectionView.layer.borderWidth = BrowserConst.separatorWidth;
        scrollCollectionView.layer.borderColor = BrowserConst.separatorColor.cgColor;
        scrollCollectionView.layer.masksToBounds = true;
        view.addSubview(scrollCollectionView)
    }
    
    func setToolBar() {
        toolBar = UIView();
        toolBar.frame = CGRect(x: 0, y: BrowserConst.kScreenHeight - BrowserConst.kBootomBarHeight, width: BrowserConst.kScreenWidth, height: BrowserConst.kBootomBarHeight)
        toolBar.backgroundColor = BrowserConst.bgColor
        view.addSubview(toolBar)
        
        let doneBtn = UIButton();
        doneBtn.frame = CGRect(x: BrowserConst.kScreenWidth - 67, y: 8.5, width: 52, height: 32);
        doneBtn.backgroundColor = BrowserConst.doneBtnColor;
        doneBtn.setTitle(Bundle.localizeString(with: "DONE"), for: .normal);
        doneBtn.titleLabel?.font = BrowserConst.toolBtnFont;
        doneBtn.addTarget(self, action: #selector(selectCompleted), for: .touchUpInside);
        doneBtn.setTitleColor(.white, for: .normal);
        doneBtn.layer.cornerRadius = 2;
        doneBtn.layer.masksToBounds = true;
        toolBar.addSubview(doneBtn);
    }
    
    @objc func selectCompleted() {
        
        if assets.isEmpty {
            NotificationCenter.default.post(name: BrowserConst.kSelectedNotification, object: nil, userInfo: [BrowserConst.kPHAssetsKey: []])
            self.navigationController?.dismiss(animated: true, completion: nil);
        }else{
            NotificationCenter.default.post(name: BrowserConst.kSelectedNotification, object: nil, userInfo: [BrowserConst.kPHAssetsKey: assets])
            self.navigationController?.dismiss(animated: true, completion: nil);
        }
    }
    
    @objc func showOrHideToolBar() {
        
        if resourceType == .local {
            toolBar.isHidden = !toolBar.isHidden
            navigationView.isHidden = !navigationView.isHidden
            scrollCollectionView.isHidden = !scrollCollectionView.isHidden
            statusBarHidden = !statusBarHidden
            self.setNeedsStatusBarAppearanceUpdate();
        }else{
            navigationView.isHidden = !navigationView.isHidden
            statusBarHidden = !statusBarHidden
            self.setNeedsStatusBarAppearanceUpdate();
        }
    }
    
    //MARK: - Actions
    
    func removeAsset(_ sender: AnyObject) {
        let completion = { (success: Bool, error: Error?) -> Void in
            if success {
                DispatchQueue.main.sync {
                    _ = self.navigationController!.popViewController(animated: true)
                }
            } else {
                print("Can't remove the asset: \(String(describing: error))")
            }
        }
        if assetCollection != nil {
            // Remove the asset from the selected album.
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest(for: self.assetCollection)!
                request.removeAssets([self.asset] as NSArray)
            }, completionHandler: completion)
        } else {
            // Delete the asset from the photo library.
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([self.asset] as NSArray)
            }, completionHandler: completion)
        }
    }
}

extension GFBrowserController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if resourceType == .local {
            return assets.count
        }else {
            return netResources.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if resourceType == .local {
            if collectionView == scrollCollectionView {
                return getGridCell(collectionView, with: indexPath);
            }else if collectionView == contentCollectionView {
                return getBrowserCell(collectionView,with: indexPath);
            }else{
                return UICollectionViewCell();
            }
        }else {
            return getBrowserCell(collectionView,with: indexPath);
        }
    }
    
    func getGridCell(_ collectionView: UICollectionView, with indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCell, for: indexPath) as? GFGridViewCell
            else {
            return UICollectionViewCell()
        }
        let asset = assets[indexPath.item]
        cell.representedAssetIdentifier = asset.localIdentifier
        let scale = UIScreen.main.scale;
        let assetSize = CGSize(width: BrowserConst.assetCollectionItemSize.width * scale, height: BrowserConst.assetCollectionItemSize.height * scale);
        imageManager.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        if indexPath.item == selectIndex - 1 {
            cell.layer.borderWidth = 1.5
            cell.layer.borderColor = BrowserConst.doneBtnColor.cgColor
        }else{
            cell.layer.borderWidth = 0
            cell.layer.borderColor = nil
        }
        return cell
    }
    
    func getBrowserCell(_ collectionView: UICollectionView, with indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: browserCell, for: indexPath) as? GFBrowserCell
            else {
                return UICollectionViewCell()
        }
        if resourceType == .local {
            let asset = assets[indexPath.item]
            cell.asset = asset;
        }else {
            
        }
       
        return cell
    }
}

extension GFBrowserController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == contentCollectionView {
            let indexPaths = contentCollectionView.indexPathsForVisibleItems;
            if let idx = indexPaths.first {
                scrollCollectionView.scrollToItem(at: idx, at: .centeredHorizontally, animated: true);
                selectIndex = idx.row + 1
            }
            for idx in 0..<assets.count {//关闭所有player的播放
                guard let cell = contentCollectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as? GFBrowserCell else {
                    return
                }
                if cell.asset?.mediaType == .video {
                    cell.playerLayer?.player?.pause();
                    cell.checkViewHidden();
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == scrollCollectionView {
            contentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true);
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true);
            selectIndex = indexPath.row + 1;
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension GFBrowserController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // The call might come on any background queue. Re-dispatch to the main queue to handle it.
        DispatchQueue.main.sync {
            // Check if there are changes to the displayed asset.
            guard let details = changeInstance.changeDetails(for: asset) else { return }
            // Get the updated asset.
            asset = details.objectAfterChanges
            
            for idx in 0..<assets.count {
                let ast = assets[idx]
                if let details = changeInstance.changeDetails(for: ast) {
                    guard let temp = details.objectAfterChanges else { return }
                    if ast.localIdentifier == temp.localIdentifier {
                        assets[idx] = temp;
                        contentCollectionView.reloadData();
                        scrollCollectionView.reloadData();
                    }
                }
            }
        }
    }
}


