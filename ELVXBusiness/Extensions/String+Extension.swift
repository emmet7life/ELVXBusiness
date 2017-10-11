//
//  String+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/15.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension String {

    /// 进行url encode 编码
    var urlEncodeString: String {
        /// 来源 https://github.com/Alamofire/Alamofire/blob/master/Source/ParameterEncoding.swift
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        let escaped = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? self

        return escaped
    }

    /// 去掉首尾空格（包含首尾的换行字符）
    var trimString: String {
        let whitespace = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: whitespace)
    }

    /// 转成 UTF8 格式的字节数据
    var data: Data? {
        return self.data(using: String.Encoding.utf8)
    }

    /// 转成 base64 加密的字节数据
    var base64Encode: Data? {
        return Data(base64Encoded: self, options: [])
    }

    /// 计算固定宽度内，文本利用系统字体完全显示所需高度
    ///
    /// - Parameters:
    ///   - width: 指定的显示宽度
    ///   - systemFontSize: 系统字体大小
    /// - Returns: 完全展示所需高度
    func calculateHeightInWidth(_ width: CGFloat, systemFontSize: CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: systemFontSize)]
        let rect = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil)
        return rect.height
    }

    func calculateHeightInWidth(_ width: CGFloat, font: UIFont, lineSpacing: CGFloat? = nil) -> CGFloat {
        var attributes: [String: AnyObject] = [NSFontAttributeName: font]
        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            attributes[NSParagraphStyleAttributeName] = paragraphStyle
        }

        let rect = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil)
        return rect.height + 1
    }

    /// 计算固定高度内，文本利用系统字体完全显示所需宽度
    ///
    /// - Parameters:
    ///   - height: 指定的显示高度
    ///   - systemFontSize: 系统字体大小
    /// - Returns: 完全展示所需宽度
    func calculateWidthInHeight(_ height: CGFloat, systemFontSize: CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: systemFontSize)]
        let rect = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: attributes, context: nil)
        return rect.width
    }

    /// 对手机号码做遮盖处理（掩盖中间4位）
    ///
    /// - Returns: 如果是合法手机号，则掩盖，否则不处理
    func coverPhoneNumber() -> String {
        if ELVerificationUtils.isValidPhoneNumber(self) {
            let start = substring(to: index(startIndex, offsetBy: 3))
            let end = substring(from: index(startIndex, offsetBy: 7))
            return "\(start)****\(end)"
        }
        return self
    }

    func html2AttributedString(_ colorHex: String) -> NSAttributedString? {
        do {
            var data: Data
            if colorHex.isEmpty {
                data = Data(utf8)
            } else {
                let html = "<body style=\"color:\(colorHex);\">\(self)</body>"
                data = Data(html.utf8)
            }

            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("html attributed error: ", error.localizedDescription)
            return nil
        }
    }

    func numberFormat(float: Int = 2) -> String {
        if let num = Int(self) {
            return numberFormat(num: num, float: float)
        }
        return "0"
    }

    func numberFormat(num: Int, float: Int = 1) -> String {
        let formatFloat = max(0, float)

        var wan = CGFloat(num) / 100000000.0
        if wan >= 1.0 {
            let _wan = String(format: "%.\(formatFloat)f亿+", wan)
            return _wan
        } else {
            wan = CGFloat(num) / 10000.0
            if wan >= 1.0 {
                let _wan = String(format: "%.\(formatFloat)f万+", wan)
                return _wan
            }
            return String(num)
        }
    }

}
