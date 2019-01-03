//
//  GameScene.swift
//  RainCat
//
//  Created by CoderDream on 2018/12/29.
//  Copyright © 2018 CoderDream. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var lastUpdateTime : TimeInterval = 0
    private var currentRainDropSpawnTime : TimeInterval = 0
    private var rainDropSpawnRate : TimeInterval = 0.5
    // 雨伞
    private let umbrellaNode = UmbrellaSprite.newInstance()
    
    // 雨滴
    let raindropTexture = SKTexture(imageNamed: "rain_drop")
    // 背景节点
    private let backgroundNode = BackgroundNode()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsBody?.categoryBitMask = WorldCategory
        
        // 监听场景的 physicsWorld 中所发生的碰撞
        self.physicsWorld.contactDelegate = self
        
        // 将背景节点添加到场景中
        backgroundNode.setup(size: size)
        addChild(backgroundNode)
        
        // 增加雨伞节点
        // umbrellaNode.position = CGPoint(x: frame.midX, y: frame.midY)
        umbrellaNode.updatePosition(point: CGPoint(x: frame.midX, y: frame.midY))
        umbrellaNode.zPosition = 4
        addChild(umbrellaNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 点击会源源不断的生成雨滴
        //spawnRaindrop()
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            umbrellaNode.setDestination(destination: point)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            umbrellaNode.setDestination(destination: point)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update the Spawn Timer
        currentRainDropSpawnTime += dt
        
        // 每过半秒钟就会有新的雨滴被创建并落至地面
        if currentRainDropSpawnTime > rainDropSpawnRate {
            currentRainDropSpawnTime = 0
            spawnRaindrop()
        }
        
        self.lastUpdateTime = currentTime
        
        umbrellaNode.update(deltaTime: dt)
    }
    
    // 创建雨滴节点
    private func spawnRaindrop() {
        // 创建雨滴节点
        let raindrop = SKSpriteNode(texture: raindropTexture)
        // 设置雨滴的物理属性：材质和大小
        raindrop.physicsBody = SKPhysicsBody(texture: raindropTexture, size: raindrop.size)
        // 设置物理属性：可碰撞元素
        raindrop.physicsBody?.categoryBitMask = RainDropCategory
        raindrop.physicsBody?.contactTestBitMask = FloorCategory | WorldCategory
        // 设置雨滴的位置：屏幕中心
        //raindrop.position = CGPoint(x: size.width / 2, y: size.height / 2)
        // 位置随机
        let xPosition = CGFloat(arc4random()).truncatingRemainder(dividingBy: size.width)
        let yPosition = size.height + raindrop.size.height
        raindrop.position = CGPoint(x: xPosition, y: yPosition)
        // 雨滴在天空和地面之上
        raindrop.zPosition = 2
        // 将雨滴添加到当前场景
        addChild(raindrop)
    }
    
    // 当有预先设置的 contactTestBitMasks 的物体碰撞发生时，这个方法就会被调用。
    func didBegin(_ contact: SKPhysicsContact) {
        // 当雨滴和其他任何其它对象的边缘发生碰撞后，我们将其碰撞掩码（collision bitmask）清零
        if contact.bodyA.categoryBitMask == RainDropCategory {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if contact.bodyB.categoryBitMask == RainDropCategory {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
        
        // 加入销毁操作来移除这些节点
        if contact.bodyA.categoryBitMask == WorldCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
}
