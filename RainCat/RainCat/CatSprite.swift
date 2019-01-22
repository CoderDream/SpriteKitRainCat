//
//  CatSprite.swift
//  RainCat
//
//  Created by CoderDream on 2019/1/21.
//  Copyright © 2019 CoderDream. All rights reserved.
//

import SpriteKit

public class CatSprite : SKSpriteNode {
    private let movementSpeed : CGFloat = 200
    
    private var timeSinceLastHit : TimeInterval = 2
    private let maxFlailTime : TimeInterval = 2
    
    private let walkingActionKey = "action_walking"
    
    // 动画帧
    private let walkFrames = [
        SKTexture(imageNamed: "cat_one"),
        SKTexture(imageNamed: "cat_two")
    ]
    
    public static func newInstance() -> CatSprite {
        let catSprite = CatSprite(imageNamed: "cat_one")
        catSprite.zPosition = 5
        catSprite.physicsBody = SKPhysicsBody(circleOfRadius: catSprite.size.width / 2)
        
        catSprite.physicsBody?.categoryBitMask = CatCategory
        catSprite.physicsBody?.contactTestBitMask = RainDropCategory | WorldCategory
        
        return catSprite
    }
    
    public func update(deltaTime: TimeInterval, foodLocation : CGPoint) {
        //
        timeSinceLastHit += deltaTime
        
        if timeSinceLastHit >= maxFlailTime {
            if action(forKey: walkingActionKey) == nil {
                let walkingAction = SKAction.repeatForever(
                    SKAction.animate(
                        with: walkFrames,
                        timePerFrame: 0.1,
                        resize: false,
                        restore: true)
                )
                
                run(walkingAction, withKey: walkingActionKey)
            }
            
            // 修正小猫的旋转角度
            if zRotation != 0 && action(forKey: "action_rotate") == nil {
                run(SKAction.rotate(byAngle: 0, duration: 0.25), withKey: "action_rotate")
            }
            
            if foodLocation.x < position.x {
                // Food is left
                position.x -= movementSpeed * CGFloat(deltaTime)
                xScale = -1
            } else {
                // Food is right
                position.x += movementSpeed * CGFloat(deltaTime)
                xScale = 1
            }
            
            //
            physicsBody?.angularVelocity = 0
        }
    }
    
    public func hitByRain() {
        timeSinceLastHit = 0
        removeAction(forKey: walkingActionKey)
    }
}
