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
    func controller(at index: Int) -> UIViewController?
    
    // Page 的 View 的大小 (默认情况下是整屏幕.通常情况下，cover 在最上面 tab 在中间 page 在下面的情况不用设这个 frame)
    func pageFrame() -> CGRect
    
    // 第一个展示的 item
    func pageFirstIndex() -> Int
    
    
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
    
    func pageFirstIndex() -> Int {
        return 0
    }
    
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
    
    func numberOfControllers() -> Int {
        return 0
    }
    
    func controller(at index: Int) -> UIViewController? {
        return nil
    }
    
    func subpageTopInset(at index: Int) -> CGFloat {
        return 0
    }
    
    func needPreload() -> Bool {
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
    
    /// 标题
    func title(at index: Int) -> String
    
    /// 标题字体
    func titleFont(at index: Int) -> UIFont
    
    /// 标题默认颜色
    func titleColor(at index: Int) -> UIColor
    
    /// 标题高亮颜色
    func titleHightlightColor(at index: Int) -> UIColor
    
    /// Item 的个数
    func numberOfItem() -> Int
    
    /// 单个 Tab 是否需要显示
    func singleTabShow() -> Bool
    
    /// 自定义 Tab View
    func customTabView() -> UIView?
    
    // Tab 的属性
    func tapTop() -> CGFloat
    func tapLeft() -> CGFloat
    func tabWidth() -> CGFloat
    
    // 假设每一个 Item 的顶部都可变的情况
    func tabItemTop(at index: Int) -> CGFloat
    
    // 假设每一个 Item 宽度都可变的情况
    func tabItemWidth(at index: Int) -> CGFloat
    
    // 假设每一个 Item 高度都可变的情况
    func tabItemHeight(at index: Int) -> CGFloat
    
    // 设置 tabBgView
    func tabBackgroundViewSetting(_ tabBgView: UIView)
    
    // 设置 tabContainerView
    func tabContainerViewSetting(_ tabContainerView: UIView)
    
    // 设置 tabView
    func tabContentViewSetting(_ tabView: UIView)
    
    // 假设每一个 Item 可以单独设置
    func tabItemSetting(_ item: UIControl, at index: Int)
    
    // 颜色
    func tabBgColor() -> UIColor
    func tabContainerColor() -> UIColor
    func tabContentColor() -> UIColor
    
    // 默认第一个加载的 Tab Item
    func firstTabItemIndex() -> Int
    
    /// Item 是否可以交互
    func tabItemCanInteraction(at index: Int) -> Bool
    
    // 指示线
    func needIndicator() -> Bool
    func indicatorBottom() -> CGFloat
    func indicatorWidth(at index: Int) -> CGFloat
    func indicatorColor(at index: Int) -> UIColor
    
}

extension BQTabDataSource {
    
    func title(at index: Int) -> String {
        return ""
    }
    
    func titleFont(at index: Int) -> UIFont {
        return UIFont.systemFont(ofSize: 13)
    }
    
    func titleColor(at index: Int) -> UIColor {
        return .gray
    }
    
    func titleHightlightColor(at index: Int) -> UIColor {
        return .black
    }
    
    func numberOfItem() -> Int {
        return 0
    }
    
    func singleTabShow() -> Bool {
        return false
    }
    
    func customTabView() -> UIView? {
        return nil
    }
    
    func tapTop() -> CGFloat {
        return .statusBarHeight + .navigationBarHeight
    }
    
    func tapLeft() -> CGFloat {
        return 0
    }
    
    func tabWidth() -> CGFloat {
        return .screenWidth
    }
    
    func tabItemTop(at index: Int) -> CGFloat {
        return 0
    }
    
    func tabItemWidth(at index: Int) -> CGFloat {
        return title(at: index).count > 3 ? 100 : 70
    }
    
    func tabItemHeight(at index: Int) -> CGFloat {
        return 35.VScale
    }
    
    func tabBgColor() -> UIColor {
        return .white
    }
    
    func tabContainerColor() -> UIColor {
        return .clear
    }
    
    func tabContentColor() -> UIColor {
        return .white
    }
    
    func tabBackgroundViewSetting(_ tabBgView: UIView) { }
    
    func tabContainerViewSetting(_ tabContainerView: UIView) { }
    
    func tabContentViewSetting(_ tabView: UIView) { }
    
    func tabItemSetting(_ item: UIControl, at index: Int) { }
    
    func firstTabItemIndex() -> Int {
        return 0
    }
    
    func tabItemCanInteraction(at index: Int) -> Bool {
        return true
    }
    
    func needIndicator() -> Bool {
        return true
    }
    
    func indicatorBottom() -> CGFloat {
        return 0
    }
    
    func indicatorWidth(at index: Int) -> CGFloat {
        return (title(at: index) as NSString).boundingRect(with: CGSize(width: 100, height: 50), options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: titleFont(at: index)], context: nil).size.width
    }
    
    func indicatorColor(at index: Int) -> UIColor {
        return .red
    }
    
}

protocol BQTabDelegate: class {
    
    // 页面切换已在 BQTabcontroller 实现
    func didClickTabItem(at index: Int)
    
}
