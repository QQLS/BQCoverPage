//
//  BQTabController.swift
//  BQCoverPage
//
//  Created by QQLS on 2018/8/27.
//  Copyright © 2018年 QQLS. All rights reserved.
//

import UIKit

class BQTabController: UIViewController {
    
    /// 往下拉时 Tab 的最大值(默认为屏幕高度)
    var maxOffset: CGFloat = .screenHeight
    /// 往上拉时 Tab 的最小值(默认为顶部高度)
    var minOffset: CGFloat = .statusBarHeight + .navigationBarHeight
    
    /// 记录当时的顶部偏移量
    private var tabViewTop: CGFloat = 0
    
    /// 为解决 pagecontroller 的横向滑动问题
    private var canScrollWithPageOff = false
    
    /// 展示 Controller
    private let pageController = BQPageController()
    
    /// Tab 的背景视图
    private(set) var tabBackgroundView = UIView()
    /// Tab 的容器视图
    private(set) var tabContainerView = UIView()
    /// Tab 的内容视图
    private(set) var tabContentView = UIView()
    
}

// MARK: - Lifecycle
extension BQTabController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageController.dataSource = self
        pageController.delegate = self
        pageController.updateCurrent(at: pageFirstIndex())
        pageController.view.frame = pageFrame()
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
}

// MARK: - Initial
private extension BQTabController {
    
    func layoutTabBar() {
        
    }
    
}

extension BQTabController {
    
    /// 适用于 Tab 高度变化的情况
    func reloadTab(isScroll: Bool) {
        
    }
    
    /// 完全刷新页面
    func reloadData() {
        
    }
    
    /// 用来手动切换界面
    func skip(to index: Int) {
        
    }
    
}

extension BQTabController: BQPageDataSource {
    
}

extension BQTabController: BQPageDelegate {
    
    func pageController(_ pageController: BQPageController, willTransition fromVC: UIViewController, toVC: UIViewController) {
        
    }
    
    func pageController(_ pageController: BQPageController, didTransition fromVC: UIViewController, toVC: UIViewController) {
        
    }
    
    func pageController(_ pageController: BQPageController, willLeave fromVC: UIViewController, toVC: UIViewController) {
        
    }
    
    func pageController(_ pageController: BQPageController, didLeave fromVC: UIViewController, toVC: UIViewController) {
        
    }
    
    func contentOffsetRatio(_ ratio: CGFloat, isDragging: Bool) {
        
    }
    
    func pageOffset(_ realOffset: CGFloat, index: Int) {
        
    }
    
    func willChangeInit() {
        
    }
    
}

extension BQTabController: BQTabDataSource {
    
}

extension BQTabController: BQTabDelegate {
    
    func didClickTabItem(at index: Int) {
        if subpageCanScroll(at: index) {
            pageController.showSubpage(at: index, animated: true)
        }
    }
    
}
