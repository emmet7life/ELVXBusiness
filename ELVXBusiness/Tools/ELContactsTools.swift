//
//  ELContactsTools.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/25.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import AddressBook
import Contacts
import SVProgressHUD

enum ELAuthorizationStatus {
    case notDetermined          // 从未授权
    case restricted                   // 被设置中的许可配置阻止
    case denied                        // 拒绝
    case authorized                  // 已授权
}

@objc protocol ELContactsToolsDelegate: class {
    @objc optional func elContactsToolsUserDenied()

    func elContactsToolsStartImports()
    func elContactsToolsEndImports(_ successCount: Int)
}

class ELContactsTools {

    static let shared = ELContactsTools()
    weak var delegate: ELContactsToolsDelegate?

    private init() { }

    func imports(to phones: [ELPhone], delegate: ELContactsToolsDelegate? = nil) {
        self.delegate = delegate

        let authStatus = authorizationStatus()
        switch authStatus {
        case .notDetermined:// 从未授权
            if #available(iOS 9.0, *) {
                let contactStore = CNContactStore()
                contactStore.requestAccess(for: .contacts, completionHandler: { [weak self] (granted, error) in
                    print(granted)
                    DispatchQueue.main.sync {
                        if granted {
                            // 授权成功
                            self?.importsInternal(to: phones)
                        } else {
                            // 授权失败
                            SVProgressHUD.show(withStatus: "(；′⌒`)\n\n授权失败")
                            delegate?.elContactsToolsUserDenied?()
                        }
                    }
                })
            } else {
                ABAddressBookRequestAccessWithCompletion(ABAddressBookCreate() as ABAddressBook) { [weak self] (granted, error) in
                    print(granted)
                    DispatchQueue.main.sync {
                        if granted {
                            // 授权成功
                            self?.importsInternal(to: phones)
                        } else {
                            // 授权失败
                            SVProgressHUD.show(withStatus: "(；′⌒`)\n\n授权失败")
                            delegate?.elContactsToolsUserDenied?()
                        }
                    }
                }
            }
        case .denied, .restricted:
            SVProgressHUD.showInfo(withStatus: "您的通讯录未被允许访问，请您去'设置--隐私'里将访问权限打开")
            delegate?.elContactsToolsUserDenied?()
        case .authorized:
            importsInternal(to: phones)
        }
    }

}

extension ELContactsTools {
    fileprivate func authorizationStatus() -> ELAuthorizationStatus {
        if #available(iOS 9.0, *) {
            let authStatus = CNContactStore .authorizationStatus(for: .contacts)
            switch authStatus {
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            case .authorized:
                return .authorized
            }
        } else {
            let authStatus = ABAddressBookGetAuthorizationStatus()
            switch authStatus {
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            case .authorized:
                return .authorized
            }
        }
    }

    fileprivate func importsInternal(to phones: [ELPhone]) {

        func format(_ num: Int) -> String {
            if num < 10 {
                return "00000\(num)"
            } else if num < 100 {
                return "0000\(num)"
            } else if num < 1000 {
                return "000\(num)"
            } else if num < 10000 {
                return "00\(num)"
            } else if num < 100000 {
                return "0\(num)"
            }  else {
                return "\(num)"
            }
        }

        delegate?.elContactsToolsStartImports()

        // 同一批次的记录，创建时间统一
        let createTime = Date()

        if #available(iOS 9.0, *) {

            // 异步执行
            DispatchQueue.global(qos: .background).async { [weak self] in

                var count = ELDatabaseTools.shared.count()
                count += 1

                var successCount: Int = 0

                for phone in phones {
                    // 保存联系人数据到手机
                    let contact = CNMutableContact()
                    contact.givenName = format(count)
                    contact.familyName = "EL助手联系人数据"
                    contact.note = "本数据由EL助手生成"
                    contact.contactType = .person
                    let phoneValue = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: phone.mobile))
                    contact.phoneNumbers = [phoneValue]
                    let saveReq = CNSaveRequest()
                    saveReq.add(contact, toContainerWithIdentifier: nil)
                    let contactStore = CNContactStore()
                    do {
                        try contactStore.execute(saveReq)
                        successCount += 1
                    } catch {
                        print("importsInternal error: \(error)")
                    }

                    // 保存到数据库
                    ELDatabaseTools.shared.insert(to: phone, createTime)
                    count += 1
                }

                DispatchQueue.main.async {
                    self?.delegate?.elContactsToolsEndImports(successCount)
                }
            }
        } else {
            // 异步执行
            DispatchQueue.global(qos: .background).async { [weak self] in

                var count = ELDatabaseTools.shared.count()
                count += 1

                var error: Unmanaged<CFError>? = nil
                let addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
                var successCount: Int = 0

                for phone in phones {
                    // 保存联系人数据到手机
                    let person: ABRecord! = ABPersonCreate().takeRetainedValue()

                    ABRecordSetValue(person, kABPersonFirstNameProperty, "EL助手联系人数据" as CFTypeRef!, &error)
                    ABRecordSetValue(person, kABPersonLastNameProperty, format(count) as CFTypeRef!, &error)
                    ABRecordSetValue(person, kABPersonNoteProperty, "本数据由EL助手生成" as CFTypeRef!, &error)

                    let multi: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABStringPropertyType)).takeRetainedValue()
                    ABMultiValueAddValueAndLabel(multi, phone.mobile as CFTypeRef!, kABPersonPhoneMobileLabel,  nil)
                    ABRecordSetValue(person, kABPersonPhoneProperty, multi, &error)
                    ABAddressBookAddRecord(addressBook, person, &error)
                    ABAddressBookSave(addressBook, &error)
                    successCount += 1

                    // 保存到数据库
                    ELDatabaseTools.shared.insert(to: phone, createTime)
                    count += 1
                }

                DispatchQueue.main.async {
                    self?.delegate?.elContactsToolsEndImports(successCount)
                }
            }
        }
    }
}
