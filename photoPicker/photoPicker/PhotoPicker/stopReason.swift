//
//  stopReason.swift
//  photoPicker
//
//  Created by 张金涛 on 2022/4/10.
//

import Foundation
enum StopReason {
    case cancelWhileChooseWay//用户在选择获取图片方式时取消
    case cancelWhileTakePhotos//用户在拍照时取消
    case cancelWhileChoosePhoto//用户在选择照片时取消
    case noCamera//未取得相机权限
    case cancelCrop//用户在裁剪时取消
    
}
