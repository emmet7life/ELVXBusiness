//
//  ELMineViewController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/11.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

class ELMineViewController: ELBaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .top
        automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Override UITableViewDelegate & UITableViewDataSource Method
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 16.0//super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.section == 1 {
            cell.addLine(by: .custom(16.0, 16.0), color: .sepLineColor, height: 0.5, position: .bottom)
        } else {
            cell.removeLine()
        }
        return cell
    }

}
