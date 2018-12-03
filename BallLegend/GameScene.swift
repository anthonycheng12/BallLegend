//
//  GameScene.swift
//  BallLegend
//
//  Created by Anthony Cheng on 12/3/18.
//  Copyright © 2018 Anthony Cheng. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    var didGameStarted = Bool(false)
    var didDied = Bool(false)
    let buzzSound = SKAction.playSoundFileNamed("buzzer.mp3", waitForCompletion: false)
    
    var score = Int(0)
    var scoreLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var taptoplayLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var pauseButton = SKSpriteNode()
    var logoImage = SKSpriteNode()
    var obstaclePair = SKNode()
    var moveAndRemove = SKAction()
    
    //CREATE THE PLAYER ATLAS FOR ANIMATION
    let playerAtlas = SKTextureAtlas(named:"player")
    var playerSprites = Array<SKTexture>()
    var player = SKSpriteNode()
    var repeatPlayerAction = SKAction()
    
    override func didMove(to view: SKView) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func createScene(){
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory // to get information on contact with player and obstacle
        self.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory // to get information on contact with player and obstacle
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false // prevents player from falling off the screen
        
        self.physicsWorld.contactDelegate = self // helps detect contact and collisions
        // self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    }
}
