//
//  collectionViewCell.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/14.
//

import Foundation
import UIKit
protocol CollectionViewCellDelegate {
    func addSelectedImage(image: UIImage, tag: Int) -> Bool
    func crop(image: UIImage, index: Int)
    func removeSelectedImage(tag: Int)
    var flags: [Int] {get}
}

class CollectionViewCell: UICollectionViewCell {
    var flag = false
    var imageView: UIImageView! = UIImageView()
    private var startLocation = CGPoint()
    var sellectButton = UIButton()
    var delegate: CollectionViewCellDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(image: UIImage){
        imageView.image=image
        config1()
    }
    func config1() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        addSubview(sellectButton)
        sellectButton.translatesAutoresizingMaskIntoConstraints = false
        sellectButton.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        sellectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 3).isActive = true
        sellectButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        sellectButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
        sellectButton.setTitleColor(.white, for: .normal)
        sellectButton.setTitle("√", for: .normal)
        if let delegate = delegate {
            for i in 0..<delegate.flags.count{
                if tag==delegate.flags[i]{
                    sellectButton.setTitleColor(.blue, for: .normal)
                    flag=true
                }
            }
        }
        sellectButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    @objc func click() {
        if flag {
            sellectButton.setTitleColor(.white, for: .normal)
            delegate?.removeSelectedImage(tag: tag)
            flag = false
        } else {
            if delegate!.addSelectedImage(image: imageView.image!, tag: tag) {
                sellectButton.setTitleColor(.blue, for: .normal)
                flag = true
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startLocation = touch.preciseLocation(in: self)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let endLocation = touch.preciseLocation(in: self)
            if startLocation.x-endLocation.x < 5, startLocation.x-endLocation.x > -5, startLocation.y-endLocation.y < 5, startLocation.y-endLocation.y > -5 {
                delegate?.crop(image: imageView.image!, index: tag % 10)
            }
        }
    }
}
