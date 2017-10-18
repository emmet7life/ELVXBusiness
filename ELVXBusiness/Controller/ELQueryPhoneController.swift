//
//  ELQueryPhoneController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

class ELQueryPhoneController: ELBaseController {

    class func viewController(_ boxType: ELToolsBoxType) -> ELQueryPhoneController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_ID_QueryPhone") as! ELQueryPhoneController
        controller.boxType = boxType
        return controller
    }

    // View
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var queryBtn: UIButton!
    @IBOutlet weak var queryResultLabel: UILabel!
    @IBOutlet weak var addToContactBtn: UIButton!

    // Data
    fileprivate var boxType: ELToolsBoxType = .addFunc
    fileprivate var resultPhoneModel: ELPhone?

    deinit {
        SVProgressHUD.dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = boxType.title

        phoneField.delegate = self
        addToContactBtn.isHidden = true

        queryBtn.layer.cornerRadius = 6.0
        queryBtn.layer.borderWidth = 0.5
        queryBtn.layer.masksToBounds = true
        queryBtn.layer.borderColor = UIColor.white.cgColor

        addToContactBtn.layer.cornerRadius = 6.0
        addToContactBtn.layer.borderWidth = 0.5
        addToContactBtn.layer.masksToBounds = true
        addToContactBtn.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onAddToContactBtnTapped(_ sender: Any) {
        if let phone = resultPhoneModel {
            ELContactsTools.shared.imports(to: [phone], delegate: self)
        }
    }

    /// 请求手机号相关信息
    @IBAction func onQueryBtnTapped(_ sender: Any) {
        let phoneNumber = phoneField.text ?? ""
        guard !phoneNumber.isEmpty else {
            SVProgressHUD.showError(withStatus: "手机号不正确\n(；′⌒`)")
            return
        }
        phoneField.resignFirstResponder()
        addToContactBtn.isHidden = true
        queryResultLabel.text = "查询到的信息将在这里展示"

        SVProgressHUD.show(withStatus: "查询中，请稍候...")
        let apiURL = queryPhoneApi(phoneNumber)
        ELReqBaseManager.request(url: apiURL, method: .get, callback: {[weak self] (status, json, request, error) in
            self?.onReqComplete(phoneNumber, status, json, request, error)
        })
    }

    /// 请求完成
    fileprivate func onReqComplete(_ phoneNumber: String, _ status: ELNetResponseStatus, _ json: JSON, _ request: URLRequest?, _ error: Error?) {
        SVProgressHUD.dismiss()

        var isError: Bool = false
        if case .success(let isSuccess, _, _) = status {
            if isSuccess {
                print(json)
                let phoneModel = ELPhone(json["data"])
                queryResultLabel.text = phoneModel.description
                addToContactBtn.isHidden = false
                resultPhoneModel = phoneModel
            } else {
                isError = true
            }
        } else {
            isError = true
        }

        if isError {
            SVProgressHUD.showError(withStatus: "发生错误了，请稍候重试\n(；′⌒`)")
        }
    }

}

extension ELQueryPhoneController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.shouldInputWithLimit(11, range: range, string: string)
    }

}

extension ELQueryPhoneController: ELContactsToolsDelegate {
    func elContactsToolsStartImports() {
        SVProgressHUD.show(withStatus: "正在导入，请稍候...")
    }

    func elContactsToolsEndImports(_ successCount: Int) {
        SVProgressHUD.showSuccess(withStatus: "导入成功")
        addToContactBtn.isHidden = true
    }
}
