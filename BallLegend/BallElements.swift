//
//  BallElements.swift
//  BallLegend
//
//  Created by Anthony Cheng on 12/3/18.
//  Copyright © 2018 Anthony Cheng. All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let playerCategory:UInt32 = 0x1 << 0
    static let obstacleCategory:UInt32 = 0x1 << 1
    static let basketballCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene {
}
