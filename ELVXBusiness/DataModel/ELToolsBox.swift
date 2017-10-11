//
//  ELToolsBox.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

enum ELToolsBoxType {
    case queryPhone // 查询手机
    case addFunc       // 添加功能

    var icon: String {
        switch self {
        case .queryPhone: return "toolbox_phone"
        case .addFunc: return "toolbox_add"
        }
    }

    var title: String {
        switch self {
        case .queryPhone: return "查手机号"
        case .addFunc: return "添加功能"
        }
    }
}
