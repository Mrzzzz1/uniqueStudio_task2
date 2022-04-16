//
//  selectFromAlbum.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/11.
//
// import Photos
import Foundation
import PhotosUI
import UIKit
class SelectViewController: UIViewController {
    var minSize: CGSize?
    var maxSize: CGSize?
    var moreButton: UIButton!
    var backClosureforSuccess: (([UIImage]) -> Void)?
    var backClosureForFail: ((StopReason) -> Void)?
    var success: Int! = 0
    var newImage: UIImage?
    var titleLabel: UILabel!
    var selectedImage: [UIImage] = []
    var flags: [Int] = []
    var stopReason: StopReason?
    var collectionView: UICollectionView!
    var indexNow = 0
    var topLevelUserCollections = PHFetchResult<PHCollection>()
    var allAssets = PHFetchResult<PHAsset>()
    override func viewDidLoad() {
        PHPhotoLibrary.shared().register(self)
        view.backgroundColor = .white
        getPermission()
        getphotos()
        setUpCollectionView()
        setUpLabel()
        setUpButton()
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // 获取相册权限
    func getPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                let sta: PHAuthorizationStatus = status as PHAuthorizationStatus
                switch sta {
                case .limited:
                    print("部分")
                case .authorized:
                    print("全部")
                default:
                    self.dismiss(animated: true, completion: nil)
                    self.backClosureForFail?(StopReason.noAlbum)
                }
            }
        }
    }

    // 添加更多选中照片
    @objc func getMorePhotos() {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }

    func getphotos() {
        topLevelUserCollections = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        print("topLevelUserCollectionsCount\(topLevelUserCollections.count)")
        let fetchOptions = PHFetchOptions()
        // 设定排序规则
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allAssets = PHAsset.fetchAssets(with: fetchOptions)
    }

    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width/3.2, height: view.frame.width/3)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height-150), collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "itemed")
    }

    func setUpLabel() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        titleLabel.text = "最近项目>"
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(titleLabel)
    }
    
    func setUpButton() {
        // 切换相册
        let button = UIButton(frame: titleLabel.frame)
        view.addSubview(button)
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        // 从相册选择更多照片
        moreButton = UIButton(frame: CGRect(x: view.frame.width-100, y: 0, width: 100, height: 60))
        view.addSubview(moreButton)
        moreButton.setTitle("更多图片", for: .normal)
        moreButton.setTitleColor(.black, for: .normal)
        moreButton.addTarget(self, action: #selector(getMorePhotos), for: .touchUpInside)
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            moreButton.isHidden = true
        }
        // 取消
        let cancelButton = UIButton(frame: CGRect(x: 50, y: view.frame.height-150, width: 100, height: 50))
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        // 确认
        let doneButton = UIButton(frame: CGRect(x: view.frame.width-150, y: view.frame.height-150, width: 100, height: 50))
        doneButton.setTitle("确认", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        view.addSubview(doneButton)
    }

    @objc func cancel() {
        backClosureForFail?(StopReason.cancelWhileChoosePhoto)
        dismiss(animated: true, completion: nil)
    }

    @objc func done() {
        if selectedImage.isEmpty {
            backClosureForFail?(StopReason.chooseNoPhoto)
        } else {
            backClosureforSuccess?(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }

    @objc func clickButton() {
        debugPrint("点击按钮")
        showActionSheet()
    }

    func showActionSheet() {
        let alertController = UIAlertController(title: "文件夹", message: .none, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "最近项目", style: .default, handler: { _ in
            if self.indexNow != 0 {
                self.indexNow = 0
                self.collectionView.reloadData()
                self.titleLabel.text = "最近项目>"
            }
            
        })
        alertController.addAction(action)
        for i in 0..<topLevelUserCollections.count {
            let action = UIAlertAction(title: topLevelUserCollections.object(at: i).localizedTitle, style: .default, handler: { _ in
                if self.indexNow != i+1 {
                    self.indexNow = i+1
                    self.collectionView.reloadData()
                    self.titleLabel.text = self.topLevelUserCollections.object(at: i).localizedTitle ?? ""+">"
                }
            })
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}

extension SelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewCellDelegate {
    func judgeMin(image:UIImage)->Bool{
        if let size=self.minSize{
            if image.size.width>=size.width&&image.size.height>=size.height {
                return true
            } else {
                return false
            }
        }else {
            return true
        }
    }
    func judgeMax(image:UIImage)->Bool{
        if let size=self.maxSize{
            if image.size.width<=size.width&&image.size.height<=size.height {
                return true
            } else {
                return false
            }
        }else {
            return true
        }
        
    }
    func addSelectedImage(image: UIImage, tag: Int)->Bool {
        if judgeMax(image: image)&&judgeMin(image: image){
            selectedImage.append(image)
            flags.append(tag)
            return true
            }
        else {
            let errorAlert = UIAlertController(title: "图片不合格", message: .none, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler:nil)
            errorAlert.addAction(cancelAction)
            present(errorAlert, animated: true, completion: nil)
            return false
        }
        
    }
    
    func removeSelectedImage(tag: Int) {
        for i in 0..<flags.count {
            if flags[i] == tag {
                selectedImage.remove(at: i)
                flags.remove(at: i)
                break
            }
        }
    }
    
    func crop(image: UIImage, index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        let cropViewController = CropViewController()
        cropViewController.setUp(image: image)
        cropViewController.backClosure1 = { (image: UIImage) in
            self.newImage = image
            cell.imageView.image = image
        }
        cropViewController.backClosure2 = { (success: Int) in
            self.success = success
        }
        present(cropViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if indexNow == 0 {
            return allAssets.count
        } else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections.object(at: indexNow-1) as! PHAssetCollection, options: nil)
            return assetsFetchResults.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemed", for: indexPath) as! CollectionViewCell
        let imageManager = PHCachingImageManager()
        if indexNow == 0 {
            imageManager.requestImage(
                for: allAssets[indexPath.item],
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { result, _ in
                    cell.config(image: result!)
                    cell.delegate = self
                    cell.tag = self.indexNow*10+indexPath.item
                })
        } else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections.object(at: indexNow-1) as! PHAssetCollection, options: nil)
            imageManager.requestImage(
                for: assetsFetchResults[indexPath.item],
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { result, _ in
                    cell.config(image: result!)
                    cell.delegate = self
                    cell.tag = self.indexNow*10+indexPath.item
                })
        }
        return cell
    }
}

extension SelectViewController: PHPhotoLibraryChangeObserver {
    // 当照片库发生变化的时候会触发
    func photoLibraryDidChange(_ change: PHChange) {
        print("change")
        // 获取照片
        getphotos()
        // 更新UI
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.selectedImage.removeAll()
            self.flags.removeAll()
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
                self.moreButton.isHidden = true
            } else {
                self.moreButton.isHidden = false
            }
        }
    }
}
