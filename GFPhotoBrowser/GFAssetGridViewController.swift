//
//  GFAssetGridViewController.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/1/30.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import UIKit
import Photos

fileprivate let reuseIdentifier = "GridViewCell"

class GFAssetGridViewController: UIViewController {
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var collectionView: UICollectionView!
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    var thumbnailSize = CGSize.zero
    var itemSize = CGSize.zero
    var selectIndexSet = IndexSet()
    
    var completion: (([PHAsset]) -> Void)?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var previousPreheatRect = CGRect.zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConfig();
        setupUI();
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setupUI() {
        
        setNavigationView();
        setCollectionView();
        setToolBar();
    }
    
    func setConfig() {
        imageManager.stopCachingImagesForAllAssets();
        previousPreheatRect = .zero
        PHPhotoLibrary.shared().register(self)
        if fetchResult == nil {
            let options = PHFetchOptions();
            options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue);
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)];
            fetchResult = PHAsset.fetchAssets(with: options);
        }
    }
    
    func setNavigationView() {
        
        self.navigationController?.navigationBar.isHidden = true;
        let navigationView = UIView();
        navigationView.frame = CGRect(x: 0, y: 0, width: BrowserConst.kScreenWidth, height: BrowserConst.kNavigationBarHeight);
        navigationView.backgroundColor = BrowserConst.bgColor;
        view.addSubview(navigationView);
        
        let titleLabel = UILabel();
        titleLabel.frame = CGRect(x: BrowserConst.kScreenWidth/2 - 50, y: BrowserConst.kStatusBarHeight, width: 100, height: BrowserConst.kNavigationBarHeight - BrowserConst.kStatusBarHeight);
        titleLabel.textColor = BrowserConst.titleColor;
        titleLabel.textAlignment = .center;
        titleLabel.font = BrowserConst.titleFont;
        titleLabel.text = Bundle.localizeString(with: "ALL_PHOTOS");
        navigationView.addSubview(titleLabel);
        
        let cancelBtn = UIButton();
        cancelBtn.frame = CGRect(x: BrowserConst.kScreenWidth - 58, y: BrowserConst.kStatusBarHeight, width: 50, height: BrowserConst.kNavigationBarHeight - BrowserConst.kStatusBarHeight)
        cancelBtn.addTarget(self, action: #selector(dismissAction), for: .touchUpInside);
        cancelBtn.setTitle(Bundle.localizeString(with: "CANCEL"), for: .normal);
        cancelBtn.titleLabel?.font = BrowserConst.toolBtnFont;
        cancelBtn.setTitleColor(BrowserConst.lightTextBtnColor, for: .normal);
        navigationView.addSubview(cancelBtn);
        
        let separator = UIView();
        separator.frame = CGRect(x: 0, y: BrowserConst.kNavigationBarHeight - BrowserConst.separatorWidth, width: BrowserConst.kScreenWidth, height: BrowserConst.separatorWidth);
        separator.backgroundColor = BrowserConst.separatorColor;
        navigationView.addSubview(separator);
    }
    
    @objc func dismissAction() {
        self.navigationController?.dismiss(animated: true, completion: nil);
    }
    
    func setToolBar() {
        let toolBar = UIView();
        toolBar.frame = CGRect(x: 0, y: BrowserConst.kScreenHeight - BrowserConst.kBootomBarHeight, width: view.bounds.width, height: BrowserConst.kBootomBarHeight)
        toolBar.backgroundColor = BrowserConst.bgColor
        view.addSubview(toolBar)
        
        let previewBtn = UIButton();
        previewBtn.frame = CGRect(x: 12, y: 8.5, width: 52, height: 32);
        previewBtn.setTitleColor(BrowserConst.toolBtnColor, for: .normal);
        previewBtn.setTitle(Bundle.localizeString(with: "PREVIEW"), for: .normal);
        previewBtn.titleLabel?.font = BrowserConst.toolBtnFont;
        previewBtn.addTarget(self, action: #selector(previewAsset), for: .touchUpInside);
        toolBar.addSubview(previewBtn);
        
        let doneBtn = UIButton();
        doneBtn.frame = CGRect(x: BrowserConst.kScreenWidth - 67, y: 8.5, width: 52, height: 32);
        doneBtn.backgroundColor = BrowserConst.doneBtnColor;
        doneBtn.addTarget(self, action: #selector(selectCompleted), for: .touchUpInside);
        doneBtn.setTitle(Bundle.localizeString(with: "DONE"), for: .normal);
        doneBtn.titleLabel?.font = BrowserConst.toolBtnFont;
        doneBtn.setTitleColor(.white, for: .normal);
        doneBtn.layer.cornerRadius = 2;
        doneBtn.layer.masksToBounds = true;
        toolBar.addSubview(doneBtn);
    }
    
    @objc func previewAsset() {
        
        let browserVC = GFBrowserController();
        let assets = self.fetchResult.objects(at: selectIndexSet);
        guard let asset = assets.first else { return }
        browserVC.fetchResult = self.fetchResult;
        browserVC.asset = asset;
        browserVC.assets = assets;
        self.navigationController?.pushViewController(browserVC, animated: true);
    }
    
    @objc func selectCompleted() {
        
        let assets = self.fetchResult.objects(at: selectIndexSet)
        
        if let completion = completion {
            completion(assets)
        }
        
        if assets.isEmpty {
            NotificationCenter.default.post(name: BrowserConst.kSelectedNotification, object: nil, userInfo: [BrowserConst.kPHAssetsKey: []])
            self.navigationController?.dismiss(animated: true, completion: nil);
        }else{
            NotificationCenter.default.post(name: BrowserConst.kSelectedNotification, object: nil, userInfo: [BrowserConst.kPHAssetsKey: assets])
            self.navigationController?.dismiss(animated: true, completion: nil);
        }
    }
    
    func setCollectionView() {
        
        let availableWidth = BrowserConst.kScreenWidth - BrowserConst.lineCount * BrowserConst.interSpacing + BrowserConst.interSpacing - 2 * BrowserConst.gridContentInset.left;
        let itemLength = (availableWidth / BrowserConst.lineCount).rounded(.towardZero);
        itemSize = CGSize(width: itemLength, height: itemLength)
        
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
        view.backgroundColor = BrowserConst.bgColor;
        
        collectionViewFlowLayout = UICollectionViewFlowLayout();
        collectionViewFlowLayout.itemSize = itemSize;
        collectionViewFlowLayout.minimumLineSpacing = BrowserConst.lineSpacing;
        collectionViewFlowLayout.minimumInteritemSpacing = BrowserConst.interSpacing;
        collectionView = UICollectionView(frame: CGRect(x: 0, y: BrowserConst.kNavigationBarHeight, width: BrowserConst.kScreenWidth, height: BrowserConst.kScreenHeight - BrowserConst.kNavigationBarHeight - BrowserConst.kBootomBarHeight), collectionViewLayout: collectionViewFlowLayout);
        collectionView.contentInset = BrowserConst.gridContentInset;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = BrowserConst.collectionBgColor;
        view.addSubview(collectionView);
        collectionView.register(GFGridViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }

    // MARK: - UpdateAssets
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
}

extension GFAssetGridViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell
        let asset = fetchResult.object(at: indexPath.item);
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? GFGridViewCell
            else { fatalError("Unexpected cell in collection view") }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GFGridViewCell else { return }
        if cell.badgeImageView.image != nil {
            cell.badgeImageView.image = nil;
            selectIndexSet.remove(indexPath.item);
        }else{
            cell.badgeImageView.image = UIImage(named: "selected");
            selectIndexSet.insert(indexPath.item);
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension GFAssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
    if old.intersects(new) {
        var added = [CGRect]()
        if new.maxY > old.maxY {
            added += [CGRect(x: new.origin.x, y: old.maxY,
                             width: new.width, height: new.maxY - old.maxY)]
        }
        if old.minY > new.minY {
            added += [CGRect(x: new.origin.x, y: new.minY,
                             width: new.width, height: old.minY - new.minY)]
        }
        var removed = [CGRect]()
        if new.maxY < old.maxY {
            removed += [CGRect(x: new.origin.x, y: new.maxY,
                               width: new.width, height: old.maxY - new.maxY)]
        }
        if old.minY < new.minY {
            removed += [CGRect(x: new.origin.x, y: old.minY,
                               width: new.width, height: new.minY - old.minY)]
        }
        return (added, removed)
    } else {
        return ([new], [old])
    }
}
