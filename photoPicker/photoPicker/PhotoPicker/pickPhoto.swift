//
//  chooseView.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/10.
//

import Foundation
import UIKit
class ChooseWayController: UIViewController {
    var stopReason: StopReason?
    var imageView = UIImageView()
    var firstTime: Bool = true
    let imagePickercontroller = UIImagePickerController()
    override func viewDidLoad() {
        self.view.backgroundColor = .white
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTime {
            firstTime = false
            showActionSheet()
        }
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
        self.present(alertController, animated: true, completion: nil)
        
    }
    func takePhoto() {
        //print("takePhoto")
        
        imagePickercontroller.delegate=self
        imagePickercontroller.allowsEditing = true
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            stopReason = .noCamera
            let errorAlert = UIAlertController(title:"相机不可用", message: .none, preferredStyle: .alert)
            let cancelAction=UIAlertAction(title: "取消", style: .cancel, handler: {
                _ in self.dismiss(animated: true, completion: nil)
            })
            errorAlert.addAction(cancelAction)
            self.present(errorAlert, animated: true, completion: nil)
            return
        }
        imagePickercontroller.sourceType = .camera
        self.present(imagePickercontroller, animated: true, completion: nil)
    }
    
    //用于crop Debug...
    func selectFromAlbum() {
        //print("selectFromAlbum")
//        imagePickercontroller.delegate = self
//        imagePickercontroller.allowsEditing = true
//        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
//            stopReason = .noCamera
//            let errorAlert = UIAlertController(title:"相册不可用", message: .none, preferredStyle: .alert)
//            let cancelAction=UIAlertAction(title: "取消", style: .cancel, handler: {
//                _ in self.dismiss(animated: true, completion: nil)
//            })
//            errorAlert.addAction(cancelAction)
//            self.present(errorAlert, animated: true, completion: nil)
//            return
//        }
//        imagePickercontroller.sourceType = .photoLibrary
//        self.present(imagePickercontroller, animated: true, completion: nil)
        let selectViewController = SelectViewController()
        present(selectViewController, animated: true, completion: nil)
        
    }
    //
}
extension ChooseWayController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true, completion: nil)
                self.stopReason = .cancelWhileTakePhotos
            }
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         imageView=UIImageView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height))
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
         self.imagePickercontroller.dismiss(animated: true, completion: nil)
         let cropViewController=CropViewController()
         cropViewController.setUp(image: self.imageView.image!)
         present(cropViewController, animated: true, completion: nil)
     }
}
