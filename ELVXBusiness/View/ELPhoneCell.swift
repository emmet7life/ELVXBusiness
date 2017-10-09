//
//  ELPhoneCell.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/28.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

/// 手机号信息Cell
class ELPhoneCell: UITableViewCell {

    static let identifier = "phone_cell_identifier"

    // MARK: - View
    @IBOutlet weak var ispLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!

    // MARK: - Data
    var isHiddenCheckedImageView: Bool = false {
        didSet {
            checkedImageView.isHidden = isHiddenCheckedImageView
            checkedImageViewWidthConstraint.constant = isHiddenCheckedImageView ? 0 : 30
        }
    }
    @IBOutlet weak var checkedImageViewWidthConstraint: NSLayoutConstraint!

    var phoneLabelTextAlignment: NSTextAlignment = .left {
        didSet {
            phoneNumberLabel.textAlignment = phoneLabelTextAlignment
        }
    }

    /// 数据模型
    var phoneModel: ELPhone? {
        didSet {
            if let _phoneModel = phoneModel {
                ispLabel.text = _phoneModel.isp.rawValue
                cityLabel.text = _phoneModel.city
                phoneNumberLabel.text = _phoneModel.mobile
                checkedImageView.image = _phoneModel.isRowSelected ? UIImage(named: "checked") : nil
            }
        }
    }

}
