//
//  HistoryCardCollectionCell.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/27.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import expanding_collection

class HistoryCardCollectionCell: BasePageCollectionCell {

    static let identifier = "identifier_HistoryCardCollectionCell"

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var customTitle: UILabel!

    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordDateLabel: UILabel!
    @IBOutlet weak var citysLabel: UILabel!

    // Back Container View Subview
    @IBOutlet weak var line1IspLabel: UILabel!
    @IBOutlet weak var line1CityLabel: UILabel!
    @IBOutlet weak var line1PhoneLabel: UILabel!

    @IBOutlet weak var line2IspLabel: UILabel!
    @IBOutlet weak var line2CityLabel: UILabel!
    @IBOutlet weak var line2PhoneLabel: UILabel!

    @IBOutlet weak var moreIndicatorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        customTitle.layer.shadowRadius = 2
        customTitle.layer.shadowOffset = CGSize(width: 0, height: 3)
        customTitle.layer.shadowOpacity = 0.2
    }

    var historyData: ELHistory? {
        didSet {
            if let _historyData = historyData {
                recordDateLabel.text = _historyData.dateStr
                recordTimeLabel.text = _historyData.timeStr
                customTitle.text = "\(_historyData.recordCount)"

                moreIndicatorLabel.isHidden = _historyData.recordData.count <= 2

                var existCitys = [String]()
                citysLabel.text = _historyData.recordData.map{ $0.city }.flatMap{
                    if existCitys.contains($0) {
                        return nil
                    } else {
                        existCitys.append($0)
                        return $0
                    }
                }.joined(separator: ", ")

                for phone in _historyData.recordData.prefix(2).enumerated() {
                    if phone.offset == 0 {
                        line1IspLabel.text = phone.element.isp.rawValue
                        line1CityLabel.text = phone.element.city
                        line1PhoneLabel.text = phone.element.mobile
                    } else if phone.offset == 1 {
                        line2IspLabel.text = phone.element.isp.rawValue
                        line2CityLabel.text = phone.element.city
                        line2PhoneLabel.text = phone.element.mobile
                    }
                }
            }
        }
    }

}

