//
//  ELReqEnums.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/12.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import Alamofire

/// 接口数据响应状态
///
/// - success: 请求成功，收到数据
/// - timeOut: 请求超时
/// - failed: 请求失败
/// - cancelled: 请求被取消

enum ELNetResponseStatus: Equatable {

    // success关联值含义说明:
    // Bool表示返回的json中code等于0
    // Int表示返回的json中code的值
    // String表示返回的json中message的值
    case success(Bool, Int, String)
    case timeOut, failed
    case cancelled

    var message: String {
        switch self {
        case .success(let isSuccess, _, _):
            return isSuccess ? "请求成功" : "服务器错误"
        case .timeOut:
            return "网络请求超时"
        case .failed:
            return "网络请求错误"
        case .cancelled:
            return "已取消"
        }
    }

    static func ==(lhs: ELNetResponseStatus, rhs: ELNetResponseStatus) -> Bool {
        switch (lhs, rhs) {
        case (.success(let l1, let l2, let l3), .success(let r1, let r2, let r3)) where l1 == r1 && l2 == r2 && l3 == r3: return true
        case (.timeOut, .timeOut): return true
        case (.failed, .failed): return true
        case (.cancelled, .cancelled): return true
        default: return false
        }
    }
}

enum ELNetRequestMethod {
    case get, post

    var alamofireMethod: Alamofire.HTTPMethod {
        switch self {
        case .get:
            return Alamofire.HTTPMethod.get
        case .post:
            return Alamofire.HTTPMethod.post
        }
    }
}

enum ELNetworkStatus: Int, Equatable {
    case unknown = 0, notReachable, wwan, wifi

    var isReachable: Bool {
        switch self {
        case .wwan, .wifi:
            return true
        default:
            return false
        }
    }

    static func convertStatus(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) -> ELNetworkStatus {
        switch status {
        case .unknown:
            return .unknown
        case .notReachable:
            return .notReachable
        case .reachable(let type):
            switch type {
            case .ethernetOrWiFi:
                return .wifi
            case .wwan:
                return .wwan
            }
        }
    }

    static func ==(lhs: ELNetworkStatus, rhs: ELNetworkStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case (.notReachable, .notReachable): return true
        case (.wifi, .wifi): return true
        case (.wwan, .wwan): return true
        default: return false
        }
    }
}
