//
//  ELBaseNavigationController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/19.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

class ELBaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .white
        navigationBar.barTintColor = .mainColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    override var prefersStatusBarHidden: Bool {
        return visibleViewController?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }

    override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

}
