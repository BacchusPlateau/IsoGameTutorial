//
//  GameViewController.swift
//  IsoGame
//
//  Created by Bret Williams on 5/4/18.
//  Copyright © 2018 Bret Williams. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        print ("showing view")
    }
    
    
}
