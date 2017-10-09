//
//  UIImage+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/26.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension UIImage {

    /// 生成一张纯色图片
    ///
    /// - Parameters:
    ///   - color: 图片颜色
    ///   - size: 图片大小，默认1*1
    /// - Returns: 图像
    class func image(from color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!;
    }
}
