import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
    // Properties
    
    let buzzSound = SKAction.playSoundFileNamed("buzzer.mp3", waitForCompletion: false)
    
    // State
    
    var started: Bool = false
    var alive: Bool = true
    var score: Int = 0
    var playerChoice = "steph"
    
    // Sprites
    
    var scoreLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var taptoplayLabel = SKLabelNode()
    var restartButton = SKSpriteNode()
    var logoImage = SKSpriteNode()
    var obstacle = SKNode()
    var moveAndRemove = SKAction()
    let playerAtlas = SKTextureAtlas(named:"player")
    var playerSprites = Array<SKTexture>()
    var player = SKSpriteNode()
    var stephButton = SKSpriteNode()
    var wadeButton = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        createScene()
//        view.showsPhysics = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started {
            selectPlayer(from: touches)
            start()
        } else if alive {
            movePlayer()
        } else if didRestart(from: touches) {
            restart()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered to move the background slowly 2 pixels to the left each time the function is called
        if (started && alive) {
            moveBackground()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (![contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask].contains(CollisionBitMask.playerCategory)) { return }
        
        // if bodyA is the player then collisionBody = bodyB, otherwise collisionBody = bodyA
        let collisionBody = contact.bodyA.categoryBitMask == CollisionBitMask.playerCategory ? contact.bodyB : contact.bodyA
        
        // if the player contacts a hoop
        if collisionBody.categoryBitMask == CollisionBitMask.basketballCategory {
            run(buzzSound)
            score += 1
            scoreLabel.text = "\(score)"
            collisionBody.node?.removeFromParent()
        } else { // if the player contacts anything else
            gameOver()
            //            restart()
        }
    }
}
