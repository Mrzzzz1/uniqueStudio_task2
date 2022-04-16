//
//  finalcell.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/16.
//

import Foundation
import UIKit
protocol FinalCellDelegate{
    func removeImage(at index:Int)
}
class FinalCell: UICollectionViewCell {
    var delegate: FinalCellDelegate? = nil
    var imageView: UIImageView! = UIImageView()
    var sellectButton = UIButton()
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
        sellectButton.setTitle("X", for: .normal)
        sellectButton.setTitleColor(.white, for: .normal)
        sellectButton.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        
    }
    @objc func click(){
        delegate?.removeImage(at: self.tag)
    }
    
    

}

