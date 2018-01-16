//
//  PhotoController.swift
//  RollingBall
//
//  Created by JerryWang on 2017/7/11.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation
import Photos

class PhotoLibrary {
    
    fileprivate var imgManager: PHImageManager
    fileprivate var requestOptions: PHImageRequestOptions
    fileprivate var fetchOptions: PHFetchOptions
    fileprivate var fetchResult: PHFetchResult<PHAsset>
    
    init () {
        imgManager = PHImageManager.default()
        requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
    }
    
    var count: Int {
        return fetchResult.count
    }
    
    func setPhoto(at index: Int, completion block: @escaping (UIImage?)->()) {
        
        if fetchResult.count == 0 {return}
        
        if index < fetchResult.count  {
            imgManager.requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
                block(image)
            }
        } else {
            block(nil)
        }
    }
    
    func getAllPhotos() -> [UIImage] {
        
        var resultArray = [UIImage]()
        for index in 0..<fetchResult.count {
            imgManager.requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
                
                if let image = image {
                    resultArray.append(image)
                }
            }
        }
        return resultArray
    }
}
