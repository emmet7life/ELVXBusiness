//
//  ELBaseController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

class ELBaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .all
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
