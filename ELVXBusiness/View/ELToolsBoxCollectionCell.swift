//
//  ELToolsBoxCollectionCell.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

class ELToolsBoxCollectionCell: UICollectionViewCell {

    static let identifier = "identifier_ELToolsBoxCollectionCell"

    @IBOutlet weak var boxImageView: UIImageView!
    @IBOutlet weak var boxTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.borderColor = UIColor.assitantColor.cgColor
        contentView.layer.borderWidth = 0.5
    }

    var boxType: ELToolsBoxType = .addFunc {
        didSet {
            boxImageView.image = UIImage(named: boxType.icon)
            boxTitleLabel.text = boxType.title
        }
    }

}
