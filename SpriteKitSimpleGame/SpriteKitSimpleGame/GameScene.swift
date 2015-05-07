//
//  GameScene.swift
//  SpriteKitSimpleGame
//  Created by Mariana Alvarez on 04/05/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.

import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    
    var monstersDestroyed = 0
    
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("Sounds/background-music-aac.caf")
        backgroundColor = SKColor.whiteColor()
        player.position = CGPoint(x:size.width * 0.1, y:size.height * 0.5)
        
        self.addChild(player)
        
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addMonster), SKAction.waitForDuration(1.0)])))
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        
        let monster = SKSpriteNode(imageNamed: "monster")
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        addChild(monster)
        
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2,y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.fadeWithDuration(0.1)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    func addBlood(monster: SKSpriteNode) {
        let blood = SKSpriteNode(imageNamed: "blood")
        blood.position = CGPoint(x: monster.position.x, y: monster.position.y)
        blood.zPosition = -1
        self.addChild(blood)
        
        let ghost = SKSpriteNode(imageNamed: "monster")
        ghost.alpha = 0.5
        ghost.zPosition = 1
        ghost.position = CGPoint(x: monster.position.x, y: monster.position.y)
        
        let path = CGPathCreateMutable()
        
        
        var minX = ghost.size.width / 2
        var maxX = self.frame.size.width - ghost.size.width / 2
        var rangeX = maxX - minX
        var random : CGFloat = CGFloat(arc4random())
        var actualX = (random % rangeX) + minX
        
        self.addChild(ghost)
        
//        CGPathMoveToPoint(path, nil, ghost.position.x, ghost.position.y)
//        
//        CGPathAddCurveToPoint(path, nil, 120, 300, 170, 700, 300, -10)
        
        
        
//        var randomDirection = arc4random_uniform(3)
//        switch (randomDirection) {
//        case 0:
//            CGPathAddCurveToPoint(path, nil, 120, 300, 170, 650, 300, -10)
//        case 1:
//            CGPathAddCurveToPoint(path, nil, 220, 150, 170, 300, 100, -10)
//        case 2:
//            CGPathAddCurveToPoint(path, nil, 400, 650, 40, 450, 300, -10)
//        default:
//            println("oi")
//        }
//        
        
//        var follow = SKAction.followPath(path, asOffset: false, orientToPath: true, duration: 10)
//        var remove = SKAction.removeFromParent()
//        ghost.runAction(SKAction.sequence([follow, remove]))
        
        let action1 = SKAction.moveTo(CGPointMake(monster.position.x , monster.position.y + 400), duration: 5)
        var remove = SKAction.removeFromParent()
        ghost.runAction(SKAction.sequence([action1, remove]))
        
        
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        runAction(SKAction.playSoundFileNamed("Sounds/shuriken.mp3", waitForCompletion: false))
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
  
        let offset = touchLocation - projectile.position

        if (offset.x < 0) {
            return
        }
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(projectile)
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        let angle : CGFloat = CGFloat(M_PI)
        let rotate = SKAction.rotateByAngle(angle, duration: 0.1)
        let repeatAction = SKAction.repeatActionForever(rotate)
        projectile.runAction(repeatAction, withKey: "rotate")

    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        runAction(SKAction.playSoundFileNamed("Sounds/Blood Squirt-SoundBible.com-1808242738.mp3", waitForCompletion: false))
        addBlood(monster)
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
    
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
}
