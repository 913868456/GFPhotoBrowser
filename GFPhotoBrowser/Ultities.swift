//
//  Ultities.swift
//  GFPhotoBrowser
//
//  Created by 防神 on 2019/2/2.
//  Copyright © 2019年 吃面多放葱. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices

enum GFResourceType {
    case local;
    case url
}

enum GFURLMediaType {
    case image(_ url: String);
    case video(_ url: String, _ thumbUrl: String)
}

extension PHAsset {
    
    var isGIF: Bool {
        let resource = PHAssetResource.assetResources(for: self).first!
        // 通过统一类型标识符(uniform type identifier) UTI 来判断
        let uti = resource.uniformTypeIdentifier as CFString
        return UTTypeConformsTo(uti, kUTTypeGIF)
    }
    
    var isGIFImage: Bool {
        let resource = PHAssetResource.assetResources(for: self).first!
        // 通过文件后缀名来判断是否是Gif
        let fileName = resource.originalFilename.lowercased()
        if fileName.hasSuffix(".gif") {
            return true
        }else {
            return false
        }
    }
}

extension Bundle {
    static func localizeString(with key: String) -> String {
        return NSLocalizedString(key, comment: "Error");
    }
}
