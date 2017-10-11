//
//  UITableViewCell+Extension.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/10/11.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import UIKit

enum ELSeperatorLineStyle {
    // 通用 (lPadding: 89.0 - rPadding: 0.0)
    case base

    // 我的界面 (lPadding: 24.0 - rPadding: 24.0)
    // 设置界面 (lPadding: 15.0 - rPadding: 15.0)
    case custom(CGFloat, CGFloat)
}

enum ELSeperatorLinePosition {
    case top
    case bottom
}

class ELSeperatorLineView: UIView {}

extension UITableViewCell {

    func addLine(by style: ELSeperatorLineStyle = .base,
                 color: UIColor = .sepLineColor,
                 height: CGFloat = 0.5,
                 position: ELSeperatorLinePosition = .bottom) {

        var hasFind = false
        for subview in contentView.subviews {
            if subview is ELSeperatorLineView {
                hasFind = true
                let lineView = subview as! ELSeperatorLineView
                updateLineViewStyle(lineView, style: style, color: color, height: height, position: position)
            }
        }

        if !hasFind {
            let lineView = ELSeperatorLineView()
            contentView.addSubview(lineView)
            updateLineViewStyle(lineView, style: style, color: color, height: height, position: position)
        }
    }

    func removeLine() {
        for subview in contentView.subviews {
            if subview is ELSeperatorLineView {
                subview.removeFromSuperview()
            }
        }
    }

    fileprivate func updateLineViewStyle(_ view: UIView,
                                         style: ELSeperatorLineStyle,
                                         color: UIColor,
                                         height: CGFloat,
                                         position: ELSeperatorLinePosition) {

        view.backgroundColor = color
        view.height = height
        var lPadding: CGFloat = 0.0
        var rPadding: CGFloat = 0.0
        switch style {
        case .base:
            lPadding = 89.0
            rPadding = 0.0
        case .custom(let lVal, let rVal):
            lPadding = lVal
            rPadding = rVal
        }

        view.left = lPadding
        view.width = UIScreen.main.bounds.width - lPadding - rPadding

        switch position {
        case .top:
            view.top = 0.0
        case .bottom:
            view.bottom = contentView.bottom
        }
    }

}
