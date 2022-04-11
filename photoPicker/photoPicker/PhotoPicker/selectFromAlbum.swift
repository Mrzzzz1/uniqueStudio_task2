//
//  selectFromAlbum.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/11.
//

import Foundation
import UIKit
class SelectViewController: UIViewController {
    var photosView=UICollectionView()
    override func viewDidLoad() {
        <#code#>
    }
    
}
extension SelectViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}
