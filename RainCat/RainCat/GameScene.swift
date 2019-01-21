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
    // 小猫节点
    private var catNode : CatSprite!
    // 生成食物时的外边距
    private let foodEdgeMargin : CGFloat = 75.0
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
        
        // 生成小猫节点
        spawnCat()
        // 生成食物精灵
        spawnFood()
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
    
    // 初始化小猫精灵
    func spawnCat() {
        //我们首先检查了猫对象是否为空。然后，我们检查了这个场景中是否已经存在了一个猫对象。
        if let currentCat = catNode, children.contains(currentCat) {
            // 如果这个场景内已经存在了一只小猫，我们就要从父类中移除它，移除它现在正在进行的所有操作，并清除这个猫对象的 SKPhysicsBody。
            catNode.removeFromParent()
            catNode.removeAllActions()
            catNode.physicsBody = nil
        }
        
        catNode = CatSprite.newInstance()
        // 设定它的初始位置为伞下 30 像素的地方
        catNode.position = CGPoint(x: umbrellaNode.position.x, y: umbrellaNode.position.y - 30)
        
        addChild(catNode)
    }
    
    // 生成食物精灵
    // 我们新建了一个 FoodSprite，然后把它放在了屏幕上一个随机的位置 x。这里我们用了之前设定的外边距（margin）变量来限制了能够生成食物精灵的屏幕范围。
    // 首先，我们设置了随机位置的范围为屏幕的宽度减去 2 乘以外边距。然后，我们用外边距来偏移起始位置。这使得食物不会生成在任意距屏幕边界 0 到 75 的位置里。
    func spawnFood() {
        let food = FoodSprite.newInstance()
        var randomPosition : CGFloat = CGFloat(arc4random())
        randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - foodEdgeMargin * 2)
        randomPosition += foodEdgeMargin
        
        food.position = CGPoint(x: randomPosition, y: size.height)
        
        addChild(food)
    }
    
    // 当有预先设置的 contactTestBitMasks 的物体碰撞发生时，这个方法就会被调用。
    func didBegin(_ contact: SKPhysicsContact) {
        // 当雨滴和其他任何其它对象的边缘发生碰撞后，我们将其碰撞掩码（collision bitmask）清零
        if contact.bodyA.categoryBitMask == RainDropCategory {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            // contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if contact.bodyB.categoryBitMask == RainDropCategory {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            // contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
        
        
        // 我们在移除雨滴碰撞和移除离屏节点中间插入了一个条件判断。这个 if 语句判断了碰撞物体是不是猫，然后我们在 handleCatCollision(contact:) 函数中处理猫的行为。
        if contact.bodyA.categoryBitMask == FoodCategory || contact.bodyB.categoryBitMask == FoodCategory {
            handleFoodCollision(contact: contact)
            
            return
        }
        
        // 我们在移除雨滴碰撞和移除离屏节点中间插入了一个条件判断。这个 if 语句判断了碰撞物体是不是猫，然后我们在 handleCatCollision(contact:) 函数中处理猫的行为。
        if contact.bodyA.categoryBitMask == WorldCategory || contact.bodyB.categoryBitMask == WorldCategory {
            handleCatCollision(contact: contact)
            
            return
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
    
    // 我们在寻找除了猫以外的物理实体（physics body）。在我们发现其他实体对象时，我们就需要判断是什么触碰了猫。
    // 现在，如果是雨滴在猫身上，我们只在控制台中输出这个碰撞发生了，而如果是猫触碰了这个游戏世界的边缘，我们就会重新生成一个猫对象。
    func handleCatCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CatCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {
        case RainDropCategory:
            print("rain hit the cat")
        case WorldCategory:
            spawnCat()
        default:
            print("Something hit the cat")
        }
    }
    
    func handleFoodCollision(contact: SKPhysicsContact) {
        //获取当前时间
        let now = Date()
        
        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        //print("当前日期时间：\(dformatter.string(from: now))")
        
        //当前时间的时间戳
        //let timeInterval:TimeInterval = now.timeIntervalSince1970
        //let timeStamp = Int(timeInterval)
        //print("当前时间的时间戳：\(timeStamp)")
        var otherBody : SKPhysicsBody
        var foodBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CatCategory {
            otherBody = contact.bodyB
            foodBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            foodBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case CatCategory:
            print("fed cat: \(dformatter.string(from: now))")
            fallthrough
        case WorldCategory:
            foodBody.node?.removeFromParent()
            foodBody.node?.physicsBody = nil
            
            spawnFood()
        default:
            print("Something else touched the food: \(dformatter.string(from: now))")
        }
    }
}
