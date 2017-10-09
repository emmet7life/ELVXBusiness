//
//  ELHelpers.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/27.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

internal func Init<Type>(_ type: Type, block: (_ type: Type) -> Void) -> Type {
    block(type)
    return type
}
