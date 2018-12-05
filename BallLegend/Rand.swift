//
//  Rand.swift
//  BallLegend
//
//  Created by Anthony Cheng on 12/4/18.
//  Copyright © 2018 Anthony Cheng. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat {
    public static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    public static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
}
