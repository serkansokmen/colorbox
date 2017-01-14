//
//  GameScene.swift
//  colorbox
//
//  Created by Serkan Sokmen on 08/01/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import SpriteKit
import GameplayKit
import ChameleonFramework


struct GameViewModel {
    
    static let colors: [SKColor] = [.flatLime, .flatPowderBlue, .clear, .flatPink, .flatSand]
    
    var color: UIColor
    var speed: TimeInterval
    var win: Int
    var loose: Int
    
    var nextColor: UIColor? {
        if let index = GameViewModel.colors.index(of: color) {
            let nextIndex = (index + 1) % GameViewModel.colors.count
            return GameViewModel.colors[nextIndex]
        }
        return nil
    }
    var prevColor: UIColor? {
        if let index = GameViewModel.colors.index(of: color) {
            let prevIndex = index == 0 ? GameViewModel.colors.count - 1 : index - 1
            return GameViewModel.colors[prevIndex]
        }
        return nil
    }
    
    var randomColor: UIColor {
        let randIndex = Int(arc4random_uniform(UInt32(GameViewModel.colors.count)))
        return GameViewModel.colors[randIndex]
    }
    
    var cellSize: CGFloat {
        return 50.0
    }
    var cellPadding: CGFloat {
        return 8.0
    }
}





class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameVm: GameViewModel!
    
    private var timer: Timer!
    
    var bucket: SKShapeNode!
    var currentBait: SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        bucket = SKShapeNode.init(rectOf: CGSize.init(width: gameVm.cellSize,
                                                      height: gameVm.cellSize),
                                  cornerRadius: 5.0)
        
        let sprite = SKSpriteNode(imageNamed: "bucket")
        bucket.addChild(sprite)
        sprite.position.x = -sprite.frame.width / CGFloat(2.0)
        
        bucket.position = CGPoint(x: self.frame.width / 2, y: 100)
        bucket.fillColor = .clear
        bucket.strokeColor = gameVm.color
        bucket.lineWidth = 4.0
        
        addChild(bucket!)
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        var colorTo: UIColor?
        
        if pos.x < bucket.position.x {
            // Bucket color
            if let prev = gameVm.prevColor {
                colorTo = prev
            }
        }
        
        if pos.x > bucket.position.x {
            // Bucket color
            if let next = gameVm.nextColor {
                colorTo = next
            }
        }
        
        guard let color = colorTo else { return }
        
        gameVm.color = color
        let action = SKAction.customAction(withDuration: 0.2, actionBlock: { node, value in
            (node as! SKShapeNode).strokeColor = color
        })
        bucket.run(action)
        
        let index = GameViewModel.colors.index(of: color)!
        let sprite = bucket.children.first as! SKSpriteNode
        let sprAction = SKAction.moveTo(x: CGFloat(index - 2) * (gameVm.cellSize + gameVm.cellPadding),
                                        duration: 0.2)
        sprite.run(sprAction)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if let bait = currentBait {
            
            if bait.position.y <= bucket.position.y && bucket.strokeColor == bait.fillColor {
                // Correct
                gameVm.win += 1
                
                bait.removeAllActions()
                
                let fade = SKAction.fadeAlpha(to: 0, duration: gameVm.speed / 2)
                let moveBy = SKAction.moveBy(x: 0, y: gameVm.cellSize, duration: gameVm.speed / 2)
                moveBy.timingMode = .easeOut
                
                bait.run(SKAction.group([fade, moveBy])) {
                    bait.removeFromParent()
                    
                    let toCorrect = SKAction.colorize(with: .flatSand, colorBlendFactor: 1, duration: 0.05)
                    let reset = SKAction.colorize(with: .flatBlack, colorBlendFactor: 1, duration: 0.1)
                    self.run(SKAction.sequence([toCorrect, reset]))
                }
            }
        }
    }
    
    func throwBait() {
        
        // Create shape node to use during mouse interaction
        let w: CGFloat = gameVm.cellSize
        let x = Double(self.frame.width / 2)
        let y = Double(self.frame.height - w)
        
        let bait = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        bait.position = CGPoint(x: x, y: y)
        bait.lineWidth = 0.0
        bait.fillColor = gameVm.randomColor
        bait.name = "bait"
        
        self.addChild(bait)
        
        currentBait = bait
        
        let move = SKAction.moveTo(y: 0, duration: gameVm.speed)
        move.timingMode = SKActionTimingMode.easeIn
        
        bait.run(move) {
            bait.removeFromParent()
            
            let toRed = SKAction.colorize(with: .flatRed, colorBlendFactor: 1, duration: 0.05)
            let reset = SKAction.colorize(with: .flatBlack, colorBlendFactor: 1, duration: 0.1)
            self.run(SKAction.sequence([toRed, reset]))
        }
        
        //            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
        //            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
        //                                              SKAction.fadeOut(withDuration: 0.5),
        //                                              SKAction.removeFromParent()]))
        
        
        
    }
}
