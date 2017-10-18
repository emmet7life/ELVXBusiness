//
//  ELApiConstant.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/17.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

let kAPiQueryPhone = "http://sj.apidata.cn/?mobile="

func queryPhoneApi(_ phoneNumber: String) -> String {
    return kAPiQueryPhone + phoneNumber
}
