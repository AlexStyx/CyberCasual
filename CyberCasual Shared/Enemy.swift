//
//  Enemy.swift
//  CyberCasual iOS
//
//  Created by Александр Бисеров on 4/27/21.
//

import SpriteKit
import Foundation

final class Enemy: SKSpriteNode {
    static func populateEnemy(at point: CGPoint) -> Enemy {
        let enemy = Enemy(imageNamed: "Enemy")
        enemy.position = point
        let enemySize = CGSize(width: 80, height: 28)
        enemy.size = enemySize
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemy.physicsBody?.isDynamic = false
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.pinned = false
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = 2
        enemy.physicsBody?.contactTestBitMask = 1
        enemy.run(rotateForRandomAngle())
        return enemy
    }
    
    static func rotateForRandomAngle() -> SKAction {
        let distribution = CGFloat.random(in: 0...360)
        let radian = distribution * CGFloat.pi / 180
        return SKAction.rotate(toAngle: radian, duration: 0)
    }
}
