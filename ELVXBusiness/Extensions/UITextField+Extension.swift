//
//  UITextField+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/17.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

extension UITextField {

    /// 限定长度内是否能继续输入
    ///（用于 UITextFieldDelegate 的textField(_:, shouldChangeCharactersInRange:, replacementString: ) 方法）
    ///
    /// - Parameters:
    ///   - limit: 限定的字符个数
    ///   - range: range
    ///   - string: string
    /// - Returns: 返回 true 表示可以输入
    func shouldInputWithLimit(_ limit: Int, range: NSRange, string: String) -> Bool {
        let text:NSMutableString = self.text!.mutableCopy() as! NSMutableString
        text.replaceCharacters(in: range, with: string)
        return text.length <= limit
    }

}
