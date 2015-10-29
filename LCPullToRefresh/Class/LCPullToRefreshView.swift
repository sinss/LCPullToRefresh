//
//  LCPullToRefreshView.swift
//  LCPullToRefresh
//
//  Created by Leo on 10/29/15.
//  Copyright © 2015 leo.chang. All rights reserved.
//

import UIKit
import ObjectiveC

//MARK: - PullToRefreshState

public enum LCPullToRefreshState : Int {
    case Stopped
    case Dragging
    case AnimatingBounce
    case Loading
    case AnimatingToStopped
    
    func isAnyOf(values : [LCPullToRefreshState]) -> Bool {
        return values.contains({ $0 == self })
    }
}

public class LCPullToRefreshView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: - Vars
    private var _state : LCPullToRefreshState = .Stopped
    
    private(set) var state : LCPullToRefreshState {
        get {return _state}
        set {
            let previousValue = state
            _state = newValue
            
            if previousValue == .Dragging && previousValue == .AnimatingBounce {
                loadingView?.startAnimating()
            }
            else if newValue == .Loading && actionHandler != nil {
                actionHandler()
            }
            else if newValue == .AnimatingToStopped {
                
            }
            else if newValue == .Stopped {
                loadingView?.stopLoading()
            }
        }
    }
    
    private var originalContentInsetTop: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    private let shapLayer = CAShapeLayer()
    
    
    private var displayLink: CADisplayLink!
    
    //a callback handler
    var actionHandler: (() -> Void)!
    
    var loadingView : LCPullToRefreshLoadingView? {
        willSet {
            loadingView?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
            }
        }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = scrollView() else { return }
            if observing {
                scrollView.lc_addObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.lc_addObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.contentInset)
                scrollView.lc_addObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.Frame)
                scrollView.lc_addObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            }
            else {
                scrollView.lc_removeObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.ContentOffset)
                scrollView.lc_removeObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.contentInset)
                scrollView.lc_removeObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.Frame)
                scrollView.lc_removeObserver(self, forKeyPath: LCPullToRefreshConstants.KeyPaths.PanGestureRecognizerState)
            }
        }
    }
    
    var fillColor: UIColor = .clearColor() {
        didSet {
            shapLayer.fillColor = fillColor.CGColor
        }
    }
    
    private let bounceAnimationHelperView = UIView()
    
    private let cControlPointview = UIView()
    private let l1ControlPointView = UIView()
    private let l2ControlPointView = UIView()
    private let l3ControlPointView = UIView()
    private let r1ControlPointView = UIView()
    private let r2ControlPointView = UIView()
    private let r3ControlPointView = UIView()
    
    
    //MARK: - Contructors
    init() {
        super.init(frame : .zero)
        
        displayLink = CADisplayLink(target: self, selector: Selector("displayLinkTick"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        shapLayer.backgroundColor = UIColor.clearColor().CGColor
        shapLayer.fillColor = UIColor.blackColor().CGColor
        shapLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        layer.addSublayer(shapLayer)
        
        addSubview(bounceAnimationHelperView)
        addSubview(cControlPointview)
        addSubview(l1ControlPointView)
        addSubview(l2ControlPointView)
        addSubview(l3ControlPointView)
        addSubview(r1ControlPointView)
        addSubview(r2ControlPointView)
        addSubview(r3ControlPointView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == LCPullToRefreshConstants.KeyPaths.ContentOffset {
            if let newContentOffsetY = change?[NSKeyValueChangeNewKey]?.CGPointValue.y, let scrollView = scrollView() {
                if state.isAnyOf([.Loading, .AnimatingToStopped]) && newContentOffsetY < -scrollView.contentInset.top {
                    scrollView.lc_stopScrollingAnimation()
                    scrollView.contentOffset.y = -scrollView.contentOffset.top
                }
                else {
                    
                }
                layoutSubviews()
            }
        }
        else if keyPath == LCPullToRefreshConstants.KeyPaths.contentInset {
            
        }
        else if keyPath == LCPullToRefreshConstants.KeyPaths.Frame {
            
        }
        else if keyPath == LCPullToRefreshConstants.KeyPaths.PanGestureRecognizerState {
            
        }
    }
    
    // MARK: - Notifications
    
    func applicationWillEnterForeground() {
        if state == .Loading {
            layoutSubviews()
        }
    }

    
    //MARK: - Public Methods
    
    func stopLoading() {
        
    }
    
    //MARK - Private Methods
    
    private func scrollView() -> UIScrollView? {
        return superview as? UIScrollView
    }
    
    private func isAnimating() -> Bool {
        return state.isAnyOf([.AnimatingBounce, .AnimatingToStopped])
    }

    private func actualContentOffsetY() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0)
    }
    
    private func currentHeignt() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
    }
    
    private func currentWaveHeight() -> CGFloat {
        return min(bounds.height / 3.0 * 1.6, LCPullToRefreshConstants.WaveMaxHeight)
    }
    
    private func currentPath() -> CGPath {
        let width: CGFloat = scrollView()?.bounds.width ?? 0.0
        
        let bezierPath = UIBezierPath()
        let animating = isAnimating()
        
        bezierPath.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLineToPoint(CGPoint(x: 0.0, y: l3ControlPointView.lc_center(animating).y))
        bezierPath.addCurveToPoint(l1ControlPointView.lc_center(animating), controlPoint1: l3ControlPointView.lc_center(animating), controlPoint2: l2ControlPointView.lc_center(animating))
        bezierPath.addCurveToPoint(r1ControlPointView.lc_center(animating), controlPoint1: cControlPointview.lc_center(animating), controlPoint2: r1ControlPointView.lc_center(animating))
        bezierPath.addCurveToPoint(r3ControlPointView.lc_center(animating), controlPoint1: r1ControlPointView.lc_center(animating), controlPoint2: r2ControlPointView.lc_center(animating))
        bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }

    private func scrollViewDidChangeContentOffset(dragging dragging : Bool) {
        
    }
    private func resetScrollViewContentInset(shouldAddOBserverWhenFinished shouldAddObserverWhtnFinihsed : Bool, animated: Bool, completion:(()->())? ) {
        
    }
    
    private func animateBounce() {
    
    }
    
    private func startDisplayLink() {
        
    }
    
    private func stopdisplayLink() {
        
    }
    
    func displayLinkTick() {
        
    }
    
    //MARK: - Layout
    private func layoutLoadingView() {
        
    }
    
    override public func layoutSubviews() {
        
    }
}

public extension NSObject {
    
    //MARK: - Vars
    private struct lc_associatedKeys {
        static var observersArray = "observers"
    }
    
    private var lc_observers: [[String : NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &lc_associatedKeys.observersArray) as? [[String : NSObject]] {
                return observers
            } else {
                let observers = [[String : NSObject]]()
                self.lc_observers = observers
                return observers
            }
        }
        
        set {
            objc_setAssociatedObject(self , &lc_associatedKeys.observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func lc_addObserver(observer : NSObject, forKeyPath keyPath:String) {
        let observerInfo = [keyPath : observer]
        
        if lc_observers.indexOf({ $0 == observerInfo }) == nil {
            lc_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .New, context: nil)
        }
    }
    
    public func lc_removeObserver(observer : NSObject, forKeyPath keyPath : String) {
        let observerInfo = [keyPath : observer]
        
        if let index = lc_observers.indexOf({ $0 == observerInfo }) {
            lc_observers.removeAtIndex(index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
}

public extension UIScrollView {
    
    //MARK: - Vars
    private struct lc_associatedKeys {
        static var pullToRefreshView = "pullToRefreshView"
    }
    
    private var _pullToRefreshView : LCPullToRefreshView? {
        get {
            if let pullToRefreshView = objc_getAssociatedObject(self, &lc_associatedKeys.pullToRefreshView) as? LCPullToRefreshView {
                return pullToRefreshView
            }
            
            return nil
        }
        
        set {
            objc_setAssociatedObject(self, &lc_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var pullToRefershView: LCPullToRefreshView! {
        get {
            if let pullToRefershView = _pullToRefreshView {
                return pullToRefershView
            }
            else {
                let pullToRefreshView = LCPullToRefreshView()
                _pullToRefreshView = pullToRefreshView
                return pullToRefreshView
            }
        }
    }
    
    //MARK: - Methods (Public)
    public func lc_addPullToRefreshWithActionHandler(actionHandler: () -> Void) {
        lc_addPullToRefreshWithActionHandler(actionHandler, loadingView: nil)
    }
    
    public func lc_addPullToRefreshWithActionHandler(actionHandler: () -> Void, loadingView : LCPullToRefreshLoadingView?) {
        multipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1
        pullToRefershView.actionHandler = actionHandler
        pullToRefershView.loadingView = loadingView
        
        addSubview(pullToRefershView)
        
        pullToRefershView.observing = true
    }
    
    public func lc_removePullToRefresh() {
        pullToRefershView.observing = false
        pullToRefershView.removeFromSuperview()
    }
    
    public func lc_setPullToRefershBackgroundcolor(color : UIColor) {
        pullToRefershView.backgroundColor = color
    }
    
    public func lc_setPullToRefreshFillColor(color : UIColor) {
        pullToRefershView.fillColor = color
    }
    
    public func lc_stopLoading() {
        pullToRefershView.stopLoading()
    }
    
    func lc_stopScrollingAnimation() {
        if let superview = self.superview, let index = superview.subviews.indexOf({ $0 == self }) as Int! {
            removeFromSuperview()
            superview.insertSubview(self, atIndex: index)
        }
    }
}

public extension UIView {
    func lc_center(usePresentationLayerIfPossible : Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentationLayer() as? CALayer {
            return presentationLayer.position
        }
        return center
    }
}

public extension UIPanGestureRecognizer {
    func lc_resign() {
        enabled = false
        enabled = true
    }
}

public extension UIGestureRecognizerState {
    func lc_isAnyOf(values : [UIGestureRecognizerState]) -> Bool {
        return values.contains({ $0 == self })
    }
}
