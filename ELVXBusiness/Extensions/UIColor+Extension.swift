//
//  UIColor+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/15.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension UIColor {

    class var mainColor: UIColor {
        return UIColor(hexString: "27B39F")!
    }

    class var subColor: UIColor {
        return UIColor(hexString: "686868")!
    }

    class var assitantColor: UIColor {
        return UIColor(hexString: "D8D8D8")!
    }

    class var sepLineColor: UIColor {
        return UIColor.colorWithHexRGBA(0xe5e5e5)
    }

    class var sepRectColor: UIColor {
        return UIColor.colorWithHexRGBA(0xf4f4f4)
    }

    class var viewBgColor: UIColor {
        return UIColor.white
    }
}

import UIKit

extension UIColor {

    /// 16进制颜色所含位数
    ///
    /// - HexBit3: 三位，不含 alpha 通道
    /// - HexBit4: 四位，含 alpha 通道
    /// - HexBit6: 六位，不含 alpha 通道
    /// - HexBit8: 八位，含 alpha 通道
    enum RGBAHexBitType {
        case hexBit3, hexBit4, hexBit6, hexBit8
    }

    /// 生成带 alpha 通道的 RBG 颜色（0~255），alpha限定为1.0
    ///
    /// - Parameters:
    ///   - red: R (0~255)
    ///   - green: G (0~255)
    ///   - blue: B (0~255)
    /// - Returns: 对应颜色对象
    class func colorWithRGB(_ red: UInt, _ green: UInt, _ blue: UInt) -> UIColor {
        return self.colorWithRGBA(red, green, blue, 255)
    }

    /// 生成带 alpha 通道的 RBG 颜色（0~255）
    ///
    /// - Parameters:
    ///   - red: R (0~255)
    ///   - green: G (0~255)
    ///   - blue: B (0~255)
    ///   - alpha: alpha 通道（0~255）
    /// - Returns: 对应颜色对象
    class func colorWithRGBA(_ red: UInt, _ green: UInt, _ blue: UInt, _ alpha: UInt) -> UIColor {
        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
        } else {
            return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha)/255.0)
        }
    }

    /// 16进制数值表示的颜色（可带 alpha 通道值）
    ///
    /// - Parameters:
    ///   - hexValue: 16进制无符号整数，(0x0 到 0xFFFFFFFF)
    ///   - bitType: 用来表示所含颜色的位数，参考: “ RGBAHexBitType ”
    /// - Returns: 对应颜色对象
    class func colorWithHexRGBA(_ hexValue: UInt64, bitType: RGBAHexBitType = .hexBit6) -> UIColor {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0

        switch (bitType) {
        case .hexBit3:
            red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
            green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
            blue  = CGFloat(hexValue & 0x00F)              / 15.0
        case .hexBit4:
            red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
            green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
            blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
            alpha = CGFloat(hexValue & 0x000F)             / 15.0
        case .hexBit6:
            red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
            green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
            blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        case .hexBit8:
            red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
            blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
            alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
        }

        if #available(iOS 10.0, *) {
            return UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    /// 将16进制数的字符串表示解析成对应颜色
    ///
    /// - Parameter hexString: 16进制数的字符串表示
    /// - Returns: 对应颜色对象
    class func colorRBGAFromHexString(_ hexString: String) -> UIColor? {
        var colorString = hexString.trimString.uppercased()
        if colorString.hasPrefix("#") {
            colorString = colorString.substring(from: colorString.characters.index(after: colorString.startIndex))
        } else if (colorString.hasPrefix("0X") || colorString.hasPrefix("0x")) {
            colorString = colorString.substring(from: colorString.characters.index(colorString.startIndex, offsetBy: 2))
        }

        let length = colorString.characters.count
        //         RGB            RGBA          RRGGBB        RRGGBBAA
        if (length != 3 && length != 4 && length != 6 && length != 8) {
            return nil
        }

        let scanner = Scanner(string: hexString)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanUnsignedLongLong(&hexValue) {
            switch (hexString.characters.count) {
            case 3:
                return self.colorWithHexRGBA(hexValue, bitType: .hexBit3)
            case 4:
                return self.colorWithHexRGBA(hexValue, bitType: .hexBit4)
            case 6:
                return self.colorWithHexRGBA(hexValue, bitType: .hexBit6)
            case 8:
                return self.colorWithHexRGBA(hexValue, bitType: .hexBit8)
            default:
                // Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8
                return nil
            }
        } else {
            // Scan hex error
            return nil
        }
    }
}
