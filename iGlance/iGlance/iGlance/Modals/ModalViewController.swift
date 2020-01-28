//
//  ModalViewController.swift
//  iGlance
//
//  Created by Dominik on 10.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class ModalViewController: NSViewController {
    // MARK: -
    // MARK: Private Functions

    /** Callback which is called when the modal will disappear */
    private var onDisappearCallback: (() -> Void)?

    // MARK: -
    // MARK: Function Overrides

    override func viewDidAppear() {
        super.viewDidAppear()

        changeWindowAppearance()

        DDLogInfo("View did appear")
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        // call the callback
        if let unwrappedCallback = self.onDisappearCallback {
            unwrappedCallback()
        }

        DDLogInfo("View will disappear")
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * This function takes a callback which is executed when the modal is about to disappear.
     */
    func onDisappear(callback: @escaping () -> Void) {
        DDLogInfo("Set on disappear callback")
        self.onDisappearCallback = callback
    }

    /**
     * Displays the modal centered and above the given parent window.
     */
    func showModal(parentWindow: NSWindow) {
        // first display the view controller since otherwise its window variable is nil
        presentAsModalWindow(self)

        // make the parent window unmovable
        parentWindow.isMovable = false
        DDLogInfo("Made the parent window unmovable")

        // center the modal on the parent window
        centerWindowOnParent(parentWindow: parentWindow)

        // set the callback to make the main window movable again after the preference window was closed
        self.onDisappear {
            parentWindow.isMovable = true
            DDLogInfo("Made the parent window movable again")
        }
    }

    /**
     * This function centers the modal window on the given parent window.
     */
    func centerWindowOnParent(parentWindow: NSWindow) {
        // get the modal window
        guard let modalWindow = self.view.window else {
            DDLogError("Could not retrieve the modal window")
            return
        }

        // get the position of the main window
        let parentWindowFrame: NSRect = parentWindow.frame

        // get the position of the modal window
        let modalWindowFrame: NSRect = modalWindow.frame

        // position the modal in the center of the main window
        // (coordinate center of a window is in the left lower corner)
        let newWindowPosition = NSPoint(
            x: parentWindowFrame.midX - modalWindowFrame.width / 2,
            y: parentWindowFrame.midY + modalWindowFrame.height / 2
        )
        modalWindow.setFrameTopLeftPoint(newWindowPosition)
        DDLogInfo("Set the position of the modal window to (\(newWindowPosition.x), \(newWindowPosition.y))")

        // make the main window unmovable
        modalWindow.isMovable = false
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Changes the window appearance to match the main window.
     */
    private func changeWindowAppearance() {
        // get the modal window
        guard let modalWindow = self.view.window else {
            DDLogError("Could not retrieve the modal window")
            return
        }

        // change the window appearance by making the titlebar transparent
        modalWindow.styleMask.insert(.fullSizeContentView)
        modalWindow.titlebarAppearsTransparent = true
        modalWindow.titleVisibility = .hidden

        // disable resizing of the window
        modalWindow.styleMask.remove(.resizable)

        // hide all unused window buttons
        modalWindow.standardWindowButton(.zoomButton)?.isHidden = true
        modalWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true

        // make the window unmovable
        modalWindow.isMovable = false

        DDLogInfo("Changed the appearance of the window")
    }
}
