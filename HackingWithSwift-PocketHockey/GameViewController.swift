//
//  GameViewController.swift
//  HackingWithSwift-PocketHockey
//
//  Created by Michael Jones on 27/11/2026.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // When we've layed our the SubViews (when the UIViewController knows it's size). The game scene will be made at the same size.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Get the view and check it's an SKView, then make sure the scene of the skView is nil. Otherwise bail out.
        guard let skView = view as? SKView, skView.scene == nil else { return }
        
        skView.presentScene(GameScene.init(size: skView.bounds.size))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
