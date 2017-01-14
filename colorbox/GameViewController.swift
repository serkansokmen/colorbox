//
//  GameViewController.swift
//  colorbox
//
//  Created by Serkan Sokmen on 08/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import ChameleonFramework

let gameSpeed = 1.0

class GameViewController: UIViewController {
    
    var baitTimer: Timer!
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.view as! SKView? else { return }
        
        // Load the SKScene from 'GameScene.sks'
        scene = GameScene(size: view.frame.size)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .flatBlack
        let randIndex = Int(arc4random_uniform(UInt32(GameViewModel.colors.count)))
        scene.gameVm = GameViewModel(color: GameViewModel.colors[randIndex], speed: gameSpeed, win: 0, loose: 0)
        
        // Present the scene
        view.presentScene(scene)
        
        view.ignoresSiblingOrder = true
        
        view.showsFPS = false
        view.showsNodeCount = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        baitTimer = Timer.scheduledTimer(withTimeInterval: gameSpeed, repeats: true, block: { [unowned self] timer in
            self.scene.throwBait()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        baitTimer.invalidate()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
