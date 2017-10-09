//
//  File.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/12.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ELReqBaseManager: NSObject {

    static let shared = ELReqBaseManager()

    private(set) var networkStatus: ELNetworkStatus
    private let _networkReachibilityManager: NetworkReachabilityManager?

    private override init() {
        _networkReachibilityManager = NetworkReachabilityManager()
        if let networkReachibilityManager = _networkReachibilityManager {
            networkStatus = ELNetworkStatus.convertStatus(networkReachibilityManager.networkReachabilityStatus)
        } else {
            networkStatus = .unknown
        }
        super.init()
    }

    deinit {
        _networkReachibilityManager?.stopListening()
    }

    fileprivate(set) static var httpHeaders: HTTPHeaders = {
        var header = SessionManager.defaultHTTPHeaders
        return header
    }()

    fileprivate(set) static var httpConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 30
        configuration.httpAdditionalHeaders = httpHeaders
        return configuration
    }()

    // MARK: - Static
    static let sessionManager: SessionManager = {
        return SessionManager(configuration: httpConfiguration)
    }()

    static func encodeParamsInURL(_ url: String, params: [String: String]) -> String {
        if var components = URLComponents(string: url) {
            var queryItems = [URLQueryItem]()
            if let items = components.queryItems {
                queryItems.append(contentsOf: items.flatMap({ (item) -> URLQueryItem? in
                    if params.keys.contains(where: { $0 == item.name }) {
                        return nil
                    }
                    return item
                }))
            }

            queryItems.append(contentsOf: params.map({ (key, value) -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            }))
            components.queryItems = queryItems

            if let encodedURL = components.string {
                return encodedURL
            }
        }
        return url
    }

    static func fillCommonPostParams(with params: [String: Any]) -> [String: Any] {
        var fillParams = params
        // TODO
        fillParams["common"] = "common"
        return fillParams
    }

    static func parseResponseStatus(_ isSuccess: Bool, json: JSON, error: Error?) -> ELNetResponseStatus {
        if isSuccess {
            let status = json["status"].intValue
            let message = json["message"].stringValue

            return ELNetResponseStatus.success(status == 1, status, message)
        } else {
            if let err = error as NSError?, err.code == NSURLErrorCancelled {
                return .cancelled
            } else if let err = error as NSError?, err.code == NSURLErrorTimedOut {
                return .timeOut
            } else {
                return .failed
            }
        }
    }

    static func convertParamsToQueryString(_ request: URLRequest, _ params: [String: Any]) -> String {
        if let _request = try? URLEncoding.default.encode(request, with: params) {
            return _request.url?.absoluteString ?? request.url?.absoluteString ?? ""
        }
        return ""
    }

    // MARK: - Public Method
    func prepare() {
        startNetworkStatusListener()
        _ = ELReqBaseManager.sessionManager
    }

    fileprivate func startNetworkStatusListener() {
        _networkReachibilityManager?.listener = { [weak self] (status) in
            let prevStatus = self?.networkStatus
            self?.networkStatus = ELNetworkStatus.convertStatus(status)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNOTENetworkStatusChanged), object: prevStatus)
        }
    }

    // MARK: - Request
    @discardableResult
    static func request(_ request: URLRequestConvertible, callback: ((_ status: ELNetResponseStatus, _ json: JSON, _ request: URLRequest?, _ error: Error?) -> Void)? = nil) -> Request {
        return handleResponseJSON(request: sessionManager.request(request), callback: callback)
    }

    @discardableResult
    static func request(url: URLConvertible, method: ELNetRequestMethod, params: [String: Any]? = nil,
                        callback: ((_ status: ELNetResponseStatus, _ json: JSON, _ request: URLRequest?, _ error: Error?) -> Void)?) -> Request {
        var parameters = params
        if case .post = method {
            parameters = fillCommonPostParams(with: params ?? [:])
        }

        return handleResponseJSON(request: sessionManager.request(url, method: method.alamofireMethod, parameters: parameters), callback: callback)
    }

    @discardableResult
    fileprivate static func handleResponseJSON(request: DataRequest,
                                               callback: ((_ status: ELNetResponseStatus, _ json: JSON, _ request: URLRequest?, _ error: Error?) -> Void)?) -> DataRequest {
        return request.responseJSON{ response in
            var json = JSON.null
            if let data = response.result.value {
                json = JSON(data)
            }

            let resp = parseResponseStatus(response.result.isSuccess, json: json, error: response.result.error)

            callback?(resp, json, response.request, response.result.error)
        }
    }

}
