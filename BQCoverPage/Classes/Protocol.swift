//
//  Protocol.swift
//  BQTabController
//
//  Created by QQLS on 2018/8/22.
//

import UIKit

protocol BQCoverDataSource: class {
    
    func coverView() -> UIView
    
    func coverFrame() -> CGRect
    
}

protocol BQPageDataSource: class {
    
    // Controller 的数量
    func numberOfControllers() -> Int
    
    // 指定 Page 的 Controller
    func controller(at index: Int) -> UIViewController
    
    // Page 的 View 的大小 (默认情况下是整屏幕.通常情况下，cover 在最上面 tab 在中间 page 在下面的情况不用设这个 frame)
    func pageFrame() -> CGRect
    
    
    // 用于设子 Controller 的 Scrollview 的 inset
    func subpageTopInset(at index: Int) -> CGFloat
    
    // 解决侧滑失效的问题
    func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer?
    
    // 交互切换的时候是否预加载
    func needPreload() -> Bool
    
    // 表示这个页面是否可用
    func subpageCanScroll(at index: Int) -> Bool
    
}

extension BQPageDataSource {
    
    func pageFrame() -> CGRect {
        return .screen
    }
    
    func subpageTopOffset(at index: Int) -> CGFloat {
        return 0
    }
    
    func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer? {
        return nil
    }
    
    func subpageCanScroll(at index: Int) -> Bool {
        return true
    }
    
}

protocol BQPageDelegate: class {
    
    // 交互切换回调
    func pageController(_ pageController: BQPageController, willTransition fromVC: UIViewController, toVC: UIViewController)
    
    func pageController(_ pageController: BQPageController, didTransition fromVC: UIViewController, toVC: UIViewController)
    
    // 非交互切换回调
    func pageController(_ pageController: BQPageController, willLeave fromVC: UIViewController, toVC: UIViewController)
    
    func pageController(_ pageController: BQPageController, didLeave fromVC: UIViewController, toVC: UIViewController)
    
    // 横向滑动回调
    func contentOffsetRatio(_ ratio: CGFloat, isDragging: Bool)
    
    // 垂直滑动的回调
    func pageOffset(_ realOffset: CGFloat, index: Int)
    
    // 针对初始化
    func willChangeInit()
    
    // 横向不能滚动
    func cannotScrollWithPageOffset() -> Bool
    
}

extension BQPageDelegate {
    
    func cannotScrollWithPageOffset() -> Bool {
        return false
    }
    
}

// 如 ChildController 实现了这个协议，表示 Tab 和 Cover 会跟随 Page 纵向滑动
protocol BQSubpageDataSource: class {
    
    // 如果需要 Cover 跟着上下滑动, 子 Controller 需要实现这个方法
    func bqScrollView() -> UIScrollView?
    
}

protocol BQTabDataSource: class {
    
    func title(at index: Int) -> String
    
    func titleColor(at index: Int) -> UIColor
    
    func titleHightlightColor(at index: Int) -> UIColor
    
    func titleFont(at index: Int) -> UIFont
    
    func numberOfTab() -> Int
    
    // tab 的属性
    func tapTop() -> CGFloat
    func tapLeft() -> CGFloat
    func tabWidth() -> CGFloat
    
    // 假设每一个 item 的顶部都可变的情况
    func tabItemTop(at index: Int) -> CGFloat
    
    // 假设每一个 item 宽度都可变的情况
    func tabItemWidth(at index: Int) -> CGFloat
    
    // 假设每一个 item 高度都可变的情况
    func tabItemHeight(at index: Int) -> CGFloat
    
    // 假设每一个 item 可以单独设置
    func tabItemSetting(_ item: UIControl, at index: Int)
    
    // 设置 tabView
    func tabViewSetting(_ tabView: UIView)
    
    // 设置 tabBgView
    func tabBgViewSetting(_ tabBgView: UIView)
    
    // 设置 tabContainerView
    func tabContainerViewSetting(_ tabContainerView: UIView)
    
    // 颜色
    func tabBgColor() -> UIColor
    func tabContainerColor() -> UIColor
    func tabContentColor() -> UIColor
    
    // 默认第一个加载的 tab
    func firstTabItemIndex() -> Int
    
    func tabItemCanInteraction(at index: Int) -> Bool
    
    // 指示线
    func needIndicator() -> Bool
    func indicatorBottom() -> CGFloat
    func indicatorWidth(at index: Int) -> CGFloat
    func indicatorColor(at index: Int) -> UIColor
    
}

protocol BQTabDelegate: class {
    
    // 页面切换已在 BQTabcontroller 实现
    func didClickTabItem(at index: Int)
    
}
