//
//  ELBaseTabController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/30.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation
import UIKit

class ELBaseTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        tabBar.barStyle = .default
//        tabBar.tintColor = .mainColor
//        tabBar.barTintColor = .mainColor

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeController = mainStoryboard.instantiateViewController(withIdentifier: "VC_ID_Tab_Home")
        let toolsController = mainStoryboard.instantiateViewController(withIdentifier: "VC_ID_Tab_ToolBox")
        let userController = mainStoryboard.instantiateViewController(withIdentifier: "VC_ID_Tab_Mine")

        viewControllers = [homeController, toolsController, userController]

        UITabBarItem.appearance().titlePositionAdjustment.vertical = -2
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.colorWithHexRGBA(0xcccccc)], for: UIControlState())
//        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.mainColor], for: .selected)

        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 9)], for: UIControlState())

        let homeItem = tabBar.items![0]
        let toolsItem = tabBar.items![1]
        let userItem = tabBar.items![2]

        homeItem.title = "主页"
        homeItem.image = UIImage(named: "home_normal")
        homeItem.selectedImage = UIImage(named: "home")
        homeItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)

        toolsItem.title = "工具"
        toolsItem.image = UIImage(named: "toolsbox_normal")
        toolsItem.selectedImage = UIImage(named: "toolsbox")
        toolsItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)

        userItem.title = "我的"
        userItem.image = UIImage(named: "user_normal")
        userItem.selectedImage = UIImage(named: "user")
        userItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)

        view.backgroundColor = .white
        tabBar.shadowImage = UIImage(named: "sep_line")
        tabBar.backgroundImage = UIImage()

        selectedIndex = 0

        let attributesForNormal = [NSForegroundColorAttributeName: UIColor.subColor, NSFontAttributeName: UIFont.systemRegularFont(9.0)]
        let attributesForSelected = [NSForegroundColorAttributeName: UIColor.mainColor, NSFontAttributeName: UIFont.systemRegularFont(9.0)]
        UITabBarItem.appearance().setTitleTextAttributes(attributesForNormal, for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes(attributesForSelected, for: .highlighted)
        UITabBarItem.appearance().setTitleTextAttributes(attributesForSelected, for: .selected)
    }

    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let controller = selectedViewController {
            return controller.preferredStatusBarStyle
        }
        return .default
    }

    override var shouldAutorotate: Bool {
        if let controller = selectedViewController {
            return controller.shouldAutorotate
        }
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let controller = selectedViewController {
            return controller.supportedInterfaceOrientations
        }
        return .portrait
    }
}
