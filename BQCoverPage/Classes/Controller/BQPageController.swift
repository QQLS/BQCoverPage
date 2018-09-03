//
//  BQPageController.swift
//  BQTabController
//
//  Created by QQLS on 2018/8/22.
//

import UIKit

class BQPageController: UIViewController {
    
    private enum PageScrollDirection {
        case left
        case right
    }
    
    private let kContentOffsetKey = "contentOffset"
    
    weak var delegate: BQPageDelegate?
    weak var dataSource: BQPageDataSource?
    
    private var memoryCaches: [Int: UIViewController] = [:]
    private var lastContentOffsets: [Int: CGFloat] = [:]
    private var lastContentSizes: [Int: CGFloat] = [:]
    
    private var contentView = BQPageContentView()
    
    var willToIndex: Int = 0
    var guessToIndex: Int = 0
    var originOffsetX: CGFloat = 0
    var lastSelectedIndex: Int = 0
    
    var firstWillAppear = true
    var firstDidAppear = true
    var firstWillLayoutSubViews = true
    
    private(set) var currentPageIndex: Int = 0
    
    lazy var pageCount: Int = self.dataSource?.numberOfControllers() ?? 0
    lazy var needPreload: Bool = self.dataSource?.needPreload() ?? true
    
    deinit {
        delegate = nil
        dataSource = nil
        clearObserver()
        memoryCaches.removeAll()
    }
    
}

// MARK: - Lifecycle
extension BQPageController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        contentView = BQPageContentView(frame: view.bounds)
        contentView.delegate = self
        view.addSubview(contentView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstWillAppear {
            delegate?.pageController(self, willLeave: controller(at: lastSelectedIndex), toVC: controller(at: currentPageIndex))
            if let gesture = dataSource?.screenEdgePanGestureRecognizer() {
                contentView.panGestureRecognizer.require(toFail: gesture)
            } else if let gesture = screenEdgePanGestureRecognizer() {
                contentView.panGestureRecognizer.require(toFail: gesture)
            }
            firstWillAppear = false
            updateContentViewLayoutIfNeeded()
        }
        controller(at: currentPageIndex).beginAppearanceTransition(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstDidAppear {
            delegate?.willChangeInit()
            delegate?.pageController(self, didLeave: controller(at: lastSelectedIndex), toVC: controller(at: currentPageIndex))
            firstDidAppear = false
        }
        controller(at: currentPageIndex).endAppearanceTransition()
    }
    
}

// MARK: - Override
extension BQPageController {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearMemory()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if firstWillLayoutSubViews {
            updateContentViewLayoutIfNeeded()
            updateContentViewDisplayIndexIfNeed()
            firstWillLayoutSubViews = false
        } else {
            updateContentViewLayoutIfNeeded()
        }
    }
    
}

// MARK: - Interface
extension BQPageController {
    
    // 必须在 reloadpage 之前把 datasource 回调的 pageCount 变了
    func reloadPage() {
        clearMemory()
        
        addControllerToShow(at: currentPageIndex)
        
        // 先计算一次布局
        updateContentViewLayoutIfNeeded()
        // 告诉外部将要改变
        delegate?.willChangeInit()
        // 高度外部是从哪到哪
        if let fromVC = dataSource?.controller(at: lastSelectedIndex),
            let toVC = dataSource?.controller(at: currentPageIndex) {
            delegate?.pageController(self, willLeave: fromVC, toVC: toVC)
        }
        // 再次计算布局
        updateContentViewLayoutIfNeeded()
        
        // 显示
        showSubpage(at: currentPageIndex, animated: true)
    }
    
    // 用于非交互切换接口
    func showSubpage(at index: Int, animated: Bool) {
        if index < 0 || index > pageCount { return }
        
        if contentView.frame.size.width <= 0 || contentView.contentSize.width <= 0 { return }
        
        // 更改记录的值
        let oldSelectIndex = lastSelectedIndex
        lastSelectedIndex = currentPageIndex
        currentPageIndex = index
        
        delegate?.willChangeInit()
        if let fromVC = dataSource?.controller(at: lastSelectedIndex),
            let toVC = dataSource?.controller(at: currentPageIndex) {
            delegate?.pageController(self, willLeave: fromVC, toVC: toVC)
        }
        addControllerToShow(at: index)
        
        beginAnimation(animated)
        if animated {
            if currentPageIndex != currentPageIndex { // 如果非交互切换的 index 和 current index 一样, 则什么都不做
                var pageSize = contentView.frame.size
                let direction: PageScrollDirection = currentPageIndex > lastSelectedIndex ? .right : .left
                let lastView = controller(at: lastSelectedIndex).view
                let currentView = controller(at: currentPageIndex).view
                lastView?.alpha = 1
                currentView?.alpha = 1
                
                // oldselectindex 就是第一个动画选择的 index
                let oldSelectView = controller(at: oldSelectIndex).view
                let backgroundIndex = contentView.index(with: contentView.contentOffset.x, width: contentView.frame.size.width)
                var backgroundView: UIView? = nil
                // 这里考虑的是第一次动画还没结束, 就开始第二次动画, 需要把当前的处的位置的 view 给隐藏掉, 避免出现一闪而过的情形.
                
                if !(oldSelectView?.layer.animationKeys()?.isEmpty ?? true) && !(lastView?.layer.animationKeys()?.isEmpty ?? true) {
                    let tmpView = controller(at: backgroundIndex).view
                    if tmpView != currentView && tmpView != lastView {
                        backgroundView = tmpView
                        backgroundView?.isHidden = true
                    }
                }
                
                // 这里考虑的是第一次动画还没结束, 就开始第二次动画, 需要把之前的动画给结束掉, oldselectindex 就是第一个动画选择的 index
                contentView.layer.removeAllAnimations()
                oldSelectView?.layer.removeAllAnimations()
                lastView?.layer.removeAllAnimations()
                currentView?.layer.removeAllAnimations()
                // 这里需要还原第一次切换的 view 的位置
                moveToOriginalPosition(for: oldSelectView, at: index)
                
                // 下面就是 lastview 切换到 currentview 的代码, direction 则是切换的方向, 这里把 lastview 和 currentview 起始放到了相邻位置在动画结束的时候, 还原位置.
                contentView.bringSubview(toFront: lastView!)
                contentView.bringSubview(toFront: currentView!)
                
                lastView?.isHidden = false
                currentView?.isHidden = false
                
                let lastViewStartOrigin = lastView?.frame.origin
                var currentViewStartOrigin = lastViewStartOrigin
                let offset = direction == .right ? contentView.frame.size.width : -contentView.frame.size.width
                currentViewStartOrigin?.x += offset
                
                var lastViewAnimationOrgin = lastViewStartOrigin;
                lastViewAnimationOrgin?.x -= offset
                let currentViewAnimationOrgin = lastViewStartOrigin
                let lastViewEndOrigin = lastViewStartOrigin
                let currentViewEndOrgin = currentView?.frame.origin
                
                lastView?.frame = CGRect(x: lastViewStartOrigin?.x ?? 0, y: lastViewStartOrigin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                currentView?.frame = CGRect(x: currentViewStartOrigin?.x ?? 0, y: currentViewStartOrigin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                
                let duration = 0.3
                UIView.animate(withDuration: duration, animations: {
                    lastView?.frame = CGRect(x: lastViewAnimationOrgin?.x ?? 0, y: lastViewAnimationOrgin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                    currentView?.frame = CGRect(x: currentViewAnimationOrgin?.x ?? 0, y: currentViewAnimationOrgin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                }) { (finished) in
                    if (finished) {
                        lastView?.alpha = 0
                        currentView?.alpha = 1
                        
                        pageSize = self.contentView.frame.size
                        lastView?.frame = CGRect(x: lastViewEndOrigin?.x ?? 0, y: lastViewEndOrigin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                        currentView?.frame = CGRect(x: currentViewEndOrgin?.x ?? 0, y: currentViewEndOrgin?.y ?? 0, width: pageSize.width, height: pageSize.height)
                        
                        backgroundView?.isHidden = false
                        self.moveToOriginalPosition(for: currentView, at: self.currentPageIndex)
                        self.moveToOriginalPosition(for: lastView, at: self.lastSelectedIndex)
                        self.scrollAnimation(animated)
                        self.endAnimation(animated)
                    }
                }
            } else {
                scrollAnimation(animated)
                endAnimation(animated)
            }
        } else {
            scrollAnimation(animated)
            endAnimation(animated)
        }
    }
    
    // 在 tabItem 高度可变的情况, 需要去动态修改 tableView 的 contentInset
    func resizePage(at index: Int, offset: CGFloat, needChangeOffset: Bool, changeOffset atBeginOffsetChange: Bool) {
        if let controller = controller(at: index) as? BQSubpageDataSource, let scrollView = controller.bqScrollView() {
            let atBeginOffset = scrollView.contentOffset.y == -(scrollView.contentInset.top)
            let contentOffset = scrollView.contentOffset
            scrollView.contentInset = UIEdgeInsets(top: dataSource?.subpageTopInset(at: index) ?? 0, left: scrollView.contentInset.left, bottom: scrollView.contentInset.bottom, right: scrollView.contentInset.right)
            scrollView.contentOffset = contentOffset
            if needChangeOffset {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: offset)
            } else {
                if atBeginOffset && atBeginOffsetChange {
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: offset)
                }
            }
        }
    }
    
    // 获取指定 Controller 的索引
    func index(of controller: UIViewController) -> Int {
        for memory in memoryCaches {
            if controller === memory.value {
                return memory.key
            }
        }
        return -1
    }
    
    /// 更新当前选中的索引
    func updateCurrent(at index: Int) {
        currentPageIndex = index
    }
    
}

// MARK: - UIScrollViewDelegate
extension BQPageController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging && scrollView === contentView {
            let offsetX = scrollView.contentOffset.x
            let width = scrollView.frame.size.width
            let lastGuestIndex = guessToIndex < 0 ? currentPageIndex : guessToIndex
            
            if originOffsetX < offsetX {
                guessToIndex = Int(ceil(offsetX / width))
            } else {
                guessToIndex = Int(floor(offsetX / width))
            }
            
            if needPreload {
                if lastGuestIndex != guessToIndex && guessToIndex != currentPageIndex && guessToIndex >= 0 && guessToIndex < pageCount {
                    delegate?.willChangeInit()
                    
                    let fromVC = controller(at: currentPageIndex)
                    let toVC = controller(at: guessToIndex)
                    fromVC.view.alpha = 1
                    toVC.view.alpha = 1
                    delegate?.pageController(self, willTransition: fromVC, toVC: toVC)
                    toVC.beginAppearanceTransition(true, animated: true)
                    if lastGuestIndex == currentPageIndex {
                        fromVC.beginAppearanceTransition(false, animated: true)
                    }
                    if lastGuestIndex != currentPageIndex && lastGuestIndex >= 0 && lastGuestIndex < pageCount {
                        let lastGestVC = controller(at: lastGuestIndex)
                        lastGestVC.beginAppearanceTransition(false, animated: true)
                        lastGestVC.endAppearanceTransition()
                    }
                }
            } else {
                if (guessToIndex != currentPageIndex && !scrollView.isDecelerating) || scrollView.isDecelerating {
                    if lastGuestIndex != guessToIndex && guessToIndex >= 0 && guessToIndex < pageCount {
                        delegate?.willChangeInit()
                        delegate?.pageController(self, willTransition: memoryCaches[currentPageIndex]!, toVC: memoryCaches[guessToIndex]!)
                    }
                }
            }
            
            delegate?.contentOffsetRatio(scrollView.contentOffset.x / contentView.frame.size.width, isDragging: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            originOffsetX = scrollView.contentOffset.x
            guessToIndex = currentPageIndex
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageViewAfterDragging(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.contentOffsetRatio(targetContentOffset.pointee.x / scrollView.frame.size.width, isDragging: false)
    }
    
}

// MARK: - Helpers
private extension BQPageController {
    
    func clearMemory() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        lastContentSizes.removeAll()
        lastContentOffsets.removeAll()
        
        clearObserver()
        let allValues = memoryCaches.values
        memoryCaches.removeAll()
        for controller in allValues {
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
        
    }
    
    func clearObserver() {
        memoryCaches.forEach {
            if let controller = $0.value as? BQSubpageDataSource, let scrollView = controller.bqScrollView() {
                scrollView.removeObserver(self, forKeyPath: kContentOffsetKey)
            }
        }
    }
    
    func visibleControllerFrame(at index: Int) -> CGRect {
        return CGRect(x: CGFloat(index) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    func addControllerToShow(at index: Int) {
        if index < 0 || index > pageCount { return }
        
        let subpageController = controller(at: index)
        let subpageFrame = visibleControllerFrame(at: index)
        if !childViewControllers.contains(subpageController) {
            addChildViewController(subpageController)
            subpageController.didMove(toParentViewController: self)
        }
        super.addChildViewController(subpageController)
        subpageController.view.frame = subpageFrame
        contentView.addSubview(subpageController.view)
    }
    
    func controller(at index: Int) -> UIViewController {
        if memoryCaches[index] == nil, let controller = dataSource?.controller(at: index) {
            controller.view.isHidden = !(dataSource?.subpageCanScroll(at: index) ?? true)
            if let subpage = controller as? BQSubpageDataSource, let scrollView = subpage.bqScrollView() {
                scrollView.scrollsToTop = false
                scrollView.tag = index
                
                if let topInset = dataSource?.subpageTopInset(at: index) {
                    let oldInsets = scrollView.contentInset
                    let newInsets = UIEdgeInsets(top: topInset, left: oldInsets.left, bottom: oldInsets.bottom, right: oldInsets.right)
                    scrollView.contentInset = newInsets
                    if #available(iOS 11.0, *) {
                        scrollView.contentInsetAdjustmentBehavior = .never
                    }
                }
                
                scrollView.addObserver(self, forKeyPath: kContentOffsetKey, options: [.initial, .new], context: nil)
                contentView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            }
            
            memoryCaches[index] = controller
            addControllerToShow(at: index)
        }
        
        return memoryCaches[index]!
    }
    
    func updateContentViewLayoutIfNeeded() {
        if contentView.frame.size.width > 0 {
            contentView.updateLayoutIfNeeded(dataSource)
        }
    }
    
    func updateContentViewDisplayIndexIfNeed() {
        if contentView.frame.size.width > 0 {
            addControllerToShow(at: currentPageIndex)
            let newOffset = contentView.offset(at: currentPageIndex, width: contentView.frame.size.width, maxWidth: contentView.contentSize.width)
            if newOffset != contentView.contentOffset {
                contentView.contentOffset = newOffset
            }
            controller(at: currentPageIndex).view.frame = visibleControllerFrame(at: currentPageIndex)
        }
    }
    
    func scrollAnimation(_ animated: Bool) {
        contentView.setContentOffset(contentView.offset(at: currentPageIndex, width: contentView.frame.size.width, maxWidth: contentView.contentSize.width), animated: animated)
    }
    
    func beginAnimation(_ animated: Bool) {
        controller(at: currentPageIndex).beginAppearanceTransition(true, animated: animated)
        if currentPageIndex != lastSelectedIndex {
            controller(at: lastSelectedIndex).beginAppearanceTransition(false, animated: animated)
        }
    }
    
    func endAnimation(_ animated: Bool) {
        controller(at: currentPageIndex).endAppearanceTransition()
        if currentPageIndex != lastSelectedIndex {
            controller(at: lastSelectedIndex).endAppearanceTransition()
        }
        delegate?.pageController(self, didLeave: controller(at: lastSelectedIndex), toVC: controller(at: currentPageIndex))
    }
    
    func moveToOriginalPosition(for view: UIView?, at index: Int) {
        guard index >= 0 && index < pageCount, let view = view else { return }
        
        let originalPosition = contentView.offset(at: index, width: contentView.frame.size.width, maxWidth: contentView.contentSize.width)
        if view.frame.origin.x != originalPosition.x {
            var newFrame = view.frame
            newFrame.origin = originalPosition
            view.frame = newFrame
        }
    }
    
    func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer? {
        var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer? = nil
        if let gestureRecognizers = navigationController?.view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer is UIScreenEdgePanGestureRecognizer {
                    screenEdgePanGestureRecognizer = recognizer as? UIScreenEdgePanGestureRecognizer
                    break
                }
            }
        }
        return screenEdgePanGestureRecognizer
    }
    
    func updatePageViewAfterDragging(_ scrollView: UIScrollView) {
        let newIndex = contentView.index(with: scrollView.contentOffset.x, width: scrollView.frame.size.width)
        let oldIndex = currentPageIndex
        currentPageIndex = newIndex
        
        if newIndex == oldIndex {
            if guessToIndex >= 0 && guessToIndex < pageCount {
                controller(at: oldIndex).beginAppearanceTransition(true, animated: true)
                controller(at: oldIndex).endAppearanceTransition()
                
                controller(at: guessToIndex).beginAppearanceTransition(true, animated: true)
                controller(at: guessToIndex).endAppearanceTransition()
            }
        } else {
            if !needPreload {
                controller(at: newIndex).beginAppearanceTransition(true, animated: true)
                controller(at: oldIndex).beginAppearanceTransition(false, animated: true)
            }
            controller(at: newIndex).endAppearanceTransition()
            controller(at: oldIndex).endAppearanceTransition()
        }
        
        originOffsetX = scrollView.contentOffset.x
        guessToIndex = currentPageIndex
        delegate?.pageController(self, didTransition: controller(at: lastSelectedIndex), toVC: controller(at: currentPageIndex))
    }
    
}

// MARK: - KVO
extension BQPageController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else { return }
        
        let index = scrollView.tag
        if keyPath == kContentOffsetKey {
            if scrollView.tag != currentPageIndex { return }
            if memoryCaches.isEmpty { return }
            
        }
        let isNotNeedChangeContentOffset = scrollView.contentSize.height < .screenHeight - .navigationBarHeight - .statusBarHeight && fabs((lastContentSizes[index] ?? 0) - scrollView.contentSize.height) > 1.0
        if (delegate?.cannotScrollWithPageOffset() ?? true) || isNotNeedChangeContentOffset {
            if fabs((lastContentOffsets[index] ?? 0) - scrollView.contentOffset.y) > 1.0 {
                scrollView.contentOffset = CGPoint(x: 0, y: (lastContentOffsets[index] ?? 0))
            }
        } else {
            lastContentOffsets[index] = scrollView.contentOffset.y
            delegate?.pageOffset(scrollView.contentOffset.y, index: index)
        }
        lastContentSizes[index] = scrollView.contentSize.height
    }
    
}
