import SpriteKit

struct CollisionBitMask {
    static let playerCategory:UInt32 = 0x1 << 0
    static let obstacleCategory:UInt32 = 0x1 << 1
    static let basketballCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene {
    func createScene() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = CollisionBitMask.groundCategory
        self.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory // to get information on contact with player and obstacle
        self.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory // to get information on contact with player and obstacle
        self.physicsBody?.isDynamic = false // if set to false then the character is not going to move if hit but for true then it will move if hit
        self.physicsBody?.affectedByGravity = false // prevents player from falling off the screen
        
        self.physicsWorld.contactDelegate = self // helps detect contact and collisions
        
        
        // for each i in range from 0 to less than 2
        for i in 0 ..< 2
        {
            let background = SKSpriteNode(imageNamed: "bg")
            background.anchorPoint = CGPoint.init(x: 0, y: 0)
            background.position = CGPoint(x:CGFloat(i) * self.frame.width, y:0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        } // this creates 2 backgrounds that are side by side and helps create the illusion of a neverending background
        
        self.player = createPlayer(legendChoice: playerChoice)
        self.addChild(player)
        
        scoreLabel = yourScore()
        self.addChild(scoreLabel)
        
        highscoreLabel = highScore()
        self.addChild(highscoreLabel)
        
        appLogo()
        
        createStephButton()
        createWadeButton()
        
        taptoplayLabel = playGame()
        self.addChild(taptoplayLabel)
    }
    
    func createPlayer(legendChoice: String) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: playerChoice)
        
        player.size = CGSize(width: 120, height: 120) // sets height and width of the character
        player.position = CGPoint(x:self.frame.midX, y: self.frame.midY) // sets the player in the middle of the screen
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 4, center: CGPoint(x: 0, y: player.size.height / 4)) // allows the player to behave like a real world object which is bothered by gravity and collisions
        player.physicsBody?.linearDamping = 1.0
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = CollisionBitMask.playerCategory // we notice collisions by comparing the category bit masks
        player.physicsBody?.collisionBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.groundCategory // allows for the detection of ground/obstacle collision
        player.physicsBody?.contactTestBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.basketballCategory | CollisionBitMask.groundCategory // want to detect collision with obstacle, basketball, or ground
        player.physicsBody?.affectedByGravity = false // allows player to go up when you touch him
        player.physicsBody?.isDynamic = true
        
        return player
    }
    
    func selectPlayer(from touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if (stephButton.contains(location)){
                playerChoice = "steph"
            } else if (wadeButton.contains(location)) {
                playerChoice = "wade"
            }
        }
    }
    
    func resetPlayer() {
        self.player.removeAllActions()
        self.player.removeFromParent()
        
        self.player = createPlayer(legendChoice: playerChoice)
        self.addChild(player)
        
        player.physicsBody?.affectedByGravity = true // have the player affected by gravity
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // make the velocity 0 so it stays stable
    }
    
    func start() {
        resetPlayer()
        
        logoImage.run(SKAction.scale(to: 0.5, duration: 0.2), completion: {
            self.logoImage.removeFromParent()
        }) // removes the logo
        
        stephButton.run(SKAction.scale(to: 1, duration: 0.2), completion: {
            self.stephButton.removeFromParent()
        })
        
        wadeButton.run(SKAction.scale(to: 1, duration: 0.2), completion: {
            self.wadeButton.removeFromParent()
        })
        
        taptoplayLabel.removeFromParent() // removes the play button
        
        let spawn = SKAction.run({
            () in
            self.obstacle = self.createObstacle()
            self.addChild(self.obstacle)
        })
        
        let delay = SKAction.wait(forDuration: 1.5)
        let SpawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.width + obstacle.frame.width)
        let moveObstacles = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
        let removeObstacles = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([moveObstacles, removeObstacles])
        
        started = true
    }
    
    func moveBackground() {
        enumerateChildNodes(withName: "background", using: ({
            (node, error) in
            let bg = node as! SKSpriteNode
            bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
            if bg.position.x <= -bg.size.width {
                bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y:bg.position.y)
            }
        }))
    }
    
    func movePlayer() {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60)) // apply impulse to allow the player to go up and by how much
    }
    
    func didRestart(from touches: Set<UITouch>) -> Bool {
        print ("Called didRestart")
        for touch in touches {
            let location = touch.location(in: self)
            
            if restartButton.contains(location) {
                return true
            }
        }
        
        return false
    }
    
    func restart() {
        print ("called restart")
        resetPlayer()
        updateHighScore()
        
        removeAllChildren()
        removeAllActions()
        
        alive = true
        started = false
        score = 0
        
        createScene()
    }
    
    // this creates a restart for the game and shows the button on a screen
    func gameOver() {
        print ("gameover")
        if !alive { return }
        
        updateHighScore()
        
        //        print (obstacle.children)
        
        alive = false
        
        obstacle.removeAllActions()
        moveAndRemove = SKAction()
        
        restartButton = SKSpriteNode(imageNamed: "restart")
        restartButton.size = CGSize(width:100, height:100)
        restartButton.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        self.addChild(restartButton)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.5))
    }
    
    //shows your score
    func yourScore() -> SKLabelNode {
        let scoreLabel = SKLabelNode()
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height - 125)
        scoreLabel.text = "\(score)"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 50
        scoreLabel.fontName = "Courier-BoldOblique"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: 0, y: 0)
        scoreBg.path = CGPath(roundedRect: CGRect(x: CGFloat(-50), y: CGFloat(-30), width: CGFloat(100), height: CGFloat(100)), cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor = UIColor(red: CGFloat(0.0 / 255.0), green: CGFloat(0.0 / 255.0), blue: CGFloat(0.0 / 255.0), alpha: CGFloat(0.2))
        scoreBg.strokeColor = UIColor.clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = -1
        scoreLabel.addChild(scoreBg)
        return scoreLabel
    }
    
    func updateHighScore() {
        if UserDefaults.standard.object(forKey: "highestScore") != nil {
            let hscore = UserDefaults.standard.integer(forKey: "highestScore")
            
            if hscore < score {
                UserDefaults.standard.set(scoreLabel.text, forKey: "highestScore")
            }
        } else {
            UserDefaults.standard.set(0, forKey: "highestScore")
        }
    }
    
    // takes note of a high score
    func highScore() -> SKLabelNode {
        let highscoreLabel = SKLabelNode()
        highscoreLabel.position = CGPoint(x: self.frame.width - 25, y: self.frame.height - 80)
        highscoreLabel.numberOfLines = 2
        highscoreLabel.horizontalAlignmentMode = .right
        
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLabel.text = "High Score\n\(highestScore) dunks!!!"
        } else {
            highscoreLabel.text = "High Score\n0 dunks!!!"
        }
        
        highscoreLabel.zPosition = 5
        highscoreLabel.fontSize = 15
        highscoreLabel.fontName = "Courier-BoldOblique"
        return highscoreLabel
    }
    
    // creates a logo
    func appLogo() {
        logoImage = SKSpriteNode()
        logoImage = SKSpriteNode(imageNamed: "hometxt")
        logoImage.size = CGSize(width: 350, height: 125)
        logoImage.position = CGPoint(x:self.frame.midX, y:self.frame.midY + 100)
        logoImage.setScale(0.5)
        self.addChild(logoImage)
        logoImage.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createStephButton() {
        stephButton = SKSpriteNode()
        stephButton = SKSpriteNode(imageNamed: "steph")
        stephButton.size = CGSize(width: 150, height: 150)
        stephButton.position = CGPoint(x:self.frame.midX-110, y:self.frame.midY-325)
        stephButton.setScale(1.0)
        self.addChild(stephButton)
        stephButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createWadeButton() {
        wadeButton = SKSpriteNode()
        wadeButton = SKSpriteNode(imageNamed: "wade")
        wadeButton.size = CGSize(width: 150, height: 150)
        wadeButton.position = CGPoint(x:self.frame.midX+110, y:self.frame.midY-325)
        wadeButton.setScale(1.0)
        self.addChild(wadeButton)
        wadeButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    // adds tap to play logo below the player
    func playGame() -> SKLabelNode {
        let taptoplayLabel = SKLabelNode()
        taptoplayLabel.position = CGPoint(x:self.frame.midX, y:self.frame.midY-175)
        taptoplayLabel.text = "Choose a legend below!"
        taptoplayLabel.fontColor = UIColor.white
        taptoplayLabel.zPosition = 5
        taptoplayLabel.fontSize = 25
        taptoplayLabel.fontName = "Courier-BoldOblique"
        return taptoplayLabel
    }
    
    func createObstacle() -> SKNode  {
        let hoop = SKSpriteNode(imageNamed: "hoop2")
        hoop.size = CGSize(width: 100, height: 100)
        hoop.position = CGPoint(x: self.frame.width + 45, y: self.frame.height / 2 - 50)
        hoop.physicsBody = SKPhysicsBody(rectangleOf: hoop.size)
        hoop.physicsBody?.affectedByGravity = false
        hoop.physicsBody?.isDynamic = false
        hoop.physicsBody?.categoryBitMask = CollisionBitMask.basketballCategory // set to basketball so the program knows it is the ball
        hoop.physicsBody?.collisionBitMask = 0
        hoop.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory // contact with player will increase point by 1
        hoop.color = SKColor.white
        
        obstacle = SKNode()
        obstacle.name = "obstacle"
        
        let signPost = SKSpriteNode(imageNamed: "signpost")
        signPost.size = CGSize(width: 40, height: 600);
        signPost.position = CGPoint(x: self.frame.width + 50, y: self.frame.height/2 - 400) // the add and minus contributes to the space between the top obstacle and the ceiling
        signPost.setScale(1.0)
        
        signPost.physicsBody = SKPhysicsBody(rectangleOf: signPost.size)
        signPost.physicsBody?.categoryBitMask = CollisionBitMask.obstacleCategory
        signPost.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        signPost.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        signPost.physicsBody?.isDynamic = false
        signPost.physicsBody?.affectedByGravity = false
        
        obstacle.addChild(signPost)
        obstacle.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -175, max: 200) // higher the number the longer the obstacle can potentially be
        obstacle.position.y = obstacle.position.y + randomPosition
        obstacle.addChild(hoop)
        
        obstacle.run(moveAndRemove)
        
        return obstacle
    }
}
