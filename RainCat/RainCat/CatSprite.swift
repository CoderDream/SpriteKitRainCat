//
//  CatSprite.swift
//  RainCat
//
//  Created by CoderDream on 2019/1/21.
//  Copyright © 2019 CoderDream. All rights reserved.
//

import SpriteKit

public class CatSprite : SKSpriteNode {
    public static func newInstance() -> CatSprite {
        let catSprite = CatSprite(imageNamed: "cat_one")
        catSprite.zPosition = 5
        catSprite.physicsBody = SKPhysicsBody(circleOfRadius: catSprite.size.width / 2)
        
        catSprite.physicsBody?.categoryBitMask = CatCategory
        catSprite.physicsBody?.contactTestBitMask = RainDropCategory | WorldCategory
        
        return catSprite
    }
    
    public func update(deltaTime: TimeInterval) {
        
    }
}
