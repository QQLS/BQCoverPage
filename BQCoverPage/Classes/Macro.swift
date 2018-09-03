//
//  Macro.swift
//  BQTabController
//
//  Created by QQLS on 2018/8/22.
//

import UIKit

public extension UIDevice {
    
//    public static let iPhone4: Bool = UIScreen.main.bounds.height == 480
//
//    public static let iPhone5: Bool = UIScreen.main.bounds.height == 568
//
//    public static let iPhone6: Bool = UIScreen.main.bounds.height == 667

//    public static let iPhonePlus: Bool = UIScreen.main.bounds.height == 736
    
    public static let iPhoneX: Bool = UIScreen.main.bounds.height == 812
    
}

public extension CGRect {
    
    /// Screen frame
    public static let screen: CGRect = UIScreen.main.bounds
    
}

public extension CGSize {
    
    /// Screen size
    public static let screen: CGSize = CGRect.screen.size
    
}

// FloatingPoint
public extension CGFloat {
    
    /// Status Bar
    public static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    
    /// Home Indicator
    public static let indicatorHeight: CGFloat = UIDevice.iPhoneX ? 34 : 0
    
    /// Navigation Bar
    public static let navigationBarHeight: CGFloat = 44
    
    /// Tab Bar
    public static let tabBarHeight: CGFloat = 49 + indicatorHeight
    
    /// Screen width
    public static let screenWidth: CGFloat = CGSize.screen.width
    
    /// Screen height
    public static let screenHeight: CGFloat  = CGSize.screen.height
    
    /// Top height = statusBarHeight + navigationBarHeight
    public static let topHeight: CGFloat  = .statusBarHeight + .navigationBarHeight
    
    public var HScale: CGFloat {
        if CGFloat.screenWidth == 375 { return self }
        
        let result = (self >= 0 ? self : -self) / 375.0 * CGFloat.screenWidth
        return self >= 0 ? floor(result) : -floor(result)
    }
    
    public var VScale: CGFloat {
        if CGFloat.screenHeight == 667 { return self }
        
        let result = (self >= 0 ? self : -self) / 667.0 * CGFloat.screenHeight
        return self >= 0 ? floor(result) : -floor(result)
    }
    
}

extension Int {
    
    public var HScale: CGFloat {
        if CGFloat.screenWidth == 375 { return CGFloat(self) }
        
        let result = CGFloat(self >= 0 ? self : -self) / 375.0 * CGFloat.screenWidth
        return self >= 0 ? floor(result) : -floor(result)
    }
    
    public var VScale: CGFloat {
        if CGFloat.screenHeight == 667 { return CGFloat(self) }
        
        let result = CGFloat(self >= 0 ? self : -self) / 667.0 * CGFloat.screenHeight
        return self >= 0 ? floor(result) : -floor(result)
    }
    
}

