//
//  selectFromAlbum.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/11.
//

import PhotosUI
//import Photos
import Foundation
import UIKit
class SelectViewController: UIViewController {
    //var photosView=UICollectionView()
    var stopReason:StopReason?
    override func viewDidLoad() {
        getPermission()
    }
        //获取相册权限
    func getPermission(){
//        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
//        debugPrint(status)
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                let sta: PHAuthorizationStatus = status as PHAuthorizationStatus
                switch sta {
                case .limited:
                    print("部分")
                case .authorized:
                    print("全部")
                default:
                    self.stopReason = .noAlbum
                }
                
            }
            
            
        }

    }
    //添加更多选中照片
    func getMorePhotos(){
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    func getphotos(){
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil) as? PHFetchResult
        let customAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil) as? PHFetchResult
        if(customAlbums==nil){
            //传错误信息
        }
        var assetCollection=[PHAssetCollection]()
        for i in 0..<customAlbums!.count{
            let collection = customAlbums![i]
            print("相册名称----\(collection.localizedTitle ?? "")")
            assetCollection.append(collection)
        }
        for i in 0..<assetCollection.count{
            let fetchResult = PHAsset.fetchAssets(in: assetCollection[i], options: nil) as? PHFetchResult

                    if (fetchResult?.count ?? 0) > 0 {
                        // 进行下一步操作，获取相册里面的内容
                    }
        }
        
        

    }
    
    
}
//extension SelectViewController: UICollectionViewDelegate,UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        //
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //
//    }
//
//
//}
