//
//  UIFont+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension UIFont {
    class func systemRegularFont(_ fontSize: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightRegular)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    class func systemLightFont(_ fontSize: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightLight)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    class func systemMediumFont(_ fontSize: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }

    class func systemSemiboldFont(_ fontSize: CGFloat) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightSemibold)
        } else {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
}
