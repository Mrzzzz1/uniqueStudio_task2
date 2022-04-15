//
//  collectionViewCell.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/14.
//

import Foundation
import UIKit
protocol CollectionViewCellDelegate {
    //var newImage: UIImage? {get set}
    //var success: Int!{get set}
    //var success: Bool!{get set}
    func addSelectedImage(image: UIImage,tag :Int)
    func crop(image: UIImage,index: Int)
    func removeSelectedImage(tag: Int)
}
class CollectionViewCell: UICollectionViewCell {
    var flag = false
    var imageView: UIImageView! = UIImageView()
    private var startLocation = CGPoint()
    var sellectButton = UIButton()
    var delegate: CollectionViewCellDelegate? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func config(image: UIImage) {
        imageView.image = image
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        print(self.heightAnchor)
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.addSubview(sellectButton)
        sellectButton.translatesAutoresizingMaskIntoConstraints = false
        sellectButton.topAnchor.constraint(equalTo: self.topAnchor,constant: 3).isActive = true
        sellectButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 3).isActive = true
        sellectButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        sellectButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2).isActive = true
        sellectButton.setTitle("√", for: .normal)
        sellectButton.setTitleColor(.white, for: .normal)
        sellectButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        
    }
    @objc func click(){
        if(flag){
            sellectButton.setTitleColor(.white, for: .normal)
            delegate?.removeSelectedImage( tag: tag)
            flag=false
        }else{
            sellectButton.setTitleColor(.blue, for: .normal)
                    delegate?.addSelectedImage(image: imageView.image!,tag: tag)
            flag=true
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startLocation = touch.preciseLocation(in: self)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch=touches.first { 
            let endLocation = touch.preciseLocation(in: self)
            if(startLocation.x-endLocation.x < 5 && startLocation.x-endLocation.x > -5 && startLocation.y-endLocation.y < 5 && startLocation.y-endLocation.y > -5){
                delegate?.crop(image: self.imageView.image!,index: self.tag%10)
            }
        }
    }
    

}
