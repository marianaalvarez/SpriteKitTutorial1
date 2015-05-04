//
//  GameViewController.swift
//  SpriteKitSimpleGame
//  Created by Mariana Alvarez on 04/05/15.
//  Copyright (c) 2015 Mariana Alvarez. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        let scene = GameScene(size: view.bounds.size)
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        super.viewDidLoad()
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
