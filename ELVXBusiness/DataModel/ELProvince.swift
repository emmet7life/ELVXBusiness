//
//  ELProvince.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/13.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

/// 省份
public enum ELProvince {
    // 未知
    case unknown

    // 4个直辖市
    case beijing
    case tianjin
    case shanghai
    case chongqing

    // 23个省
    case hebei              // 河北
    case shanxi1          // 山西
    case shanxi2          // 陕西
    case liaoning         // 辽宁
    case jilin                // 吉林
    case heilongjiang  // 黑龙江
    case gansu             // 甘肃
    case qinghai          // 青海
    case shandong       // 山东
    case anhui              // 安徽
    case jiangsu           // 江苏
    case zhejiang         // 浙江
    case henan             // 河南
    case hubei              // 湖北
    case hunan             // 湖南
    case jiangxi            // 江西
    case taiwan             // 台湾
    case fujian               // 福建
    case yunan              // 云南
    case hainan             // 海南
    case sichuan            // 四川
    case guizhou           // 贵州
    case guangdong      // 广东

    // 5个自治区
    case neimenggu    // 内蒙古
    case xinjiang         // 新疆
    case guangxi         // 广西
    case xizang           // 西藏
    case ningxia          // 宁夏

    // 2个特别行政区
    case xianggang     // 香港
    case aomen            // 澳门

    mutating func stringTo(_ str: String) {
       guard !str.isEmpty else {
            self = .unknown
            return
        }
        if str.contains("北京") {
            self = .beijing
        } else if str.contains("") {

        }
    }

}
