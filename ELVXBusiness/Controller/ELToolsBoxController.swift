//
//  ELToolsBoxController.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/10.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit
import SVProgressHUD

class ELToolsBoxController: ELBaseController {

    // View
    @IBOutlet weak var collectionView: UICollectionView!

    // Data
    fileprivate var toolsBoxes: [ELToolsBoxType] = [.queryPhone, .addFunc]
    fileprivate var itemSize: CGSize = CGSize.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        collectionView.dataSource = self
        collectionView.delegate = self

        let itemWidth: CGFloat = view.width / 4.0
        let itemHeight: CGFloat = itemWidth
        itemSize = CGSize(width: itemWidth, height: itemHeight)

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = itemSize
            flowLayout.minimumInteritemSpacing = 0.0
            flowLayout.minimumLineSpacing = 0.0
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

}

extension ELToolsBoxController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolsBoxes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: ELToolsBoxCollectionCell.identifier, for: indexPath)
        if let boxCell = cell as? ELToolsBoxCollectionCell {
            boxCell.boxType = toolsBoxes[indexPath.item]
        }
        return cell
    }

}

extension ELToolsBoxController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let boxType = toolsBoxes[indexPath.item]
        switch boxType {
        case .queryPhone:
            let queryPhoneController = ELQueryPhoneController.viewController(boxType)
            navigationController?.pushViewController(queryPhoneController, animated: true)
        case .addFunc:
            SVProgressHUD.showInfo(withStatus: "O(∩_∩)O\n更多功能开发中\n请耐心等待")
        }
    }

}
