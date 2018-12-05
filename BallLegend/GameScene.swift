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
    let playerAtlas = SKTextureAtlas(named:"player")
    var playerSprites = Array<SKTexture>()
    var player = SKSpriteNode()
    var repeatPlayerAction = SKAction()
    
    // CHRIS'S CODE
    var stephButton = SKSpriteNode()
    var larryButton = SKSpriteNode()
    var wadeButton = SKSpriteNode()
    var playerChoice = "larry"
    // ENDS HERE

    override func didMove(to view: SKView) {
        createScene()
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if didGameStarted == false{
            
            
            // CHRIS'S CODE
            for touch in touches{
                let location = touch.location(in: self)
                if (stephButton.contains(location)){
                    playerChoice = "steph"
                    print ("chose steph")
                }
                else if (larryButton.contains(location)){
                    playerChoice = "larry"
                    print ("chose larry")
                }
                else if (wadeButton.contains(location)){
                    playerChoice = "wade"
                    print ("chose wade")
                }
            }
            // ENDS HERE
            
            didGameStarted =  true // check to see if the game started
            player.physicsBody?.affectedByGravity = true // have the player affected by gravity
            logoImage.run(SKAction.scale(to: 0.5, duration: 0.2), completion: {
                self.logoImage.removeFromParent()
            }) // removes the logo
            
            
            
            // CHRIS'S CODE
            stephButton.run(SKAction.scale(to: 1, duration: 0.2), completion: {
                self.stephButton.removeFromParent()
            })
            larryButton.run(SKAction.scale(to: 1, duration: 0.2), completion: {
                self.larryButton.removeFromParent()
            })
            wadeButton.run(SKAction.scale(to: 1, duration: 0.2), completion: {
                self.wadeButton.removeFromParent()
            })
            // ENDS HERE

            
            
            taptoplayLabel.removeFromParent() // removes the play button
            // self.player.run(repeatPlayerAction) potentially remove this (just animates the bird)
            
            //1
            let spawn = SKAction.run({
                () in
                self.obstaclePair = self.createObstacles()
                self.addChild(self.obstaclePair)
            })
            //2
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            //3
            let distance = CGFloat(self.frame.width + obstaclePair.frame.width)
            let moveObstacles = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removeObstacles = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveObstacles, removeObstacles])
            
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // make the velocity 0 so it stays stable
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60)) // apply impulse to allow the player to go up and by how much
        } else {
            if didDied == false {
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
            }
            // as long as you are not dead keep the velocity at 0 and then have the player go up and by how much
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            //1
            if didDied == true{
                if restartButton.contains(location){
                    if UserDefaults.standard.object(forKey: "highestScore") != nil {
                        let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                        if hscore < Int(scoreLabel.text!)!{
                            UserDefaults.standard.set(scoreLabel.text, forKey: "highestScore")
                        }
                    } else {
                        UserDefaults.standard.set(0, forKey: "highestScore")
                    }
                    restartScene()
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered to move the background slowly 2 pixels to the left each time the function is called
        if didGameStarted == true{
            if didDied == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    let bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
                    }
                }))
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.obstacleCategory || firstBody.categoryBitMask == CollisionBitMask.obstacleCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory || firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.groundCategory || firstBody.categoryBitMask == CollisionBitMask.groundCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory{
            enumerateChildNodes(withName: "obstaclePair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if didDied == false{
                didDied = true
                restartGame()
                self.player.removeAllActions()
            }
        } else if firstBody.categoryBitMask == CollisionBitMask.playerCategory && secondBody.categoryBitMask == CollisionBitMask.basketballCategory {
            run(buzzSound)
            score += 1
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
        } else if firstBody.categoryBitMask == CollisionBitMask.basketballCategory && secondBody.categoryBitMask == CollisionBitMask.playerCategory {
            run(buzzSound)
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        didDied = false
        didGameStarted = false
        score = 0
        createScene()
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
        
        for i in 0..<2
        {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        } // this creates 2 backgrounds that are side by side and helps create the illusion of a neverending background
        
        
        playerSprites.append(playerAtlas.textureNamed(playerChoice)) // shows the player
        
        self.player = createPlayer(legendChoice: playerChoice)
        self.addChild(player)
        
        let animatePlayer = SKAction.animate(with: self.playerSprites, timePerFrame: 0.1)
        self.repeatPlayerAction = SKAction.repeatForever(animatePlayer)
        
        scoreLabel = yourScore()
        self.addChild(scoreLabel)
        
        highscoreLabel = highScore()
        self.addChild(highscoreLabel)
        
        appLogo()
        
        // CHRIS'S CODE
        createStephButton()
        createLarryButton()
        createWadeButton()
        // ENDS HERE

        taptoplayLabel = playGame()
        self.addChild(taptoplayLabel)
    }
}
