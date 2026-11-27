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

class GameScene: SKScene {
    let neonMagenta = SKColor(red: 1, green: 0.2, blue: 0.9, alpha: 1)
    
    let paddleRadius = 32.0
    var rinkFrame = CGRect.zero
    
    var player: SKShapeNode!
    var world = SKNode()
    
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
        
        world.addChild(paddle) // The fully constructed 'paddle' node (including the 'paddleHandle' node) is added to the 'world' node as a child.
        
        return paddle // Returns the fully constructed 'paddle' node to be used as a property later.
    }
    
}
