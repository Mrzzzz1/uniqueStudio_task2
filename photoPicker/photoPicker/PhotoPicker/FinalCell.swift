//
//  finalcell.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/16.
//

import Foundation
import UIKit
protocol FinalCellDelegate {
    func removeImage(at index: Int)
}

class FinalCell: UICollectionViewCell {
    var delegate: FinalCellDelegate?
    var imageView: UIImageView! = UIImageView()
    var sellectButton = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(image: UIImage) {
        imageView.image = image
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        print(heightAnchor)
        imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        addSubview(sellectButton)
        sellectButton.translatesAutoresizingMaskIntoConstraints = false
        sellectButton.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        sellectButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 3).isActive = true
        sellectButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        sellectButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
        sellectButton.setTitle("X", for: .normal)
        sellectButton.setTitleColor(.white, for: .normal)
        sellectButton.addTarget(self, action: #selector(click), for: .touchUpInside)
    }

    @objc func click() {
        delegate?.removeImage(at: tag)
    }
}
