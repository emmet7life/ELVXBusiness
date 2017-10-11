//
//  ELVerificationUtils.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/11.
//  Copyright © 2017年 emmet7life. All rights reserved.
//
import Foundation

/// 正则表达式匹配
///
/// - Parameters:
///   - regex: 正则表达式规则
///   - testText: 带校验的字符串
/// - Returns: 返回 true 表示校验通过
private func regexTest(regexText regex: String, testText: String) -> Bool {
    let regexTest = NSPredicate(format: "SELF MATCHES %@", regex)
    return regexTest.evaluate(with: testText)
}

/// 全国省份代码
private let kVCIdCardProvinceCode = [
    /** 11:"北京",12:"天津",13:"河北",14:"山西",15:"内蒙古" */
    "11", "12", "13", "14", "15",
    /** 21:"辽宁",22:"吉林",23:"黑龙江" */
    "21", "22", "23",
    /** 31:"上海",32:"江苏",33:"浙江",34:"安徽",35:"福建",36:"江西",37:"山东" */
    "31", "32", "33", "34", "35", "36", "37",
    /** 41:"河南",42:"湖北",43:"湖南",44:"广东",45:"广西",46:"海南" */
    "41", "42", "43", "44", "45", "46",
    /** 50:"重庆",51:"四川",52:"贵州",53:"云南",54:"西藏" */
    "50", "51", "52", "53", "54",
    /** 61:"陕西",62:"甘肃",63:"青海",64:"宁夏",65:"新疆" */
    "61", "62", "63", "64", "65",
    /** 71:"台湾",81:"香港",82:"澳门",91:"国外" */
    "71", "81", "82", "91"]

/// 18位身份证最后的校验位
private let kVCPIdCardValidationCodes = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]

/// 校验类工具
struct ELVerificationUtils {

    /// 手机号码校验
    ///
    /// - Parameter phoneNumber: 手机号
    /// - Returns: 返回 true 表示是正确的手机号
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let regex = "^(13[0-9]|14[0-9]|15[0-9]|17[0-9]|18[0-9])\\d{8}$"
        return regexTest(regexText: regex, testText: phoneNumber)
    }

    /// 全汉字校验
    ///
    /// - Parameter text: 待检测的字符串
    /// - Returns: 返回 true 表示该串全部由汉字组成
    static func isOnlyChinese(_ text: String) -> Bool {
        let regex = "^[\\u4e00-\\u9fa5]+$"
        return regexTest(regexText: regex, testText: text)
    }

    /// 是否是6位纯数字
    ///
    /// - Parameter numbers: 待检测的字符串
    /// - Returns: 返回 true 表示该串是6位纯数字
    static func isValidSixNumbers(_ numbers: String) -> Bool {
        // 6到20位数字字母的组合（不区分大小写）的正则为"^[a-zA-Z0-9]{6,20}$"
        let regex = "^[0-9]{6}$"
        return regexTest(regexText: regex, testText: numbers)
    }

    /// 邮箱地址校验
    ///
    /// - Parameter email: 邮箱地址
    /// - Returns: 返回 true 表示是有效的邮箱地址
    static func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        return regexTest(regexText: regex, testText: email)
    }

    /// 昵称校验（2-15个字符，支持中英文、数字、“_”或减号）
    ///
    /// - Parameter nickName: 昵称
    /// - Returns: 返回 true 表示是有效的昵称
    static func isValidNickName(_ nickName: String) -> Bool {
        let regex = "^[\\u4e00-\\u9fa5A-Za-z0-9_-]{2,15}$"
        return regexTest(regexText: regex, testText: nickName)
    }

    /// 密码校验
    static func isValidPassword(_ password: String) -> Bool {
        return password.characters.count >= 6 && password.characters.count <= 16
    }

    /// 验证码校验
    static func isValidVtyCode(_ numbers: String) -> Bool {
        let regex = "^[0-9]{4}$"
        return regexTest(regexText: regex, testText: numbers)
    }

    /// 身份证号码校验（15位与18位均可）
    ///
    /// - Parameter cardId: 身份证号码
    /// - Returns: 返回 true 表示合法身份证号
    static func isValidIdentityCardId(_ cardId: String) -> Bool {
        let cardRegex = "(^\\d{15}$)|(^\\d{17}([0-9]|X|x)$)"

        guard regexTest(regexText: cardRegex, testText: cardId) else {
            return false
        }

        // 验证省份
        let province = cardId.substring(to: cardId.index(cardId.startIndex, offsetBy: 2))
        if !kVCIdCardProvinceCode.contains(province) {
            return false
        }

        // 验证出生年月日
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd"

        if cardId.characters.count == 15 {
            var idStr = cardId.substring(from: cardId.characters.index(cardId.startIndex, offsetBy: 6))
            idStr = idStr.substring(to: idStr.characters.index(idStr.startIndex, offsetBy: 6))

            return dateFormat.date(from: "18\(idStr)") != nil || dateFormat.date(from: "19\(idStr)") != nil
        }

        // 验证出生年月日
        var idStr = cardId.substring(from: cardId.characters.index(cardId.startIndex, offsetBy: 6))
        idStr = idStr.substring(to: idStr.characters.index(idStr.startIndex, offsetBy: 8))
        guard dateFormat.date(from: idStr) != nil else {
            return false
        }

        // 验证校验码
        let weight = [7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2]
        let idNumber : NSString = cardId as NSString
        var sum = 0
        for i in 0 ..< 17 {
            let c : NSString = idNumber.substring(with: NSRange(location: i, length: 1)) as NSString
            sum += c.integerValue * weight[i]
        }

        let mod11 = sum % 11;
        if mod11 == 2 {
            return cardId.hasSuffix("x") || cardId.hasSuffix("X")
        }

        return cardId.hasSuffix(kVCPIdCardValidationCodes[mod11])
    }
}
