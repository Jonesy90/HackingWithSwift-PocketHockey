//
//  GameScene.swift
//  HackingWithSwift-PocketHockey
//
//  Created by Michael Jones on 27/11/2026.
//

import SpriteKit

/// Creates static constraints to define bitmask values of different physics categories used in SpriteKit's physics system.
enum PhysicsCategory {
    static let puck: UInt32 = 1
    static let wall: UInt32 = 2
    static let paddle: UInt32 = 4
    static let goal: UInt32 = 8
}

/// Objective: A way to keep numbers inside a particular range.
/// Solution: An extension to CGFloat that will check if the number falls below or above some range. Returning to the nearest boundary if it does or the original number if it doesn't.
extension CGFloat {
    func clamped(to range: ClosedRange<Double>) -> Double {
        if self < range.lowerBound {
            range.lowerBound
        } else if self > range.upperBound {
            range.upperBound
        } else {
            self
        }
    }
}

// CGVector: Is used with SpriteKit and Core Graphics to represent a vector in 2D space (dx = horizontal, dy = vertical).
/// Calculates the vectors speed and provides a vector speed cap (limit) to keep the vector movement under control.
extension CGVector {
    /// A computed property to determine the speed of the node using pythagorean theorem.
    /// This gives the distance from the origin to the point, which also referred to as the speed of the vector.
    var speed: Double {
        hypot(dx, dy)
    }
    
    /// Ensures the speed vector does not exceed the maximum speed.
    func limited(to maxSpeed: Double) -> CGVector {
        guard speed > maxSpeed else { return self }
        
        /// If the speed does exceed the maximum speed, a scaling factor value is created and applied.
        /// This will update the vector so it matches the maximum speed instead of exceeding it.
        let scale = maxSpeed / speed
        return CGVector(dx: dx * scale, dy: dy * scale)
    }
}

class GameScene: SKScene {
    let neonMagenta = SKColor(red: 1, green: 0.2, blue: 0.9, alpha: 1)
    let neonCyan = SKColor(red: 0.2, green: 0.9, blue: 1, alpha: 1)
    
    let paddleRadius = 32.0
    let puckRadius = 16.0
    
    var rinkFrame = CGRect.zero
    
    var player: SKShapeNode!
    var puck: SKShapeNode!
    var world = SKNode()
    
    let playerSpeed = 2_500.0
    let maxPuckSpeed = 1_500.0
    
    var playerTarget: CGPoint?
    
    
    /// This is called when the GameScene is first presented by the SpritKit view (SKView).
    /// It is the starting point for setting up the scenes initial state.
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero // Disables the gravity within the 
        
        rinkFrame = CGRect(x: 16, y: 32, width: size.width - 32, height: size.height - 152) // Provides the frame of the rinkFrame.
        
        /// Adds the world node to the scene.
        /// In this case, the world node contains the 'paddle' and 'paddleHandle' nodes.
        addChild(world)
        player = makePaddle(color: neonMagenta, y: rinkFrame.minY + 120) // Creates a paddle node as assigns it to the player variable.
    }
    
    /// Creates a circular paddle node
    /// - Parameters:
    ///   - color: Colour of the paddle.
    ///   - y: y position of the paddle in the rinkFrame.
    /// - Returns: A paddle of type SKShapeNode
    func makePaddle(color: SKColor, y: Double) -> SKShapeNode {
        /// Desgining how the paddle looks.
        let paddle = SKShapeNode(circleOfRadius: paddleRadius) // Creates a new SKShapeNode in a shape of a circle with the radius of 'paddleRadius' (32.0).
        paddle.position = CGPoint(x: rinkFrame.midX, y: y) // Positions the node in the middle of the middle of the rinkFrame (x axis) and the y position is the parameter that's passed in.
        paddle.fillColor = color.withAlphaComponent(0.2) // Fills the colour of the paddle to the parameter that was passed in with a slight opacity/transparency look.
        paddle.strokeColor = color // Fills the outline of the node with the color passed in.
        paddle.lineWidth = 3
        paddle.glowWidth = 10
        
        let paddleHandle = SKShapeNode(circleOfRadius: paddleRadius * 0.4) // Produces a smaller circle with a radius of the 'paddleRadius' but 40% of the size.
        paddleHandle.fillColor = color.withAlphaComponent(0.5) // Fills the colour of the paddle to the parameter that was passed in with a slight opacity/transparency look.
        paddleHandle.strokeColor = color // Fills the outline of the node with the color passed in.
        paddleHandle.glowWidth = 3
        paddle.addChild(paddleHandle) // The 'paddleHandle' node is added to the 'paddle' node as a child.
        
        /// Physics configuration for the paddle body.
        let body = SKPhysicsBody(circleOfRadius: paddleRadius)
        body.friction = 0 // The body has no friction so it will not slow down as it moves along the rink walls.
        body.restitution = 0.9 // The bounciness of the body. The higher the number the more bouncy it is.
        body.linearDamping = 8 // The paddle eventually glide to a stop natuarally when the user lifts their finger from the screen.
        body.density = 10 // The paddle is heavier than the puck.
        body.allowsRotation = false // The paddle will never rotate.
        body.usesPreciseCollisionDetection = true
        
        body.categoryBitMask = PhysicsCategory.paddle
        body.collisionBitMask = PhysicsCategory.wall
        paddle.physicsBody = body
        
        world.addChild(paddle) // The fully constructed 'paddle' node (including the 'paddleHandle' node) is added to the 'world' node as a child.
        
        return paddle // Returns the fully constructed 'paddle' node to be used as a property later.
    }
    
    /// Creates, configures and returns a SKShapeNode that represents the puck. It's responsible for the pucks visual appearance and the physics-based behaviour.
    /// - Returns: Returns the puck node as SKShapeNode
    func makePuck() -> SKShapeNode {
        /// Designing how the puck looks.
        let puck = SKShapeNode(circleOfRadius: puckRadius)
        puck.fillColor = neonCyan.withAlphaComponent(0.35)
        puck.strokeColor = neonCyan
        puck.lineWidth = 2
        puck.glowWidth = 8
        
        /// Configures the phyics behaviour of the puck node.
        let body = SKPhysicsBody(circleOfRadius: puckRadius)
        body.friction = 0
        body.restitution = 0.95
        body.linearDamping = 0.25
        body.allowsRotation = false
        body.usesPreciseCollisionDetection = true
        
        /// Configures the collision categories of the puck node.
        body.categoryBitMask = PhysicsCategory.puck // Identifies the body of the node as a puck for physics checks.
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.paddle // Other body nodes the puck node can collide with (and bounce off).
        body.contactTestBitMask = PhysicsCategory.wall | PhysicsCategory.paddle | PhysicsCategory.goal // Notifies when the puck node collides with any of these other body nodes.
        
        /// Applies the physics body to the puck node and adds it to the world node.
        puck.physicsBody = body
        world.addChild(puck)
        
        return puck
    }
    
    /// Used to move the paddle (SKShapeNode) toward a target position (CGPoint). It clamps the paddle so it stays within the rink bountries, calculates the velocity and limits the paddle speed.
    /// - Parameters:
    ///   - paddle: The SKShapeNode representing the paddle to move.
    ///   - target: The CGPoint to where the SKShapNode is going to move to.
    ///   - yRange: The allowed vertical range (y-coordinates) for the paddle.
    ///   - maxSpeed: The maximum speed the paddle node is allowed to move.
    func drive(_ paddle: SKShapeNode, toward target: CGPoint, yRange: ClosedRange<Double>, maxSpeed: Double) {
        /// The paddle is clamped inbetween the left and right side of the rink.
        let targetX = target.x.clamped(to: (rinkFrame.minX + paddleRadius)...(rinkFrame.maxX - paddleRadius))
        /// The paddle is clamped between the the bottom and top of the rink.
        let targetY = target.y.clamped(to: yRange)
        
        /// Calculates the paddles velocity by calculating the difference between the targetX and targetY.
        let velocity = CGVector(dx: (targetX - paddle.position.x) * 12, dy: (targetY - paddle.position.y) * 12)
        /// Limits the speed of the paddles velocity to the maximum speed applied.
        paddle.physicsBody?.velocity = velocity.limited(to: maxSpeed)
    }
    
    /// Repositions and launches the puck at the start of play (or after a goal), sending it towards a given direction.
    /// - Parameter direction: <#direction description#>
    func serve(toward direction: Double) {
        puck.position = CGPoint(x: rinkFrame.midX, y: rinkFrame.midY) // Sets the pucks location to the middle of the screen.
        puck.isHidden = false // Makes the puck visable, in case it was hidden after a previous event.
        puck.setScale(0.1) // Starts the puck at a very small scale.
        puck.run(.scale(to: 1, duration: 0.2)) // Returns the punk back to it's original size after a certain amount of time.
        puck.physicsBody?.isDynamic = true // Guarantees the puck will move and interact physics (collision, forces etc).
        puck.physicsBody?.velocity = CGVector(dx: .random(in: -150...150), dy: direction * 300) // Sets the puck to move in a certain direction.
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let playerTarget {
            drive(
                player,
                toward: playerTarget,
                yRange: (rinkFrame.minY + paddleRadius)...(rinkFrame.midY - paddleRadius),
                maxSpeed: playerSpeed
            )
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerTarget = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerTarget = touches.first?.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerTarget = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerTarget = nil
    }
    
}
