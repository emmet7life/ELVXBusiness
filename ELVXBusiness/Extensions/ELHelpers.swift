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

func delay(_ delta: Double, callFunc: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delta * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        callFunc()
    }
}

func async<T, N>(_ delta: Double, param: T, task: @escaping (_ value: T) -> N, callFunc: @escaping (_ result: N) -> ()) {
    func doTaskThenCallback() {
        let t = task(param)
        DispatchQueue.main.async(execute: {
            callFunc(t)
        })
    }

    if delta > 0.0 {
        DispatchQueue.global().asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delta * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            doTaskThenCallback()
        }
    } else {
        DispatchQueue.global().async {
            doTaskThenCallback()
        }
    }
}

func __devlog(_ items: Any...) {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        //模拟器
        print(items)
    #else
        // 真机
        if kAppIsDevEnv {
            print(items)
        }
    #endif
}
