//
//  PreferenceModalViewController.swift
//  iGlance
//
//  Created by Dominik on 06.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class PreferenceModalViewController: NSViewController {
    private var onDisappearCallback: (() -> Void)?

    // MARK: -
    // MARK: Function Overrides

    override func viewDidAppear() {
        super.viewDidAppear()

        // change the window appearance by making the titlebar transparent
        self.view.window?.styleMask.insert(.fullSizeContentView)
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.titleVisibility = .hidden

        // disable resizing of the window
        self.view.window?.styleMask.remove(.resizable)

        // hide all unused window buttons
        self.view.window?.standardWindowButton(.zoomButton)?.isHidden = true
        self.view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true

        // make the window unmovable
        self.view.window?.isMovable = false
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        // call the callback
        if let unwrappedCallback = self.onDisappearCallback {
            unwrappedCallback()
        }
    }

    // MARK: -
    // MARK: Instance Functions

    func onDisappear(callback: @escaping () -> Void) {
        self.onDisappearCallback = callback
    }
}
