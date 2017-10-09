//
//  String+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/15.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension String {

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

}
