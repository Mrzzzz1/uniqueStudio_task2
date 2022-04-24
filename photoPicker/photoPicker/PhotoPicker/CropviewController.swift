//
//  crop.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/9.
//

import Foundation
import UIKit
class CropViewController: UIViewController {
    var upView = UIView()
    var lowView = UIView()
    var image: UIImage!
    var backClosure1: ((UIImage)->Void)?
    var color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    var color2 = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    var imageView = UIImageView()
    var newImage = UIImage()
    var cropRectView = UIScrollView()

    override func viewDidLoad() {
        view.backgroundColor = .black
    }

    func setUp(image: UIImage) {
        self.image = image
        // 裁剪框

        view.addSubview(cropRectView)
        cropRectView.frame.origin = CGPoint(x: 0, y: (view.frame.height-view.frame.width)/2)
        cropRectView.frame.size = CGSize(width: view.frame.width, height: view.frame.width)
        cropRectView.clipsToBounds = false
        cropRectView.maximumZoomScale = 2
        cropRectView.minimumZoomScale = 1
        cropRectView.addSubview(imageView)
        cropRectView.delegate = self

        drawBorderLayer()

        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: cropRectView.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: cropRectView.topAnchor).isActive = true
        if image.size.width > image.size.height {
            imageView.heightAnchor.constraint(equalTo: cropRectView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: cropRectView.widthAnchor, multiplier: image.size.width/image.size.height).isActive = true
            cropRectView.contentSize = CGSize(width: view.frame.width*image.size.width/image.size.height, height: view.frame.width)
            cropRectView.contentOffset.x = (cropRectView.contentSize.width-cropRectView.frame.width)/2
            print(cropRectView.contentSize.width)
            print(cropRectView.frame.width)
        }
        else {
            imageView.widthAnchor.constraint(equalTo: cropRectView.widthAnchor).isActive = true
            imageView.heightAnchor.constraint(equalTo: cropRectView.heightAnchor, multiplier: image.size.height/image.size.width).isActive = true
            cropRectView.contentSize = CGSize(width: view.frame.width, height: view.frame.width*image.size.height/image.size.width)
            cropRectView.contentOffset.y = (view.frame.width*image.size.height/image.size.width-cropRectView.frame.width)/2
        }

        upView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.height-view.frame.width)/2))
        upView.backgroundColor = color1
        lowView = UIView(frame: CGRect(x: 0, y: (view.frame.height + view.frame.width)/2, width: view.frame.width, height: (view.frame.height-view.frame.width)/2))
        lowView.backgroundColor = color1
        view.addSubview(upView)
        view.addSubview(lowView)

        setUpButton()
    }

    func setUpButton() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.toolbar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.toolbar.barTintColor = .black
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.toolbar.isHidden = false
        let cancelButton = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancel))
        let doneButton = UIBarButtonItem(title: "确认", style: .done, target: self, action: #selector(done))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: "barButtonItemClicked:", action: nil)
        setToolbarItems([cancelButton, flexibleSpace, doneButton], animated: true)
    }

    @objc func cancel() {
        navigationController?.toolbar.barTintColor = .white
        navigationController?.toolbar.tintColor = .black
        navigationController?.navigationBar.isHidden = false
        navigationController?.popViewController(animated: false)
    }

    @objc func done() {
        cropImage()
        backClosure1?(newImage)
        navigationController?.toolbar.barTintColor = .white
        navigationController?.toolbar.tintColor = .black
        navigationController?.navigationBar.isHidden = false
        navigationController?.popViewController(animated: false)
    }

    // 画边框
    func drawBorderLayer() {
        let borderLayer = CAShapeLayer()
        borderLayer.bounds = cropRectView.bounds

        borderLayer.position = view.layer.position
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: 2).cgPath
        borderLayer.lineWidth = 5/UIScreen.main.scale
        borderLayer.lineDashPattern = [4, 2] as [NSNumber]
        borderLayer.lineDashPhase = 0.1
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        view.layer.addSublayer(borderLayer)
    }

    // 裁剪图片
    func cropImage() {
        image = image.fixOrientation()
        let cgImage = image.cgImage!
        let rect = CGRect(x: cropRectView.contentOffset.x*image.size.width/cropRectView.contentSize.width, y: cropRectView.contentOffset.y*image.size.height/cropRectView.contentSize.height, width: cropRectView.frame.width*image.size.width/cropRectView.contentSize.width, height: cropRectView.frame.height*image.size.height/cropRectView.contentSize.height)
        let newImage = cgImage.cropping(to: rect)!
        self.newImage = UIImage(cgImage: newImage)
        // Debug
        imageView.image = self.newImage
    }
}

extension CropViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView)->UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        upView.backgroundColor = color2
        lowView.backgroundColor = color2
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        upView.backgroundColor = color1
        lowView.backgroundColor = color1
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        upView.backgroundColor = color2
        lowView.backgroundColor = color2
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        upView.backgroundColor = color1
        lowView.backgroundColor = color1
    }
}

// 若不向上，旋转为向上，若为镜像，则翻转加旋转
extension UIImage {
    // 修复图片旋转
    func fixOrientation() ->UIImage {
        if imageOrientation == .up {
            return self
        }
        var transform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)

        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi/2)

        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi/2)

        default:
            break
        }

        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)

        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }

        let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0, space: cgImage!.colorSpace!, bitmapInfo: cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))

        default:
            ctx?.draw(cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
        }

        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)

        return img
    }
}
