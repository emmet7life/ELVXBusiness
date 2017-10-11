//
//  ImportHistoryViewController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/19.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SnapKit
import SwiftDate
import SVProgressHUD
import SwiftyJSON
import expanding_collection

class ImportHistoryViewController: ExpandingViewController {

    class func viewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_ID_History")
    }

    // MARK: - Data
    fileprivate var historyDatas = [ELHistory]()
    fileprivate var cellsIsOpen = [Bool]()

    fileprivate var isInitDataQuery = false

    fileprivate var diffTimeDate = [String: [Date]]()

    deinit {
        SVProgressHUD.dismiss()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "查询中...")

        title = "历史"

        let baseWidth: CGFloat = 256.0
        let baseHeight: CGFloat = 335.0

        if UIScreen.isPhoneDown5Plus {
            let newWidth: CGFloat = 220.0
            let newHeight: CGFloat = newWidth / (baseWidth / baseHeight)

            itemSize = CGSize(width: newWidth, height: newHeight)
        } else {
            itemSize = CGSize(width: baseWidth, height: baseHeight)
        }

        super.viewDidLoad()

        registerCell()
        addSwipeGesture(to: collectionView!)
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

            // 查询时间
            var diffMonthDate = [Date]()
            var diffDayDate = [Date]()

            var diffTimeDate = [String: [Date]]()

            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            dateFormat.locale = Locale.current

            let dateGroups = ELDatabaseTools.shared.queryGroupByCreateTime()
            for date in dateGroups {
                let dateInRegion = date.inRegion(region: Region(tz: TimeZone.current, cal: Calendar.current, loc: Locale.current))
                let adjustDate = dateInRegion.absoluteDate

                // 月份不同
                if !diffMonthDate.contains(where: {
                    $0.month == adjustDate.month && $0.year == adjustDate.year
                }) {
                    diffMonthDate.append(adjustDate)
                }

                // 日期不同
                if !diffDayDate.contains(where: {
                    let diff = $0.month == adjustDate.month && $0.year == adjustDate.year && $0.day == adjustDate.day
                    return diff
                }) {
                    diffDayDate.append(adjustDate)
                }

                let dateKey = "\(adjustDate.year)-\(adjustDate.month)-\(adjustDate.day)"
                if diffTimeDate[dateKey] == nil { diffTimeDate[dateKey] = [Date]() }
                diffTimeDate[dateKey]?.append(adjustDate)

                print(dateFormat.string(from: adjustDate))
            }

            print(diffTimeDate)
            weakSelf.diffTimeDate = diffTimeDate

            // 按月组织结果
            if diffMonthDate.count > 1 {

                for date in diffMonthDate {
                    let monthStr = date.month < 10 ? "0\(date.month)" : "\(date.month)"
                    let fullMonthDateStr = "\(date.year)年\(monthStr)月\(date.monthDays)日 23:59:59"
                    let fullMonthStartDateStr = "\(date.year)年\(monthStr)月01日 00:00:00"
                    if let fullMonthDate = dateFormat.date(from: fullMonthDateStr), let fullMonthStartDate = dateFormat.date(from: fullMonthStartDateStr) {
                        let dateStr = "\(date.year)年\(monthStr)月"
                        let phones = ELDatabaseTools.shared.query(with: fullMonthDate, false, true, fullMonthStartDate)
                        let history = ELHistory(createDate: fullMonthDate, recordCount: phones.count, recordData: phones, dateStr: dateStr, timeStr: "")
                        weakSelf.historyDatas.append(history)
                    }
                }

                DispatchQueue.main.async { [weak weakSelf] in
                    weakSelf?.reloadData()
                    SVProgressHUD.dismiss()
                }

            } else if diffDayDate.count >= 1 {
                // 按天组织结果
                print(diffDayDate)

                for date in diffDayDate {
                    let monthStr = date.month < 10 ? "0\(date.month)" : "\(date.month)"
                    let fullDayDateStr = "\(date.year)年\(monthStr)月\(date.day)日 23:59:59"
                    let fullDayStartDateStr = "\(date.year)年\(monthStr)月\(date.day)日 00:00:00"
                    if let fullDayDate = dateFormat.date(from: fullDayDateStr), let fullDayStartDate = dateFormat.date(from: fullDayStartDateStr) {
                        let dateStr = "\(date.year)年\(monthStr)月\(date.day)日"
                        let phones = ELDatabaseTools.shared.query(with: fullDayDate, false, true, fullDayStartDate)
                        let history = ELHistory(createDate: fullDayDate, recordCount: phones.count, recordData: phones, dateStr: dateStr, timeStr: "")
                        weakSelf.historyDatas.append(history)
                    }
                }

                DispatchQueue.main.async { [weak weakSelf] in
                    weakSelf?.reloadData()
                    SVProgressHUD.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.showInfo(withStatus: "未能查询到数据")
                }
            }
        }
    }

}

extension ImportHistoryViewController {

    fileprivate func reloadData() {
        cellsIsOpen = Array(repeating: false, count: historyDatas.count)
        collectionView?.reloadData()
    }

    fileprivate func registerCell() {
        let nib = UINib(nibName: "HistoryCardCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: HistoryCardCollectionCell.identifier)
    }

    fileprivate func addSwipeGesture(to view: UIView) {
        let upGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))) {
            $0.direction = .up
        }
        let downGesture = Init(UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))) {
            $0.direction = .down
        }

        view.addGestureRecognizer(upGesture)
        view.addGestureRecognizer(downGesture)
    }

    @objc fileprivate func swipeHandler(_ sender: UISwipeGestureRecognizer) {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell  = collectionView?.cellForItem(at: indexPath) as? HistoryCardCollectionCell else { return }
        // double swipe Up transition
        if cell.isOpened == true && sender.direction == .up {
//            pushToViewController(getViewController())

//            let phone = ELPhone(JSON.null)
//            let history = ELHistory(createTime: "2017年09月28日", recordCount: 10, recordData: [phone])
//            pushToViewController()

//            if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
//                rightButton.animationSelected(true)
//            }

            openDetailController()
        }

        let open = sender.direction == .up ? true : false
        cell.cellIsOpen(open)
        cellsIsOpen[indexPath.row] = cell.isOpened
    }

    fileprivate func openDetailController() {
        if let dates = diffTimeDate[Array(diffTimeDate.keys)[currentIndex]] {
            navigationController?.pushViewController(ImportHistoryDetailViewController.viewController(dates: dates), animated: true)
        }
    }

}

extension ImportHistoryViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        guard let cell = cell as? HistoryCardCollectionCell else { return }

        cell.historyData = historyDatas[indexPath.row]
        cell.cellIsOpen(cellsIsOpen[indexPath.row], animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? HistoryCardCollectionCell
            , currentIndex == indexPath.row else { return }

        if cell.isOpened == false {
            cell.cellIsOpen(true)
        } else {
//            pushToViewController(getViewController())
//
//            if let rightButton = navigationItem.rightBarButtonItem as? AnimatingBarButton {
//                rightButton.animationSelected(true)
//            }

//            let phone = ELPhone(JSON.null)
//            let history = ELHistory(createTime: "2017年09月28日", recordCount: 10, recordData: [phone])
//            navigationController?.pushViewController(ImportHistoryDetailViewController.viewController(datas: [history]), animated: true)
            openDetailController()
        }
    }

}

extension ImportHistoryViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyDatas.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HistoryCardCollectionCell.identifier, for: indexPath)
    }

}
