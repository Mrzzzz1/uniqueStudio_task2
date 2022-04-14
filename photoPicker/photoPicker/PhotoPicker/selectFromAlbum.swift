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
    var selectedImage: [UIImage]?
    var flags: [Int] = [-1]
    var stopReason: StopReason?
    var collectionView: UICollectionView!
    var indexNow=0
    var topLevelUserCollections = PHFetchResult<PHCollection>()
    var allAssets=PHFetchResult<PHAsset>()
    override func viewDidLoad() {
        getPermission()
        getphotos()
        //setUpCollectionView()
    }
        //获取相册权限
    func getPermission() {
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
    func getMorePhotos() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    func getphotos() {
         topLevelUserCollections=PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        print("topLevelUserCollectionsCount\(topLevelUserCollections.count)")
        let fetchOptions = PHFetchOptions()
        // 设定排序规则
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
         allAssets = PHAsset.fetchAssets(with: fetchOptions)
        setUpCollectionView()
    }
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.width/3.2, height: self.view.frame.width/3)
        collectionView = UICollectionView(frame:CGRect(x: 0, y: 60, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
        self.view.addSubview(collectionView)
//        collectionView.translatesAutoresizingMaskIntoConstraints=false
//        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
//        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive=true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "itemed")
    }
    
    
}
extension SelectViewController: UICollectionViewDelegate,UICollectionViewDataSource,CollectionViewCellDelegate {
    func addSelectedImage(image: UIImage, tag: Int) {
        selectedImage?.append(image)
        flags.append(tag)
        print("flags\(flags.count)")
        for i in 0..<flags.count{
            print(flags[i])
        }
    }
    
    func removeSelectedImage(tag: Int) {
        for i in 0..<flags.count{
            if flags[i]==tag{
                selectedImage?.remove(at: i)
                flags.remove(at: i)
                break
            }
        }
    }
    
    
    
    func crop(image: UIImage) {
        let cropViewController = CropViewController()
        cropViewController.setUp(image: image)
        self.present(cropViewController, animated: true, completion: nil)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if indexNow==0{
            return allAssets.count
        }else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections[indexNow] as! PHAssetCollection, options: nil)
            return assetsFetchResults.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemed", for: indexPath) as! CollectionViewCell
        let imageManager = PHCachingImageManager()
        if indexNow==0 {
                imageManager.requestImage(
                    for: allAssets[indexPath.item],
                       targetSize:  PHImageManagerMaximumSize,
                       contentMode: .aspectFill,
                    options: nil,
                    resultHandler: { result, info in
                        cell.config(image: result!)
                        cell.delegate=self
                        cell.tag = self.indexNow*10+indexPath.item
                    })
        }else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections[indexNow] as! PHAssetCollection, options: nil)
            imageManager.requestImage(
                for: assetsFetchResults[indexPath.item],
                   targetSize:  PHImageManagerMaximumSize,
                   contentMode: .aspectFill,
                options: nil,
                resultHandler: { result, info in
                    cell.config(image: result!)
                    cell.delegate=self
                    cell.tag = self.indexNow*10+indexPath.item
                })
            
        }
        return cell
    }


}
