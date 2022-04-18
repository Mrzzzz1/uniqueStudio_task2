//
//  chooseView.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/10.
//

import Foundation
import UIKit
class ChooseWayController: UIViewController {
    var delegate: SelectViewControllerDelegate?
    var backClosureforSuccess: (([UIImage]) -> Void)?
    var backClosureForFail: ((StopReason) -> Void)?
    var stopReason: StopReason?
    var collectionView: UICollectionView!
    var imageView = UIImageView()
    var firstTime: Bool = true
    var selectedImages: [UIImage] = []
    var onlyOneImage: UIImage?
    let imagePickercontroller = UIImagePickerController()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        setUpButton()
        if let delegate = delegate {
            if delegate.chooseOnlyOne {
                setUpimageView()
            } else {
                setUpCollectionView()
            }
        } else {
            setUpCollectionView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTime {
            firstTime = false
            showActionSheet()
        }
    }

    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width/3.2, height: view.frame.width/3)
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height-210), collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(FinalCell.self, forCellWithReuseIdentifier: "item")
    }

    func setUpimageView() {
        imageView = UIImageView(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height-210))
        view.addSubview(imageView)
    }

    func setUpButton() {
        let cancelButton = UIButton(frame: CGRect(x: 50, y: view.frame.height-120, width: 100, height: 50))
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        let doneButton = UIButton(frame: CGRect(x: view.frame.width-150, y: view.frame.height-120, width: 100, height: 50))
        doneButton.setTitle("确认", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        view.addSubview(doneButton)
        let moreButton = UIButton(frame: CGRect(x: view.frame.width-150, y: 0, width: 150, height: 60))
        view.addSubview(moreButton)
        if let delegate = delegate {
            if delegate.chooseOnlyOne {
                moreButton.setTitle("重新选择", for: .normal)
            } else {
                moreButton.setTitle("选择更多图片", for: .normal)
            }
        } else {
            moreButton.setTitle("选择更多图片", for: .normal)
        }
        
        moreButton.setTitleColor(.black, for: .normal)
        moreButton.addTarget(self, action: #selector(getMorePhotos), for: .touchUpInside)
    }
    
    @objc func cancel() {
        backClosureForFail?(StopReason.cancelWhileChoosePhoto)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func done() {
        if selectedImages.isEmpty, onlyOneImage == nil {
            backClosureForFail?(StopReason.chooseNoPhoto)
        } else {
            if let delegate = delegate {
                if delegate.chooseOnlyOne {
                    if let onlyOneImage = onlyOneImage {
                        let image: [UIImage] = [onlyOneImage]
                        backClosureforSuccess?(image)
                    }
                } else {
                    backClosureforSuccess?(selectedImages)
                }
            } else {
                backClosureforSuccess?(selectedImages)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @objc func getMorePhotos() {
        showActionSheet()
    }
    
    func showActionSheet() {
        let alertController = UIAlertController(title: "获取图片", message: .none, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let takeAction = UIAlertAction(title: "拍照", style: .default, handler: {
            _ in self.takePhoto()
        })
        let selectAction = UIAlertAction(title: "从手机相册中选择", style: .default, handler: {
            _ in self.selectFromAlbum()
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takeAction)
        alertController.addAction(selectAction)
        present(alertController, animated: true, completion: nil)
    }

    func takePhoto() {
        imagePickercontroller.allowsEditing = true
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            stopReason = .noCamera
            let errorAlert = UIAlertController(title: "相机不可用", message: .none, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                self.backClosureForFail?(.noCamera)
                self.dismiss(animated: true, completion: nil)
            })
            errorAlert.addAction(cancelAction)
            present(errorAlert, animated: true, completion: nil)
            return
        }
        imagePickercontroller.sourceType = .camera
        present(imagePickercontroller, animated: true, completion: nil)
    }
    
    func selectFromAlbum() {
        let selectViewController = SelectViewController()
        if let delegate = delegate {
            selectViewController.delegate = delegate
        }
        selectViewController.backClosureforSuccess = { (images: [UIImage]) in if let delegate = self.delegate {
            if delegate.chooseOnlyOne {
                self.onlyOneImage = images[0]
                self.imageView.image = self.onlyOneImage
//                print(self.imageView.image?.size)
            } else {
                for i in 0 ..< images.count {
                    self.selectedImages.append(images[i])
                    self.collectionView.reloadData()
                }
            }
        } else {
            for i in 0 ..< images.count {
                self.selectedImages.append(images[i])
                self.collectionView.reloadData()
            }
        }
        }
        selectViewController.backClosureForFail = {
            (reason: StopReason) in self.stopReason = reason
                if self.stopReason == .noAlbum {
                    self.backClosureForFail?(.noAlbum)
                    // self.dismiss(animated: true, completion: nil)
                }
        }
        present(selectViewController, animated: true, completion: nil)
    }
}

extension ChooseWayController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        stopReason = .cancelWhileTakePhotos
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePickercontroller.dismiss(animated: true, completion: nil)
        let cropViewController = CropViewController()
        if let image = image {
            cropViewController.setUp(image: image)
            cropViewController.backClosure1 = { (image: UIImage) in
                if let delegate = self.delegate {
                    if delegate.chooseOnlyOne == true {
                        self.onlyOneImage = image
                        self.imageView.image = image
                    } else {
                        self.selectedImages.append(image)
                        self.collectionView.reloadData()
                    }
                } else {
                    self.selectedImages.append(image)
                    self.collectionView.reloadData()
                }
            }
            //         cropViewController.backClosure2 = { (
            //
            //         }
            present(cropViewController, animated: true, completion: nil)
        }
    }
}

extension ChooseWayController: UICollectionViewDelegate, UICollectionViewDataSource, FinalCellDelegate {
    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! FinalCell
        cell.config(image: selectedImages[indexPath.item])
        cell.delegate = self
        cell.tag = indexPath.item
        return cell
    }
}
