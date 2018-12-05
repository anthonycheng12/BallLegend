import SpriteKit

struct CollisionBitMask {
    static let playerCategory:UInt32 = 0x1 << 0
    static let obstacleCategory:UInt32 = 0x1 << 1
    static let basketballCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}

extension GameScene {
    func createPlayer(legendChoice: String) -> SKSpriteNode {
        let player = SKSpriteNode(texture: SKTextureAtlas(named:"player").textureNamed(playerChoice))
        player.size = CGSize(width: 60, height: 70) // sets height and width of the character
        player.position = CGPoint(x:self.frame.midX, y:self.frame.midY) // sets the player in the middle of the screen
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2) // allows the player to behave like a real world object which is bothered by gravity and collisions
        player.physicsBody?.linearDamping = 1.1
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = CollisionBitMask.playerCategory // we notice collisions by comparing the category bit masks
        player.physicsBody?.collisionBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.groundCategory // allows for the detection of ground/obstacle collision
        player.physicsBody?.contactTestBitMask = CollisionBitMask.obstacleCategory | CollisionBitMask.basketballCategory | CollisionBitMask.groundCategory // want to detect collision with obstacle, basketball, or ground
        player.physicsBody?.affectedByGravity = false // allows player to go up when you touch him
        player.physicsBody?.isDynamic = true
        
        return player
    }
    
    // this creates a restart for the game and shows the button on a screen
    func restartGame() {
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
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.6)
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
    
    // takes note of a high score
    func highScore() -> SKLabelNode {
        let highscoreLabel = SKLabelNode()
        highscoreLabel.position = CGPoint(x: self.frame.width - 80, y: self.frame.height - 22)
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            highscoreLabel.text = "Highest Score: \(highestScore)"
        } else {
            highscoreLabel.text = "Highest Score: 0"
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
        stephButton.size = CGSize(width: 250, height: 150)
        stephButton.position = CGPoint(x:self.frame.midX-125, y:self.frame.midY-350)
        stephButton.setScale(0.5)
        self.addChild(stephButton)
        stephButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createLarryButton() {
        larryButton = SKSpriteNode()
        larryButton = SKSpriteNode(imageNamed: "larry")
        larryButton.size = CGSize(width: 300, height: 200)
        larryButton.position = CGPoint(x:self.frame.midX+35, y:self.frame.midY-300)
        larryButton.setScale(0.5)
        self.addChild(larryButton)
        larryButton.run(SKAction.scale(to: 1.0, duration: 0.3))
    }
    
    func createWadeButton() {
        wadeButton = SKSpriteNode()
        wadeButton = SKSpriteNode(imageNamed: "wade")
        wadeButton.size = CGSize(width: 250, height: 150)
        wadeButton.position = CGPoint(x:self.frame.midX+125, y:self.frame.midY-350)
        wadeButton.setScale(0.5)
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
    
    func createObstacles() -> SKNode  {

        let bball = SKSpriteNode(imageNamed: "ball")
        bball.size = CGSize(width: 40, height: 40)
        bball.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        bball.physicsBody = SKPhysicsBody(rectangleOf: bball.size)
        bball.physicsBody?.affectedByGravity = false
        bball.physicsBody?.isDynamic = false
        bball.physicsBody?.categoryBitMask = CollisionBitMask.basketballCategory // set to basketball so the program knows it is the ball
        bball.physicsBody?.collisionBitMask = 0
        bball.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory // contact with player will increase point by 1
        bball.color = SKColor.white

        obstaclePair = SKNode()
        obstaclePair.name = "obstaclePair"
        
        let topObs = SKSpriteNode(imageNamed: "shaq")
        let botObs = SKSpriteNode(imageNamed: "shaq")
        
        topObs.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 400)
        botObs.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 400) // the add and minus contributes to the space between the top obstacle and bottom obstacle
        
        topObs.setScale(0.5)
        botObs.setScale(0.5)
        
        topObs.physicsBody = SKPhysicsBody(rectangleOf: topObs.size)
        topObs.physicsBody?.categoryBitMask = CollisionBitMask.obstacleCategory
        topObs.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        topObs.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        topObs.physicsBody?.isDynamic = false
        topObs.physicsBody?.affectedByGravity = false
        
        botObs.physicsBody = SKPhysicsBody(rectangleOf: botObs.size)
        botObs.physicsBody?.categoryBitMask = CollisionBitMask.obstacleCategory
        botObs.physicsBody?.collisionBitMask = CollisionBitMask.playerCategory
        botObs.physicsBody?.contactTestBitMask = CollisionBitMask.playerCategory
        botObs.physicsBody?.isDynamic = false
        botObs.physicsBody?.affectedByGravity = false
        
        topObs.zRotation = CGFloat(Double.pi)
        
        obstaclePair.addChild(topObs)
        obstaclePair.addChild(botObs)
        
        obstaclePair.zPosition = 1

        let randomPosition = CGFloat.random(min: -175, max: 200) // higher the number the longer the obstacles can potentially be
        obstaclePair.position.y = obstaclePair.position.y +  randomPosition
        obstaclePair.addChild(bball)
        
        obstaclePair.run(moveAndRemove)
        
        return obstaclePair
    }
    
}
