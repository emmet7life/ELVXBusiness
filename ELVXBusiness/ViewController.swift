//
//  ViewController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/12.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SwiftyJSON
import YYCategories
import FileKit
import SVProgressHUD

enum ELDownloadState {
    case wait
    case downloading
    case downloaded
}

class ELOperatorView: UIView {

    var targetSize: CGSize = CGSize(width: 90.0, height: 90.0)

    override func layoutSubviews() {
        super.layoutSubviews()

        let scale: CGFloat = targetSize.width / 90.0
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }

}

class ELButton: UIButton {

    var targetSize: CGSize = CGSize(width: 90.0, height: 90.0)

    override func layoutSubviews() {
        super.layoutSubviews()

        let scale: CGFloat = targetSize.width / 90.0
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }

}

class ViewController: UIViewController {

    // MARK: - View
    @IBOutlet weak var countCollectionView: MILRatingCollectionView!
    @IBOutlet weak var phonePrefixMultipleSelectCollectionView: MultipleSelectCollectionView!
    @IBOutlet weak var phoneMediumMultipleSelectCollectionView: MultipleSelectCollectionView!
    @IBOutlet weak var phoneSuffixMultipleSelectCollectionView: MultipleSelectCollectionView!
    @IBOutlet weak var phoneNumbersTableView: UITableView!

    @IBOutlet weak var operatorView: UIView!
    @IBOutlet weak var operatorUpLabel: UILabel!
    @IBOutlet weak var operatorDownLabel: UILabel!

    @IBOutlet weak var completeBtn: UIButton!

    @IBOutlet weak var operatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var operatorViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var operatorViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var completeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var completeBtnCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var completeBtnBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var topContentViewHeightConstraint: NSLayoutConstraint!

    // Cached View
    fileprivate var headerView: ELPhoneHeaderView?

    // MARK: - Data

    fileprivate var _orderBy: ELOrder = .isp
    fileprivate var _orderIsAsc = false

    fileprivate var phonePrefixs = [String]()
    fileprivate var phoneMediums = [String]()
    fileprivate var phoneSuffixs = [String]()

    fileprivate var generatedPhoneNumber = [String]()
    fileprivate var generatedPhoneModel = [ELPhone]()

    fileprivate var downloadState: ELDownloadState = .wait {
        didSet {
            setOperatorViewState(with: downloadState)

            switch downloadState {
            case .wait, .downloading:
                // 两个按钮回到中间

                operatorViewWidthConstraint.constant = 90.0
                operatorViewCenterXConstraint.constant = 0.0
                operatorViewBottomConstraint.constant = 20.0

                completeBtnWidthConstraint.constant = 90.0
                completeBtnCenterXConstraint.constant = 0.0
                completeBtnBottomConstraint.constant = 20.0

                let targetSize = CGSize(width: 90.0, height: 90.0)
                (operatorView as! ELOperatorView).targetSize = targetSize
                (completeBtn as! ELButton).targetSize = targetSize

                operatorView.layer.cornerRadius = 90.0 * 0.5
                completeBtn.layer.cornerRadius = 90.0 * 0.5

                topContentViewHeightConstraint.constant = 262.0

                UIView.animate(withDuration: 0.36, animations: {
                    self.view.layoutIfNeeded()
                })

                // 加上历史按钮
                if downloadState == .wait {
                    let historyBar = UIBarButtonItem(image: UIImage(named: "history"), style: .plain, target: self, action: #selector(onHistoryBarButtonItemTapped))
                    navigationItem.setRightBarButton(historyBar, animated: true)
                }

            case .downloaded:
                // 两个按钮分散到两侧

                operatorViewWidthConstraint.constant = 80.0
                operatorViewCenterXConstraint.constant = -(view.width*0.5 - 80.0 * 0.5 - 6.0)
                operatorViewBottomConstraint.constant = 6.0

                completeBtnWidthConstraint.constant = 80.0
                completeBtnCenterXConstraint.constant =  (view.width*0.5 - 80.0 * 0.5 - 6.0)
                completeBtnBottomConstraint.constant = 6.0

                let targetSize = CGSize(width: 80.0, height: 80.0)
                (operatorView as! ELOperatorView).targetSize = targetSize
                (completeBtn as! ELButton).targetSize = targetSize

                operatorView.layer.cornerRadius = 80.0 * 0.5
                completeBtn.layer.cornerRadius = 80.0 * 0.5

                topContentViewHeightConstraint.constant = 0.0

                UIView.animate(withDuration: 0.36, animations: {
                    self.view.layoutIfNeeded()
                })

                // 加上刷新按钮
                let refreshBar = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(onRefreshBarButtonItemTapped))
                navigationItem.setRightBarButton(refreshBar, animated: true)
            }
        }
    }

    // MARK: - Init Method
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .mainColor

        downloadState = .wait

        SVProgressHUD.setDefaultStyle(.dark)

        operatorView.layer.cornerRadius = operatorView.width * 0.5
        operatorView.backgroundColor = .mainColor
        completeBtn.layer.cornerRadius = completeBtn.width * 0.5
        completeBtn.backgroundColor = .mainColor

        phoneNumbersTableView.register(ELPhoneHeaderView.self, forHeaderFooterViewReuseIdentifier: ELPhoneHeaderView.identifier)
        phoneNumbersTableView.register(UINib.init(nibName: "PhoneDetailCell", bundle: nil), forCellReuseIdentifier: ELPhoneCell.identifier)

        phoneNumbersTableView.dataSource = self
        phoneNumbersTableView.delegate = self

        countCollectionView.constants.numbers = [10, 50, 100, 150, 200]
        countCollectionView.constants.circleBackgroundColor = UIColor.mainColor
        
        countCollectionView.constants.fontSize = UIScreen.isPhoneDown5Plus ? 30.0 : 40.0

        // 提取本地号段数据
        phonePrefixs = [String]()
        phoneMediums = [String]()
        phoneSuffixs = [String]()

        if let phoneJsonRawPath = Bundle.main.path(forResource: "phone", ofType: "json") {
            if let phoneData = try? Data(contentsOf: URL(fileURLWithPath: phoneJsonRawPath)) {
                let prefixJSON = JSON(phoneData)["prefix"]
                for (_, valueJSON) in prefixJSON.dictionaryValue {
                    for prefixJSON in valueJSON.arrayValue {
                        let prefix = prefixJSON.stringValue
                        phonePrefixs.append(prefix)
                    }
                }
                phonePrefixMultipleSelectCollectionView.isPrefixAddtional = true
                phonePrefixMultipleSelectCollectionView.texts = phonePrefixs

                let mediumJSON = JSON(phoneData)["medium"]
                for medium in mediumJSON.arrayValue {
                    let mediumText = medium.stringValue
                    phoneMediums.append(mediumText)
                }
                phoneMediumMultipleSelectCollectionView.isPrefixAddtional = true
                phoneMediumMultipleSelectCollectionView.texts = phoneMediums

                let suffixJSON = JSON(phoneData)["suffix"]
                for suffix in suffixJSON.arrayValue {
                    let suffixText = suffix.stringValue
                    phoneSuffixs.append(suffixText)
                }
                phoneSuffixMultipleSelectCollectionView.isPrefixAddtional = true
                phoneSuffixMultipleSelectCollectionView.texts = phoneSuffixs
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Logic Method

    /// 根据状态设置主操作按钮的文本信息
    fileprivate func setOperatorViewState(with downloadState: ELDownloadState) {
        switch downloadState {
        case .wait:
            operatorUpLabel.text = "开始"
            operatorDownLabel.text = "下载"
        case .downloading:
            operatorUpLabel.text = "正在"
            operatorDownLabel.text = "下载"
        case .downloaded:
            operatorUpLabel.text = "重新"
            operatorDownLabel.text = "下载"
        }
    }

    /// 主操作按钮点击处理
    @IBAction func onOperatorBtnTapped(_ sender: Any) {
        switch downloadState {
        case .wait:
            view.isUserInteractionEnabled = false
            SVProgressHUD.show()

            startDownload()

            downloadState = .downloading

        case .downloaded:
            downloadState = .wait
            generatedPhoneNumber.removeAll()
            generatedPhoneModel.removeAll()
            phoneNumbersTableView.reloadData()
        case .downloading:
            break
        }
    }

    /// “完成”按钮点击处理
    @IBAction func onCompleteBtnTapped(_ sender: Any) {
        // 过滤未选中的项
        let userNeededPhoneModel = generatedPhoneModel.flatMap { $0.isRowSelected ? $0 : nil }
        ELContactsTools.shared.imports(to: userNeededPhoneModel, delegate: self)
    }

    @objc fileprivate func onHistoryBarButtonItemTapped() {
        let controller = ImportHistoryViewController.viewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc fileprivate func onRefreshBarButtonItemTapped() {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()

        startDownload()
    }

    fileprivate func reorderContent() {
        switch _orderBy {
        case .isp: orderContentByIsp(_orderIsAsc)
        case .city: orderContentByCity(_orderIsAsc)
        case .phone: orderContentByPhone(_orderIsAsc)
        }
    }

    fileprivate func orderContentByIsp(_ isAsc: Bool) {

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            return isAsc ? modelL.isp.rawValue > modelR.isp.rawValue : modelL.isp.rawValue < modelR.isp.rawValue
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.isp.rawValue == modelR.isp.rawValue {
                return isAsc ? modelL.city > modelR.city : modelL.city < modelR.city
            }
            return false
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.isp.rawValue == modelR.isp.rawValue {
                if modelL.city == modelR.city {
                    return isAsc ? modelL.mobile > modelR.mobile : modelL.mobile < modelR.mobile
                }
            }
            return false
        })

        phoneNumbersTableView.reloadData()
    }

    fileprivate func orderContentByCity(_ isAsc: Bool) {

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            return isAsc ? modelL.city > modelR.city : modelL.city < modelR.city
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.city == modelR.city {
                return isAsc ? modelL.isp.rawValue > modelR.isp.rawValue : modelL.isp.rawValue < modelR.isp.rawValue
            }
            return false
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.city == modelR.city {
                if modelL.isp.rawValue == modelR.isp.rawValue {
                    return isAsc ? modelL.mobile > modelR.mobile : modelL.mobile < modelR.mobile
                }
            }
            return false
        })

        phoneNumbersTableView.reloadData()
    }

    fileprivate func orderContentByPhone(_ isAsc: Bool) {

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            return isAsc ? modelL.mobile > modelR.mobile : modelL.mobile < modelR.mobile
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.mobile == modelR.mobile {
                return isAsc ? modelL.isp.rawValue > modelR.isp.rawValue : modelL.isp.rawValue < modelR.isp.rawValue
            }
            return false
        })

        generatedPhoneModel.sort(by: { (modelL, modelR) -> Bool in
            if modelL.mobile == modelR.mobile {
                if modelL.isp.rawValue == modelR.isp.rawValue {
                    return isAsc ? modelL.city > modelR.city : modelL.city < modelR.city
                }
            }
            return false
        })

        phoneNumbersTableView.reloadData()
    }

    // MARK: - Request & Handler

    /// 开始下载
    fileprivate func startDownload() {

        guard let generateCount = countCollectionView.constants.selectedIndex else { return }
        generatedPhoneNumber.removeAll()
        generatedPhoneModel.removeAll()

        print(phonePrefixMultipleSelectCollectionView.selectedCellIndexes)
        print(phoneMediumMultipleSelectCollectionView.selectedCellIndexes)
        print(phoneSuffixMultipleSelectCollectionView.selectedCellIndexes)

        let originalPrefixSelectedIndexes = ELPhoneTools.shared.generateSelectedIndexes(phonePrefixMultipleSelectCollectionView.selectedCellIndexes, dataArray: phonePrefixs)
        let originalMediumSelectedIndexes = ELPhoneTools.shared.generateSelectedIndexes(phoneMediumMultipleSelectCollectionView.selectedCellIndexes, dataArray: phoneMediums)
        let originalSuffixSelectedIndexes = ELPhoneTools.shared.generateSelectedIndexes(phoneSuffixMultipleSelectCollectionView.selectedCellIndexes, dataArray: phoneSuffixs)

        var prefixSelectedIndexes = originalPrefixSelectedIndexes
        var mediumSelectedIndexes = originalMediumSelectedIndexes
        var suffixSelectedIndexes = originalSuffixSelectedIndexes

        while generatedPhoneNumber.count < generateCount {
            // 随机取prefix
            let _randomPrefix = ELPhoneTools.shared.random(prefixSelectedIndexes.count)
            let prefixRaw = phonePrefixs[prefixSelectedIndexes[_randomPrefix]]
            prefixSelectedIndexes.remove(at: _randomPrefix)
            if prefixSelectedIndexes.isEmpty {
                prefixSelectedIndexes = originalPrefixSelectedIndexes
            }

            // 随机取medium
            let _randomMedium = ELPhoneTools.shared.random(mediumSelectedIndexes.count)
            let mediumRaw = phoneMediums[mediumSelectedIndexes[_randomMedium]]
            mediumSelectedIndexes.remove(at: _randomMedium)
            if mediumSelectedIndexes.isEmpty {
                mediumSelectedIndexes = originalMediumSelectedIndexes
            }

            // 随机取suffix
            let _randomSuffix = ELPhoneTools.shared.random(suffixSelectedIndexes.count)
            let suffixRaw = phoneSuffixs[suffixSelectedIndexes[_randomSuffix]]
            suffixSelectedIndexes.remove(at: _randomSuffix)
            if suffixSelectedIndexes.isEmpty {
                suffixSelectedIndexes = originalSuffixSelectedIndexes
            }

            if let prefix = ELPhonePrefix(rawValue: prefixRaw), let medium = ELPhoneMedium(rawValue: mediumRaw), let suffix = ELPhoneSuffix(rawValue: suffixRaw) {
                if let phoneNumber = ELPhoneTools.shared.generatePhoneNumber(with: prefix, medium: medium, suffix: suffix) {
                    if ELDatabaseTools.shared.exists(with: phoneNumber) {
                        print("数据库中已存在此号码了😲！！\(phoneNumber)")
                        continue
                    }

                    if generatedPhoneNumber.contains(phoneNumber) {
                        print("竟然随机出了同样的号码 😲！！\(phoneNumber)")
                        continue
                    }

                    generatedPhoneNumber.append(phoneNumber)
                }
            }
        }

        guard !generatedPhoneNumber.isEmpty else { return }
        requestPhoneNumberDetailInfo(generatedPhoneNumber.remove(at: 0))
    }

    /// 请求手机号相关信息
    fileprivate func requestPhoneNumberDetailInfo(_ phoneNumber: String) {
        let apiURL = "http://sj.apidata.cn/?mobile=\(phoneNumber)"
        ELReqBaseManager.request(url: apiURL, method: .get, callback: {[weak self] (status, json, request, error) in
            self?.onReqComplete(phoneNumber, status, json, request, error)
        })
    }

    /// 请求完成
    fileprivate func onReqComplete(_ phoneNumber: String, _ status: ELNetResponseStatus, _ json: JSON, _ request: URLRequest?, _ error: Error?) {
        if case .success(let isSuccess, _, _) = status {
            if isSuccess {
                print(json)
                if let index = generatedPhoneNumber.index(where: { return $0 == phoneNumber }) {
                    generatedPhoneNumber.remove(at: index)
                }

                let phoneModel = ELPhone(json["data"])
                generatedPhoneModel.append(phoneModel)
            }
        }

        if !generatedPhoneNumber.isEmpty {
            // 继续查询
            requestPhoneNumberDetailInfo(generatedPhoneNumber.remove(at: 0))
        } else {
            // 全部查询完成
            reorderContent()
            phoneNumbersTableView.reloadData()

            downloadState = .downloaded
            SVProgressHUD.dismiss()
            view.isUserInteractionEnabled = true
        }
    }

    // 由“详情页”的“导入”功能调用
    func resetPhoneModel(_ phoneModel: [ELPhone]) {
        generatedPhoneModel = phoneModel

        reorderContent()
        phoneNumbersTableView.reloadData()

        downloadState = .downloaded
        view.isUserInteractionEnabled = true
    }
}

// MARK: - 排序
extension ViewController: ELPhoneOrderDelegate {
    func elPhoneOrder(by order: ELOrder, isAsc: Bool) {
        _orderBy = order
        _orderIsAsc = isAsc
        guard !generatedPhoneModel.isEmpty else { return }
        reorderContent()
    }

    func elPhoneSelectAll(_ isSelectAll: Bool) {
        for var phone in generatedPhoneModel.enumerated() {
            phone.element.isRowSelected = isSelectAll
            generatedPhoneModel[phone.offset] = phone.element
        }

        phoneNumbersTableView.reloadData()
    }
}

// MARK: - 导入通讯录过程代理
extension ViewController: ELContactsToolsDelegate {
    func elContactsToolsStartImports() {
        SVProgressHUD.show(withStatus: "正在导入数据，请稍候...")
        view.isUserInteractionEnabled = false
    }

    func elContactsToolsEndImports(_ successCount: Int) {
        SVProgressHUD.showSuccess(withStatus: "成功导入\(successCount)条数据")
        view.isUserInteractionEnabled = true
    }
}

// MARK: - 展示Cell代理
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return generatedPhoneModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ELPhoneCell.identifier, for: indexPath)
        if let elPhoneCell = cell as? ELPhoneCell {
            let phoneModel = generatedPhoneModel[indexPath.row]
            elPhoneCell.phoneModel = phoneModel
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        var phoneModel = generatedPhoneModel[indexPath.row]
        phoneModel.isRowSelected = !phoneModel.isRowSelected
        generatedPhoneModel[indexPath.row] = phoneModel

        tableView.reloadRow(at: indexPath, with: .none)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let _headerView = headerView {
            return _headerView
        } else {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ELPhoneHeaderView.identifier)
            if let _headerView = view as? ELPhoneHeaderView {
                _headerView.delegate = self
                headerView = _headerView
            }
            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

}

@objc enum ELOrder: Int {
    case isp
    case city
    case phone
}

protocol ELPhoneOrderDelegate: class {
    func elPhoneOrder(by order: ELOrder, isAsc: Bool)
    func elPhoneSelectAll(_ isSelectAll: Bool)
}

// MARK: - 过滤器视图
class ELPhoneHeaderView: UITableViewHeaderFooterView {

    static let identifier = "ELPhoneHeaderView"

    // View
    let orderByIspBtn = UIButton(type: .custom)
    let orderByCityBtn = UIButton(type: .custom)
    let orderByPhoneBtn = UIButton(type: .custom)

    fileprivate var isCheckedAll = true

    // Delegate
    weak var delegate: ELPhoneOrderDelegate?

    override var reuseIdentifier: String? {
        return ELPhoneHeaderView.identifier
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {

        let btnHeight: CGFloat = 32.5

        setBtnStyle(orderByIspBtn)
        setBtnStyle(orderByCityBtn)
        setBtnStyle(orderByPhoneBtn)

        let orderTipLabel = UILabel()
        orderTipLabel.textColor = .subColor
        orderTipLabel.text = "排序规则: "
        orderTipLabel.font = UIFont.systemFont(ofSize: 12.0)

        let checkAllBtn = UIButton(type: .custom)
        checkAllBtn.tag = 0
        checkAllBtn.setImage(UIImage(named: "checked"), for: .normal)
        checkAllBtn.addTarget(self, action: #selector(onCheckAllBtnTapped(_:)), for: .touchUpInside)

        contentView.addSubview(orderTipLabel)
        contentView.addSubview(checkAllBtn)

        contentView.addSubview(orderByIspBtn)
        contentView.addSubview(orderByCityBtn)
        contentView.addSubview(orderByPhoneBtn)

        orderTipLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(8.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(btnHeight)
        }

        orderByIspBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(orderTipLabel.snp.trailing).offset(5.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(btnHeight)
            make.width.greaterThanOrEqualTo(50.0)
        }

        orderByCityBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(orderByIspBtn.snp.trailing).offset(5.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(btnHeight)
            make.width.greaterThanOrEqualTo(50.0)
        }

        orderByPhoneBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(orderByCityBtn.snp.trailing).offset(5.0)
            make.centerY.equalToSuperview()
            make.height.equalTo(btnHeight)
            make.width.greaterThanOrEqualTo(50.0)
        }

        checkAllBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(-2.0)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44.0)
        }

        orderByIspBtn.setTitle("运营商", for: UIControlState())
        orderByCityBtn.setTitle("城市", for: UIControlState())
        orderByPhoneBtn.setTitle("手机号", for: UIControlState())

        // 默认按运营商排序
        orderByIspBtn.isSelected = true
    }

    fileprivate func setBtnStyle(_ btn: UIButton) {
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 6.0
        btn.setTitleColor(.white, for: .selected)
        btn.setBackgroundImage(UIImage.image(from: .mainColor), for: .selected)
        btn.setTitleColor(.subColor, for: .normal)
        btn.setBackgroundImage(UIImage.image(from: .assitantColor), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        btn.addTarget(self, action: #selector(onBtnTapped(_:)), for: .touchUpInside)
        btn.tag = 0
    }

    @objc fileprivate func onBtnTapped(_ sender: UIButton) {
        for button in [orderByIspBtn, orderByCityBtn, orderByPhoneBtn] {
            button.isSelected = sender == button
            button.tag = button.tag == 0 ? 1 : 0
        }

        if orderByIspBtn.isSelected {
            delegate?.elPhoneOrder(by: .isp, isAsc: sender.tag == 0)
        } else if orderByCityBtn.isSelected {
            delegate?.elPhoneOrder(by: .city, isAsc: sender.tag == 0)
        } else if orderByPhoneBtn.isSelected {
            delegate?.elPhoneOrder(by: .phone, isAsc: sender.tag == 0)
        }
    }

    @objc fileprivate func onCheckAllBtnTapped(_ sender: UIButton) {
        isCheckedAll = !isCheckedAll
        delegate?.elPhoneSelectAll(isCheckedAll)
    }
    
}
