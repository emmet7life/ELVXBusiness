//
//  ELQueryPhoneController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

class ELQueryPhoneController: ELBaseController {

    class func viewController(_ boxType: ELToolsBoxType) -> ELQueryPhoneController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_ID_QueryPhone") as! ELQueryPhoneController
        controller.boxType = boxType
        return controller
    }

    // Data
    fileprivate var boxType: ELToolsBoxType = .addFunc

    override func viewDidLoad() {
        super.viewDidLoad()

        title = boxType.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
