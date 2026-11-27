//
//  GameScene.swift
//  HackingWithSwift-PocketHockey
//
//  Created by Michael Jones on 27/11/2026.
//

import SpriteKit

class GameScene: SKScene {
    let neonMagenta = SKColor(red: 1, green: 0.2, blue: 0.9, alpha: 1)
    
    let paddleRadius = 32.0
    var rinkFrame = CGRect.zero
    
    var player: SKShapeNode!
    var world = SKNode()
    
    /// This is called when the GameScene is first presented by the SpritKit view (SKView).
    /// It is the starting point for setting up the scenes initial state.
    override func didMove(to view: SKView) {
        
    }
    
}
