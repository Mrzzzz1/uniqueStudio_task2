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
protocol SelectViewControllerDelegate {
    func judge(image: UIImage) -> Bool
    var chooseOnlyOne: Bool { get }
    func doWhilefalse()
}

class SelectViewController: UIViewController {
    //let doneButton=UIBarButtonItem(title: "确认", style: .done, target: self, action: #selector(done))
    var delegate: SelectViewControllerDelegate?
    var titlebButton = UIButton()
    var backClosureforSuccess: (([UIImage]) -> Void)?
    var backClosureForFail: ((StopReason) -> Void)?
    var newImage: UIImage?
    var selectedImage: [UIImage] = []
    var flags: [Int] = []
    var stopReason: StopReason?
    var collectionView: UICollectionView!
    var indexNow = 0
    var topLevelUserCollections = PHFetchResult<PHCollection>()
    var allAssets = PHFetchResult<PHAsset>()
    let label = UILabel()
    override func viewDidLoad() {
        PHPhotoLibrary.shared().register(self)
        navigationController?.setToolbarHidden(false, animated: true)
        view.backgroundColor = .white
        getPermission()
        getphotos()
        setUpCollectionView()
        setUpLabel()
        setUpButton()
        let leftButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = leftButton
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
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width/3.05, height: view.frame.width/3)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 120, width: view.frame.width, height: view.frame.height-220), collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "itemed")
    }

    func setUpLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.text = "无可用图片"
        label.preferredMaxLayoutWidth = view.frame.width*0.9
        label.numberOfLines = 2
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        label.font = UIFont.boldSystemFont(ofSize: 30)
    }

    func setUpButton() {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized {
            navigationController?.toolbar.isHidden = true
        }
        titlebButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        titlebButton.setTitle("最近图片", for: .normal)
        titlebButton.setTitleColor(.black, for: .normal)
        titlebButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        titlebButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        titlebButton.layer.cornerRadius = 16
        navigationItem.titleView = titlebButton
        let doneButton=UIBarButtonItem(title: "确认", style: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem=doneButton
        doneButton.isEnabled=false
        doneButton.tintColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        if let delegate = delegate {
            if delegate.chooseOnlyOne == true {
                navigationItem.rightBarButtonItem?.title = ""
                navigationItem.rightBarButtonItem?.action = nil
            }
        }
        let moreButton = UIBarButtonItem(title: "获取更多图片", style: .done, target: self, action: #selector(getMorePhotos))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: "barButtonItemClicked:", action: nil)
        setToolbarItems([flexibleSpace, moreButton, flexibleSpace], animated: true)
    }

    @objc func cancel() {
        backClosureForFail?(StopReason.cancelWhileChoosePhoto)
        navigationController?.popViewController(animated: true)
        navigationController?.toolbar.isHidden = false
    }

    @objc func done() {
            backClosureforSuccess?(selectedImage)
        navigationController?.popViewController(animated: true)
        navigationController?.toolbar.isHidden = false
    }

    @objc func clickButton() {
        debugPrint("点击按钮")
        showActionSheet()
    }

    @objc func showActionSheet() {
        let alertController = UIAlertController(title: "文件夹", message: .none, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "最近项目", style: .default, handler: { _ in
            if self.indexNow != 0 {
                self.indexNow = 0
                self.collectionView.reloadData()
                self.titlebButton.setTitle("最近项目", for: .normal)
            }

        })
        alertController.addAction(action)
        for i in 0..<topLevelUserCollections.count {
            let action = UIAlertAction(title: topLevelUserCollections.object(at: i).localizedTitle, style: .default, handler: { _ in
                if self.indexNow != i+1 {
                    self.indexNow = i+1
                    self.collectionView.reloadData()
                    self.titlebButton.setTitle(self.topLevelUserCollections.object(at: i).localizedTitle, for: .normal)
                }
            })
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}

extension SelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewCellDelegate {
    func addSelectedImage(image: UIImage, tag: Int) -> Bool {
        if let delegate = delegate {
            if delegate.chooseOnlyOne {
                if delegate.judge(image: image) {
                    selectedImage.append(image)
                    flags.append(tag)
                    done()
                    return true
                } else {
                    delegate.doWhilefalse()
                    return false
                }
            } else {
                if delegate.judge(image: image) {
                    navigationItem.rightBarButtonItem?.isEnabled=true
                    navigationItem.rightBarButtonItem?.tintColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                    selectedImage.append(image)
                    flags.append(tag)
                    return true
                } else {
                    delegate.doWhilefalse()
                    return false
                }
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled=true
            navigationItem.rightBarButtonItem?.tintColor=UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            selectedImage.append(image)
            flags.append(tag)
            return true
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
        if(selectedImage.isEmpty) {
            navigationItem.rightBarButtonItem?.isEnabled=false
            navigationItem.rightBarButtonItem?.tintColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
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
            // cell.click()
        }
        navigationController?.pushViewController(cropViewController, animated: true)
        navigationController?.toolbar.isHidden = false
        navigationController?.toolbar.tintColor = .white
        navigationController?.toolbar.barTintColor = .black
        navigationController?.navigationBar.isHidden = true
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if indexNow == 0 {
            if allAssets.count == 0 {
                label.isHidden = false
            } else {
                label.isHidden = true
            }
            return allAssets.count
        } else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections.object(at: indexNow-1) as! PHAssetCollection, options: nil)
            if assetsFetchResults.count == 0 {
                label.isHidden = false
            } else {
                label.isHidden = true
            }
            return assetsFetchResults.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemed", for: indexPath) as! CollectionViewCell
        let imageManager = PHCachingImageManager()
          if indexNow == 0 {
//            imageManager.requestImageDataAndOrientation(for: allAssets[indexPath.item], options: nil, resultHandler: {Date,_,_,_  in
//                if let Date = Date {
//                    if  let image=UIImage(data: Date){
//                        cell.config(image: image)
//                        cell.delegate = self
//                        cell.tag = self.indexNow*10+indexPath.item
//                    }
//                }
//            })
            imageManager.requestImage(
                for: allAssets[indexPath.item],
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { result, _ in
                    if let im = result {
                        cell.config(image: im)
                        cell.backgroundColor = .red
                        cell.delegate = self
                        cell.tag = self.indexNow*10+indexPath.item
                    }
                })
        } else {
            let assetsFetchResults: PHFetchResult = PHAsset.fetchAssets(in: topLevelUserCollections.object(at: indexNow-1) as! PHAssetCollection, options: nil)
            imageManager.requestImage(
                for: assetsFetchResults[indexPath.item],
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFill,
                options: nil,
                resultHandler: { result, _ in
                    if let im = result {
                        cell.tag = self.indexNow*10+indexPath.item
                        cell.config(image: im)
                        cell.delegate = self
                    }
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
                self.navigationController?.toolbar.isHidden = true
            } else {
                self.navigationController?.toolbar.isHidden = false
            }
        }
    }
}
