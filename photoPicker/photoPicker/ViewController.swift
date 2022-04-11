//
//  ViewController.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/9.
//

import UIKit

class ViewController: UIViewController {
    let button = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpButton()
    }

    func setUpButton() {
        view.addSubview(button)
        button.setTitle("选择图片", for: .normal)
        
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(self.chooseWay), for: .touchUpInside)
    }
    @objc func chooseWay() {
        let choosewayController=ChooseWayController()
        present(choosewayController, animated: true, completion: nil)
    }

}

