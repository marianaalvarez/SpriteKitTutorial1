//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//  Created by Mariana Alvarez on 04/05/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.whiteColor()
        
        
        runAction(SKAction.playSoundFileNamed("Sounds/blood_hit.mp3", waitForCompletion: false))
        
        var message = won ? "You Won!" : "You Lose!"
        var image = won ? "bloodbg" : "bloodbg"
    
        let backGround = SKSpriteNode(imageNamed: image)
        backGround.position = CGPoint(x: size.width/2, y: size.height/2)
        backGround.size = CGSizeMake(700, 500)
        addChild(backGround)
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 60
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        let label2 = SKLabelNode(fontNamed: "Chalkduster")
        label2.text = "Tap to play again"
        label2.fontSize = 30
        label2.fontColor = SKColor.blackColor()
        label2.position = CGPoint(x: size.width/2, y: size.height/2.5)
        addChild(label2)
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let reveal = SKTransition.fadeWithDuration(0.0001)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: reveal)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}