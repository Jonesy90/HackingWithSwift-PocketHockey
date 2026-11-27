//
//  GameViewController.swift
//  HackingWithSwift-PocketHockey
//
//  Created by Michael Jones on 27/11/2026.
//

import UIKit
import SpriteKit
import GameplayKit

/// Handles the setup and configuration of the game scene, as well as UI preferences for orientation and UI visability.
class GameViewController: UIViewController {
    
    /// Is called by UIKit after the view controllers view has laid out it's subviews.
    /// Why?: This ensures the game scene is always created at the correct size. This is important just in case the device orientation or screen size changes.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 1. Checks if the main view can be cast as a SKView.
        /// 2. If #1 is true and there currenly no scene, it will create and present a new GameScene sized to match the SKView.
        guard let skView = view as? SKView, skView.scene == nil else { return }
        
        skView.presentScene(GameScene.init(size: skView.bounds.size))
    }
    
    /// Restricts the app to portrait orientation only.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    /// Status bar is hidden.
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    /// Request that the home bar (at the bottom of some iPhones) is hidden.
    override var prefersHomeIndicatorAutoHidden: Bool {
        true
    }
}
