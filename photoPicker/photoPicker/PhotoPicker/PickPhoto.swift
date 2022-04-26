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
    let label = UILabel()

    override func viewDidLoad() {
        navigationController?.setToolbarHidden(false, animated: true)
        view.backgroundColor = .white
        navigationController?.toolbar.isHidden = false
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
        setUpLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTime {
            firstTime = false
            showActionSheet()
        }
    }

    func setUpLabel() {
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.text = "请选择图片"
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        label.font = UIFont.boldSystemFont(ofSize: 30)
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
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }

    func setUpButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确认", style: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem?.isEnabled=false
        navigationItem.rightBarButtonItem?.tintColor=UIColor(white: 0, alpha: 0.5)
        let moreButton = UIBarButtonItem(title: "1", style: .done, target: self, action: #selector(getMorePhotos))
        if let delegate = delegate {
            if delegate.chooseOnlyOne {
                moreButton.title = "重新选择"
            } else {
                moreButton.title = "选择更多图片"
            }
        } else {
            moreButton.title = "选择更多图片"
        }
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: "barButtonItemClicked:", action: nil)
        setToolbarItems([flexibleSpace, moreButton, flexibleSpace], animated: true)
    }

    @objc func cancel() {
        backClosureForFail?(StopReason.cancelWhileChoosePhoto)
        navigationController?.popViewController(animated: true)
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
        navigationController?.popViewController(animated: true)
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
        selectViewController.backClosureforSuccess = { (images: [UIImage]) in self.label.isHidden = true
            self.navigationItem.rightBarButtonItem?.tintColor = .black
            self.navigationItem.rightBarButtonItem?.isEnabled=true
            if let delegate = self.delegate {
                if delegate.chooseOnlyOne {
                    self.onlyOneImage = images[0]
                    self.imageView.image = self.onlyOneImage
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
                }
        }
        navigationController?.pushViewController(selectViewController, animated: true)
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
                self.label.isHidden = true
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
            navigationController?.pushViewController(cropViewController, animated: true)
            navigationController?.toolbar.isHidden = false
            navigationController?.toolbar.tintColor = .white
            navigationController?.toolbar.barTintColor = .black
            navigationController?.navigationBar.isHidden = true
        }
    }
}

extension ChooseWayController: UICollectionViewDelegate, UICollectionViewDataSource, FinalCellDelegate {
    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
        collectionView.reloadData()
        if selectedImages.isEmpty {
            label.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled=false
            navigationItem.rightBarButtonItem?.tintColor=UIColor(white: 0, alpha: 0.5)
        }
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
