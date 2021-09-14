//
//  GameScene.swift
//  CyberCasual Shared
//
//  Created by Александр Бисеров on 4/26/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    fileprivate var player: SKSpriteNode!
    fileprivate var upperBound: SKSpriteNode!
    fileprivate var bottomBound: SKSpriteNode!
    fileprivate var upperPoint: SKSpriteNode!
    fileprivate var bottomPoint: SKSpriteNode!
    fileprivate var targetPosition: CGPoint!
    fileprivate var countLabel: SKLabelNode!
    fileprivate var tapToStartLabel: SKLabelNode!
    fileprivate var gameOverLabel: SKLabelNode!
    fileprivate var bestScoreLabel: SKLabelNode!
    fileprivate let leftBound: CGFloat = -100
    fileprivate let rightBound:CGFloat = 100
    fileprivate var enemies: [Enemy] = []
    fileprivate var hasFinished = false
    
    fileprivate var count = 0 {
        didSet {
            countLabel.alpha = 0
            countLabel.text = "Score: \(count)"
            countLabel.alpha = 1
        }
    }

    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        player = (self.childNode(withName: "Player") as! SKSpriteNode)
        upperBound = (self.childNode(withName: "upperBound") as! SKSpriteNode)
        bottomBound = (self.childNode(withName: "bottomBound") as! SKSpriteNode)
        upperPoint = (self.childNode(withName: "upperPoint") as! SKSpriteNode)
        bottomPoint = (self.childNode(withName: "bottomPoint") as! SKSpriteNode)
        countLabel = (self.childNode(withName: "countLabel") as! SKLabelNode)
        tapToStartLabel = (self.childNode(withName: "tapToStartLabel") as! SKLabelNode)
        gameOverLabel = (self.childNode(withName: "gameOverLabel") as! SKLabelNode)
        bestScoreLabel = (self.childNode(withName: "bestScoreLabel") as! SKLabelNode)
        let bestScore = getBestScore()
        bestScoreLabel.text = "Best score: \(bestScore)"
        gameOverLabel.alpha = 0
        bottomPoint.alpha = 0
    }
}

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !hasFinished {
            tapToStartLabel.alpha = 0
            movePlayer()
            if enemies.isEmpty {
                spawnEnemies()
            }
        } else {
            let bestScore = getBestScore()
            bestScoreLabel.text = "Best score: \(bestScore)"
            tapToStartLabel.alpha = 0
            gameOverLabel.alpha = 0
            for enemy in enemies {
                enemy.removeFromParent()
                guard let index = enemies.firstIndex(of: enemy) else { abort() }
                enemies.remove(at: index)
            }
            let playerStartPosition = CGPoint(x: 21.335, y: -13.652)
            player.position = playerStartPosition
            count = 0
            hasFinished = false
            movePlayer()
            if enemies.isEmpty {
                spawnEnemies()
            }
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == contact.bodyB.categoryBitMask {
            if contact.bodyA.collisionBitMask == 1 {
                if upperPoint.alpha == 1 {
                    count += 1
                    upperPoint.alpha = 0
                    let randomX = CGFloat.random(in: leftBound...rightBound)
                    let oldY = bottomPoint.position.y
                    let newPosition = CGPoint(x: randomX, y: oldY)
                    bottomPoint.position = newPosition
                    bottomPoint.alpha = 1
                }
            } else {
                if bottomPoint.alpha == 1 {
                    count += 1
                    bottomPoint.alpha = 0
                    let randomX = CGFloat.random(in: leftBound...rightBound)
                    let oldY = upperPoint.position.y
                    let newPosition = CGPoint(x: randomX, y: oldY)
                    upperPoint.position = newPosition
                    upperPoint.alpha = 1
                }
            }
            movePlayer()
        } else {
            stopGame()
        }
    }
    
    fileprivate func stopGame() {
        let previousBestScore = getBestScore()
        if previousBestScore < count || previousBestScore == nil {
            setNewBestScore(score: count)
        }
        hasFinished = true
        player.removeAllActions()
        for enemy in enemies {
            enemy.removeAllActions()
        }
        tapToStartLabel.text =  "Tap to restart"
        tapToStartLabel.alpha = 1
        gameOverLabel.alpha = 1
    }
}

extension GameScene {
    fileprivate func calculateDuration(withSpeed speed: CGFloat) -> TimeInterval {
        let curerntPosition = player.position
        let vectorX = targetPosition.x - curerntPosition.x
        let vectorY = targetPosition.y - curerntPosition.y
        let vectorPosition = CGPoint(x: vectorX, y: vectorY)
        let vectorLength = sqrt((vectorPosition.x * vectorPosition.x) + (vectorPosition.y * vectorPosition.y))
        let timeInterval = vectorLength / speed
        return TimeInterval(timeInterval)
    }
    
    fileprivate func movePlayer() {
        targetPosition = targetPosition == upperPoint.position ? bottomPoint.position : upperPoint.position
        let duration = calculateDuration(withSpeed: 250)
        let movePlayerAction = SKAction.move(to: targetPosition, duration: duration)
        player.run(movePlayerAction)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for enemy in enemies {
            if enemy.position.x == 230 {
                enemies.removeFirst()
                enemy.removeFromParent()
            }
        }
        if let lastEnemy = enemies.last {
            if lastEnemy.position.x > 0 {
                spawnEnemies()
            }
        }
    }
    
    fileprivate func spawnEnemies() {
        let upperBoundY = upperBound.position.y - 50
        let bottomBoundY = bottomBound.position.y + 50
        let randomY = CGFloat.random(in: bottomBoundY...upperBoundY)
        let randomPosition = CGPoint(x: -230, y: randomY)
        let enemy = Enemy.populateEnemy(at: randomPosition)
        self.addChild(enemy)
        enemies.append(enemy)
        let moveEnemyAction = SKAction.move(to: CGPoint(x: 230, y: randomY), duration: 5)
        enemy.run(moveEnemyAction)
    }
}

// MARK: - UserDefaults
extension GameScene {
    private func setNewBestScore(score: Int) {
        let saveData = UserDefaults.standard
        saveData.setValue(score, forKey: "bestScore")
    }
    
    private func getBestScore() -> Int {
        let getData = UserDefaults.standard
        let bestScore = getData.integer(forKey: "bestScore")
        return bestScore
    }
}

