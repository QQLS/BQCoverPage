//
//  BQTabBar.swift
//  BQCoverPage
//
//  Created by QQLS on 2018/8/27.
//  Copyright © 2018年 QQLS. All rights reserved.
//

import UIKit

class BQTabBar: UIScrollView {
    
}

private extension BQTabBar {
    
    class BQPageTabItem: UIControl {
        
        var itemIndex: Int = 0
        
        var normalTitleColor: UIColor = .gray
        var highlightedTitleColor: UIColor = .black
        
        var titleLabel = UILabel()
        
        override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    titleLabel.textColor = highlightedTitleColor
                    if #available(iOS 8.2, *) {
                        titleLabel.font = UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: .medium)
                    } else {
                        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: titleLabel.font.pointSize)
                    }
                    titleLabel.sizeToFit()
                } else {
                    titleLabel.textColor = normalTitleColor;
                    titleLabel.font = UIFont.systemFont(ofSize: titleLabel.font.pointSize)
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = .clear
            
            titleLabel.backgroundColor = .clear
            titleLabel.textAlignment = .center
            titleLabel.frame = bounds
            addSubview(titleLabel)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        }
        
    }
    
}
