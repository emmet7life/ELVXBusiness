//
//  MultipleSelectCollectionView.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/15.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

// MARK: - CollectionView
public class MultipleSelectCollectionView: UICollectionView {

    // MARK: - Data
    fileprivate var cellDatas = [MultipleSelectCollectionViewCellData]()

    var texts: [String] = [] {
        didSet {

            var prefixAddtionalCellData: MultipleSelectCollectionViewCellData?
            if let cellData = cellDatas.first, cellData.isPrefixAddtionalCell {
                prefixAddtionalCellData = cellData
            }

            cellDatas.removeAll()

            if let cellData = prefixAddtionalCellData {
                cellDatas.append(cellData)
            }

            for text in texts {
                let cellData = MultipleSelectCollectionViewCellData(text)
                cellDatas.append(cellData)
            }

            reloadData()
        }
    }

    fileprivate(set) var selectedCellIndexes: [Int] = [] {
        didSet {

        }
    }

    // 第一个Cell是否挂一个额外的选项
    fileprivate var _isPrefixAddtional = false
    var isPrefixAddtional: Bool {
        set {
            _isPrefixAddtional = newValue
            if _isPrefixAddtional {
                let _prefixAddtionalText = prefixAddtionalText
                prefixAddtionalText = _prefixAddtionalText
            } else {
                prefixAddtionalText = nil
            }
        }

        get {
            return _isPrefixAddtional
        }
    }

    // 额外选项是否默认选中
    var isPrefixAddtionalDefaultSelect = true
    var isPrefixAddtionalCanMixAppear = false

    // 额外选项的文本内容
    var prefixAddtionalText: String? = "随机" {
        didSet {
            if prefixAddtionalText == nil || prefixAddtionalText!.isEmpty {
                _isPrefixAddtional = false
                if let firstCellData = cellDatas.first, firstCellData.isPrefixAddtionalCell {
                    cellDatas.remove(at: 0)
                    reloadData()

                    if selectedCellIndexes.contains(0) {
                        selectedCellIndexes.remove(at: 0)
                    }
                }
            } else {
                _isPrefixAddtional = true
                if let firstCellData = cellDatas.first, firstCellData.isPrefixAddtionalCell {
                    firstCellData.text = prefixAddtionalText!
                } else {
                    let addtionalCellData = MultipleSelectCollectionViewCellData(prefixAddtionalText!)
                    addtionalCellData.isPrefixAddtionalCell = true
                    cellDatas.append(addtionalCellData)
                    // 当前已选中的项往后移一位
                    selectedCellIndexes = selectedCellIndexes.map{ $0 + 1 }
                    if isPrefixAddtionalDefaultSelect {
                        selectedCellIndexes.append(0)
                        addtionalCellData.setSelected(true)
                    }
                }

                reloadData()
            }
        }
    }

    // MARK: - 辅助属性
    fileprivate var cellHeightCaches = [String: CGSize]()

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        register(MultipleSelectCollectionViewCell.self, forCellWithReuseIdentifier: MultipleSelectCollectionViewCell.identifier)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 5.0
        flowLayout.scrollDirection = .horizontal
        collectionViewLayout = flowLayout

        dataSource = self
        delegate = self

        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
    }

}

extension MultipleSelectCollectionView: MultipleSelectCollectionViewCellDelegate {

    func onMultipleSelectCollectionViewCellTapped(indexPath: IndexPath, isSelected: Bool) {
        let itemIndex = indexPath.item
        if isSelected {
            if !selectedCellIndexes.contains(itemIndex) {
                selectedCellIndexes.append(itemIndex)
            }

            // 第一个额外的选项与其他选项不能同时存在
            if isPrefixAddtional && !isPrefixAddtionalCanMixAppear {
                // 选了“随机”，其他的默认清除
                if itemIndex == 0 {
                    let deselectCellIndexes = selectedCellIndexes.flatMap({ (item) -> Int? in
                        return item == 0 ? nil : item
                    })
                    for cellIndex in deselectCellIndexes {
                        cellDatas[cellIndex].setSelected(false)
                    }
                    selectedCellIndexes.removeAll()
                    selectedCellIndexes.append(0)
                } else {
                    // 选了其他，“随机”默认清除
                    let prefixCellData = cellDatas[0]
                    if prefixCellData.isSelected {
                        selectedCellIndexes.remove(at: 0)
                    }
                    prefixCellData.setSelected(false)
                }
                reloadData()
            }
        } else {
            if let index = selectedCellIndexes.index(where: { $0 == itemIndex }) {
                selectedCellIndexes.remove(at: index)
            }

            if selectedCellIndexes.isEmpty {
                SVProgressHUD.showInfo(withStatus: "请至少选中一个选项")

                selectedCellIndexes.append(itemIndex)
                cellDatas[itemIndex].setSelected(true)
                reloadItems(at: [IndexPath(item: itemIndex, section: 0)])
            }
        }

    }

}

extension MultipleSelectCollectionView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellDatas.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipleSelectCollectionViewCell.identifier, for: indexPath)
        if let _cell = cell as? MultipleSelectCollectionViewCell {
            _cell.cellData = cellDatas[indexPath.item]
            _cell.indexPath = indexPath
            _cell.delegate = self
        }
        return cell
    }

}

extension MultipleSelectCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cacheKey = "\(indexPath.section)-\(indexPath.item)"
        if let cachedSize = cellHeightCaches[cacheKey] {
            return cachedSize
        }
        let cellData = cellDatas[indexPath.item]
        let cellWidth = cellData.text.calculateWidthInHeight(collectionView.height, systemFontSize: 12.0) + 8.0 * 2
        let cellSize = CGSize(width: cellWidth, height: min(30, collectionView.height))
        cellHeightCaches[cacheKey] = cellSize
        return cellSize
    }
}

// MARK: - Cell
private protocol MultipleSelectCollectionViewCellDelegate: class {
    func onMultipleSelectCollectionViewCellTapped(indexPath: IndexPath, isSelected: Bool)
}

private final class MultipleSelectCollectionViewCell: UICollectionViewCell {

    public static let identifier = "MultipleSelectCollectionViewCell_identifier"

    // MARK: - Data
    var cellData: MultipleSelectCollectionViewCellData? {
        didSet {
            if let _cellData = cellData {
                textBtn.setTitle(_cellData.text, for: .normal)
                _cellData.isSelected ? setAsSelectedHighlight() : setAsNormal()
            }
        }
    }

    var indexPath: IndexPath?
    weak var delegate: MultipleSelectCollectionViewCellDelegate?

    // MARK: - View
    private lazy var textBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 6.0
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        textBtn.addTarget(self, action: #selector(onTextBtnTapped), for: .touchUpInside)
        contentView.addSubview(textBtn)
        textBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setAsNormal()
    }

    private func setAsSelectedHighlight() {
        textBtn.layer.borderColor = UIColor.mainColor.cgColor
        textBtn.setTitleColor(UIColor.mainColor, for: .normal)
    }

    private func setAsNormal() {
        textBtn.layer.borderColor = UIColor.subColor.cgColor
        textBtn.setTitleColor(UIColor.subColor, for: .normal)
    }

    @objc fileprivate func onTextBtnTapped() {
        if let _cellData = cellData {
            _cellData.isSelected = !_cellData.isSelected
            _cellData.isSelected ? setAsSelectedHighlight() : setAsNormal()

            guard let _indexPath = indexPath else { return }
            delegate?.onMultipleSelectCollectionViewCellTapped(indexPath: _indexPath, isSelected: _cellData.isSelected)
        }
    }
}

// MARK: - Cell Data
private final class MultipleSelectCollectionViewCellData {

    var isPrefixAddtionalCell = false
    var text: String = ""
    fileprivate(set) var isSelected: Bool = false

    init(_ text: String) {
        self.text = text
    }

    func setSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
}
