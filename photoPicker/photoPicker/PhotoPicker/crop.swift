//
//  crop.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/9.
//

import Foundation
import UIKit
class CropViewController: UIViewController {
    var image: UIImage!
    var color1=UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    var color2=UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    var imageView=UIImageView()
    var newImage=UIImage()
    
    var cropRectView=UIScrollView()
    
    override func viewDidLoad() {
        self.view.backgroundColor = color1
    }
    func setUp(image:UIImage) {
        self.image=image;
        self.view.addSubview(cropRectView)
        
//        cropRectView.translatesAutoresizingMaskIntoConstraints=false
//        cropRectView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive=true
//        cropRectView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive=true
//        cropRectView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive=true
//        cropRectView.heightAnchor.constraint(equalTo: self.view.widthAnchor).isActive=true
        cropRectView.center=self.view.center
        cropRectView.frame.size=CGSize(width: self.view.frame.width, height: self.view.frame.width)
        cropRectView.maximumZoomScale=2
        cropRectView.minimumZoomScale=1
        cropRectView.contentSize=image.size
        cropRectView.addSubview(imageView)
        drawBorderLayer()
        imageView.image=image
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.centerXAnchor.constraint(equalTo: cropRectView.centerXAnchor).isActive=true
        imageView.centerYAnchor.constraint(equalTo: cropRectView.centerYAnchor).isActive=true
        
        if image.size.width<self.view.frame.width {
            imageView.widthAnchor.constraint(equalTo: cropRectView.widthAnchor).isActive=true
        }else {
            imageView.widthAnchor.constraint(equalTo: cropRectView.widthAnchor, constant: image.size.width-self.view.frame.width).isActive=true
        }
        
        if image.size.height<self.view.frame.width {
            imageView.heightAnchor.constraint(equalTo: cropRectView.heightAnchor).isActive=true
        } else {
            imageView.heightAnchor.constraint(equalTo: cropRectView.heightAnchor, constant: image.size.height-self.view.frame.width).isActive=true
        }
    }
    
    func setUpButton() {
        let cancelButton=UIButton(frame: CGRect(x: 50, y: self.view.frame.height-100, width: 100, height: 50))
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        let doneButton=UIButton(frame: CGRect(x: self.view.frame.width-150, y: self.view.frame.height-100, width: 100, height: 50))
        doneButton.setTitle("确认", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
    }
    @objc func cancel() {
         self.dismiss(animated: true, completion: nil)
        //回传信息
    }
    @objc func done() {
        cropImage()
        //回传裁剪后的照片
    }
    
    //画边框
    func drawBorderLayer() {
        let borderLayer =  CAShapeLayer()
                borderLayer.bounds = cropRectView.bounds
                
                borderLayer.position = CGPoint(x: cropRectView.bounds.midX, y: cropRectView.bounds.midY);
                borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: 2).cgPath
                borderLayer.lineWidth = 5 / UIScreen.main.scale
                borderLayer.lineDashPattern = [4,2] as [NSNumber]
                borderLayer.lineDashPhase = 0.1;
                borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
                cropRectView.layer.addSublayer(borderLayer)
                
       
    }
    func cropImage() {
        let cgImage=image.cgImage!
        let rect:CGRect=cropRectView.frame
        let newImage = cgImage.cropping(to: rect)!
        self.newImage=UIImage(cgImage: newImage)
        
    }
    
}

extension CropViewController:UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.view.backgroundColor=color2
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.view.backgroundColor=color1
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.backgroundColor=color2
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.backgroundColor=color1
    }
}


