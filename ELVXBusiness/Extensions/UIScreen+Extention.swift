//
//  UIScreen+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/26.
//  Copyright © 2017年 Gookee. All rights reserved.
//

import UIKit

extension UIScreen {

    static var isPhoneX: Bool {
        let sizeInPixel = UIScreen.main.sizeInPixel
        return (sizeInPixel.width == 1125.0 && sizeInPixel.height == 2436.0)
    }

    // 6+
    static var isPhoneUp6Plus: Bool {
        return UIScreen.main.bounds.width >= 414
    }

    // 6
    static var isPhone6: Bool {
        return UIScreen.main.bounds.width == 375
    }

    // 320 3GS 4(s) 5c 5(s)
    static var isPhoneDown5Plus: Bool {
        return UIScreen.main.bounds.width < 375
    }
}
