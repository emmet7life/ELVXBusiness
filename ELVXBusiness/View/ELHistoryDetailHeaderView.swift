//
//  ELHistoryDetailHeaderView.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/28.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

protocol ELHistoryDetailHeaderViewDelegate: class {
    func elHistoryDetailHeaderViewReimportBtnTapped(_ section: Int)
}

class ELHistoryDetailHeaderView: UITableViewHeaderFooterView {

    static let identifier = "identifier_ELHistoryDetailHeaderView"

    override var reuseIdentifier: String? {
        return ELHistoryDetailHeaderView.identifier
    }

    // View
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reimportBtn: UIButton!

    // Data
    var section: Int = 0

    weak var delegate: ELHistoryDetailHeaderViewDelegate?

    @IBAction func onReimportBtnTapped(_ sender: Any) {
        delegate?.elHistoryDetailHeaderViewReimportBtnTapped(section)
    }

    
}
