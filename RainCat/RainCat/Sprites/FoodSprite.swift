//
//  FoodSprite.swift
//  RainCat
//
//  Created by CoderDream on 2019/1/21.
//  Copyright © 2019 CoderDream. All rights reserved.
//

import SpriteKit

public class FoodSprite : SKSpriteNode {
    public static func newInstance() -> FoodSprite {
        let foodDish = FoodSprite(imageNamed: "food_dish")
        foodDish.physicsBody = SKPhysicsBody(rectangleOf: foodDish.size)
        foodDish.physicsBody?.categoryBitMask = FoodCategory
        foodDish.physicsBody?.contactTestBitMask = RainDropCategory | WorldCategory | CatCategory
        foodDish.zPosition = 5
        
        return foodDish
    }
    
    public func update(deltaTime: TimeInterval) {
        
    }
}
