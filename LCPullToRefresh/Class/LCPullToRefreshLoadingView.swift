//
//  LCPullToRefreshLoadingView.swift
//  LCPullToRefresh
//
//  Created by Leo on 10/29/15.
//  Copyright © 2015 leo.chang. All rights reserved.
//

import UIKit

public class LCPullToRefreshLoadingView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK: -  Vars
    
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clearColor().CGColor
        maskLayer.fillColor = UIColor.blackColor().CGColor
        maskLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        self.layer.mask = maskLayer
        return maskLayer
    }()
    
    //MARK: - Constructors
    
    public init() {
        super.init(frame : .zero)
    }
    
    public override init(frame : CGRect) {
        super.init(frame : .zero)
    }
    
    required public init?(coder aDecoder : NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    public func setPullProgress(progress : CGFloat) {
        
    }
    
    public func startAnimating() {
        
    }
    
    public func stopLoading() {
        
    }
}
