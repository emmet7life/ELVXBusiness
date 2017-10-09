//
//  ImportHistoryDetailViewController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/28.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SVProgressHUD
import expanding_collection

class ImportHistoryDetailViewController: UITableViewController {

    class func viewController(dates: [Date]) -> UITableViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_ID_History_Detail") as! ImportHistoryDetailViewController
        controller.queryDates = dates
        return controller
    }

    var queryDates = [Date]()
    var queryDatas = [ELHistory]()

    fileprivate var isInitDataQuery = false

    deinit {
        SVProgressHUD.dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "查询中...")

        title = "详情"

        edgesForExtendedLayout = .top
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .automatic
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }

        tableView.register(UINib(nibName: "HistoryDetailView", bundle: nil), forHeaderFooterViewReuseIdentifier: ELHistoryDetailHeaderView.identifier)
        tableView.register(UINib(nibName: "PhoneDetailCell", bundle: nil), forCellReuseIdentifier: ELPhoneCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
    }

    @objc fileprivate func onImportAllBatButtonItemTapped() {
        print("onImportAllBatButtonItemTapped")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 初始化数据查询
        guard !isInitDataQuery else { return }
        isInitDataQuery = true

        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            dateFormat.locale = Locale.current

            for date in weakSelf.queryDates {
                let phones = ELDatabaseTools.shared.query(with: date)
                let history = ELHistory(createDate: date, recordCount: phones.count, recordData: phones, dateStr: dateFormat.string(from: date), timeStr: "")
                weakSelf.queryDatas.append(history)
            }

            DispatchQueue.main.async { [weak weakSelf] in
                weakSelf?.tableView.reloadData()
                SVProgressHUD.dismiss()


                // 导入全部
                let importAllBarButtonItem = UIBarButtonItem(title: "全部导入", style: .plain, target: self, action: #selector(ImportHistoryDetailViewController.onImportAllBatButtonItemTapped))
                weakSelf?.navigationItem.rightBarButtonItem = importAllBarButtonItem
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return queryDatas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phonesCount(at: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ELPhoneCell.identifier, for: indexPath)
        if let phoneCell = cell as? ELPhoneCell {
            phoneCell.phoneModel = phone(at: indexPath.section, index: indexPath.row)
            phoneCell.isHiddenCheckedImageView = true
            phoneCell.phoneLabelTextAlignment = .right
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ELHistoryDetailHeaderView.identifier)
        if let headerView = view as? ELHistoryDetailHeaderView {
            if let historyModel = history(at: section) {
                headerView.section = section
                headerView.delegate = self
                headerView.timeLabel.text = historyModel.dateStr + " " + historyModel.timeStr
            }
        }
        return view
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
    }

}

extension ImportHistoryDetailViewController: ELHistoryDetailHeaderViewDelegate {
    func elHistoryDetailHeaderViewReimportBtnTapped(_ section: Int) {
        let _navigationController = navigationController
        navigationController?.popToRootViewController(animated: false)
        if let controller = _navigationController?.visibleViewController as? ViewController, let phoneModel = history(at: section)?.recordData {
            controller.resetPhoneModel(phoneModel)
        }
    }
}

extension ImportHistoryDetailViewController {

    fileprivate func phonesCount(at index: Int) -> Int {
        return history(at: index)?.recordData.count ?? 0
    }

    fileprivate func history(at index: Int) -> ELHistory? {
        if index >= 0 && index < queryDatas.count {
            return queryDatas[index]
        }
        return nil
    }

    fileprivate func phone(at section: Int, index: Int) -> ELPhone? {
        if section >= 0 && section < queryDatas.count {
            let history = queryDatas[section]
            if index >= 0 && index < history.recordData.count {
                return history.recordData[index]
            }
        }
        return nil
    }

}
