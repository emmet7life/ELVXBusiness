//
//  ELPhoneModel.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/13.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import SwiftyJSON
import FMDB

public struct ELPhone {

    let prefix: String
    let mobile: String

    let types: String?
    let isp: ELIsp
    let standard: ELStandard

    // 目前不细分城市信息
    let province: String// ELProvince
    let city: String// ELCity
    let areaCode: Int// ELAreaCode
    let zipCode: Int// ELZipCode

    /// 标识行是否被选中（默认选中全部）
    var isRowSelected = true

    init(_ json: JSON) {
        prefix = json["prefix"].stringValue
        mobile = json["mobile"].stringValue

        province = json["province"].stringValue
        city = json["city"].stringValue
        areaCode = json["code"].intValue
        zipCode = json["zipcode"].intValue

        isp = ELIsp(rawValue: json["isp"].stringValue) ?? .unknown
        let _types = json["types"].stringValue
        types = _types
        if _types.contains("4g")
            || _types.contains("4G")
            || _types.contains("LTE")
            || _types.contains("FDD") {
            standard = .standard4G
        } else if _types.contains("3g")
            || _types.contains("3G")
            || _types.contains("WCDMA")
            || _types.contains("SCDMA")
            || _types.contains("CDMA2000") {
            standard = .standard3G
        } else {
            standard = .standard2G
        }
    }

    init(_ set: FMResultSet) {
        prefix = ""
        types = nil
        mobile = set.string(forColumn: kPhonesTableColumnMobile) ?? ""
        isp = ELIsp(rawValue: set.string(forColumn: kPhonesTableColumnIsp) ?? "") ?? .unknown
        standard = ELStandard(rawValue: Int(set.int(forColumn: kPhonesTableColumnStandard))) ?? .standard2G
        province = set.string(forColumn: kPhonesTableColumnProvince) ?? ""
        city = set.string(forColumn: kPhonesTableColumnCity) ?? ""
        areaCode = Int(set.int(forColumn: kPhonesTableColumnAreaCode))
        zipCode = Int(set.int(forColumn: kPhonesTableColumnZipCode))
    }

    var debugDescription: String {
        return "\(isp.rawValue), \(city), \(mobile)"
    }

    var description: String {
        return "地   区：\(province),\(city)\n" + "网络制式：\(types ?? "")"
    }

}

public enum ELPhonePrefix: String {
    case m139 = "139"
    case m138 = "138"
    case m137 = "137"
    case m136 = "136"
    case m135 = "135"
    case m134 = "134"
    case m178 = "178"
    case m170 = "170"
    case m188 = "188"
    case m187 = "187"
    case m183 = "183"
    case m182 = "182"
    case m159 = "159"
    case m158 = "158"
    case m157 = "157"
    case m152 = "152"
    case m150 = "150"
    case m147 = "147"
    case m186 = "186"
    case m185 = "185"
    case m156 = "156"
    case m155 = "155"
    case m130 = "130"
    case m131 = "131"
    case m132 = "132"
    case m189 = "189"
    case m180 = "180"
    case m153 = "153"
    case m133 = "133"
}

public enum ELPhoneMedium: String {
    case AAAA
    case AAAB
    case BAAA
    case AABB
    case ABAB
    case ABCD
}

public enum ELPhoneSuffix: String {
    case AAAAA
    case AAAA
    case AAA
    case AABBB
    case AAAAB
    case AAAB
    case AA
    case AABBCC
    case AABB
    case ABABAB
    case ABAB
    case ABCDABCD
    case ABCD
    case ABC
    case ABCABC
    case AABBCCx = "AABBCC*"
    case ABCABCx = "ABCABC*"
    case ABABABx = "ABABAB*"
    case ABCxxABC = "ABC**ABC"
    case xABCxABC = "*ABC*ABC"
}
