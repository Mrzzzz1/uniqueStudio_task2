//
//  ViewController.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/9.
//

import UIKit
class ViewController: UIViewController {
    //是否只需要一张图片
    var chooseOnlyOne=false
    //var chooseOnlyOne=true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        navigationController?.toolbar.tintColor = .black
        view.backgroundColor = .white
        //setUpButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "选择图片", style: .done, target: self, action: #selector(selectpt))
    }
    
    @objc func selectpt() {
        let choosewayController=ChooseWayController()
        choosewayController.delegate=self
        choosewayController.backClosureforSuccess = { (images:[UIImage]) in //使用获取的照片
            print("获得\(images.count)张图片")
        }
        choosewayController.backClosureForFail = { (reason:StopReason) in
            print("未获得图片原因：\(reason)")
        }
        navigationController?.pushViewController(choosewayController, animated: true)
    }

}

extension ViewController: SelectViewControllerDelegate{
    func judge(image: UIImage) -> Bool {
        //
        return true
    }
    func doWhilefalse() {
        print(false)
    }
    
    
}

