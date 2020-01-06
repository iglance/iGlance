//
//  MainView.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

/**
 * Parent class for the main views.
 */
class MainViewViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // create the visual effect view for the background blur
        let visualEffectView = NSVisualEffectView(frame: self.view.frame)
        visualEffectView.material = NSVisualEffectView.Material.underWindowBackground
        // add the visual effect view
        self.view.addSubview(visualEffectView, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
    }
}
