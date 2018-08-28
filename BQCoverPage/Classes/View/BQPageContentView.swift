//
//  BQPageContentView.swift
//  BQCoverPage
//
//  Created by QQLS on 2018/8/27.
//  Copyright © 2018年 QQLS. All rights reserved.
//

import UIKit

class BQPageContentView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 上下两行代码是等价的
        autoresizingMask = UIViewAutoresizing(rawValue: 0x1<<6 - 1)
//        autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin, .flexibleHeight]
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        bounces = false
        scrollsToTop = false
        backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Override
extension BQPageContentView {
    
    override func addSubview(_ view: UIView) {
        // 只有不存在的时候才会添加上去
        if !subviews.contains(view) {
            super.addSubview(view)
        }
    }
    
}

// MARK: - Interface
extension BQPageContentView {
    
    func updateLayoutIfNeeded(_ dataSource: BQPageDataSource?) {
        var startIndex = -1
        var endIndex = -1
        let itemCount = dataSource?.numberOfControllers() ?? 0
        for index in 0..<itemCount {
            let canScroll = dataSource?.subpageCanScroll(at: index) ?? true
            if canScroll && startIndex == -1 { // 第一个能滚的为开始
                startIndex = index
            } else if !canScroll && startIndex != -1 { // 在有能滚的情况下第一个不能滚的为结束
                endIndex = index
                break
            }
        }
        
        if startIndex != -1 && endIndex == -1 {
            endIndex = itemCount
        }
        
        contentInset = UIEdgeInsets(top: 0, left: -CGFloat(startIndex) * frame.size.width, bottom: 0, right: 0)
        contentSize = CGSize(width: CGFloat(endIndex) * frame.size.width, height: frame.size.height)
    }
    
    func offset(at index: Int, width: CGFloat, maxWidth: CGFloat) -> CGPoint {
        var offsetX = CGFloat(index) * width
        if offsetX < 0 { offsetX = 0 }
        if offsetX > maxWidth - width { offsetX = maxWidth - width }
        return CGPoint(x: offsetX, y: 0)
    }
    
    func index(with offset: CGFloat, width: CGFloat) -> Int {
        var index = Int(offset / width)
        if index < 0 { index = 0 }
        return index
    }
    
}

