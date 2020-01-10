//
//  AboutModalViewController.swift
//  iGlance
//
//  Created by Dominik on 10.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import os.log

class AboutModalViewController: ModalViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var logoImage: NSImageView!
    @IBOutlet private var versionLabel: NSTextField!

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        self.setVersionLabel()
        
        // add a callback to change the logo depending on the current theme
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(onThemeChange),
            name: .AppleInterfaceThemeChangedNotification,
            object: nil
        )

        // add the correct logo image at startup
        changeLogo()
    }

    // MARK: -
    // MARK: Private Functions

    @objc
    private func onThemeChange() {
        changeLogo()
    }
    
    /**
     * Set the version label to the current app version.
     */
    private func setVersionLabel() {
        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            os_log("Could not retrieve the version of the app", type: .error)
            return
        }
        versionLabel.stringValue = appVersion
    }
    
    /**
     * Sets the logo according to the current os theme.
     */
    private func changeLogo() {
        if ThemeManager.isDarkTheme() {
            logoImage.image = NSImage(named: "iGlance_logo_white")
        } else {
            logoImage.image = NSImage(named: "iGlance_logo_black")
        }
    }
}
