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
    @IBOutlet private var licenseTextView: NSTextView!

    // MARK: -
    // MARK: Function Overrides

    override func viewWillAppear() {
        super.viewWillAppear()

        self.setVersionLabel()
        self.setLicenseView()

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

    private func setLicenseView() {
        // get the property list as a dictionary
        guard let plistPath = Bundle.main.path(forResource: "Credits", ofType: "plist") else {
            os_log("Could not retrieve Credits.plist", type: .error)
            return
        }
        guard let creditsDict = NSDictionary(contentsOfFile: plistPath) else {
            os_log("Could not cast Credits.plist to a dictionary", type: .error)
            return
        }

        var licenseViewString = ""
        for (index, key) in creditsDict.enumerated() {
            guard let library = creditsDict[key.key] as? [String: String] else {
                os_log("Could not cast the library to a [String : String] dictionary", type: .error)
                continue
            }

            guard let libUrl = library["URL"] else {
                os_log("Could not unpack the url of a library", type: .error)
                continue
            }
            guard let libLicense = library["License"] else {
                os_log("Could not unpack the license of a library", type: .error)
                continue
            }

            // add the title and the url of the library
            var libraryString = "\(key.key) \(libUrl) \n\n"

            // add the license of the library
            libraryString += libLicense

            // add the library string to the license view
            licenseViewString += (index == 0 ? "" : "\n\n\n\n") + libraryString
        }

        // set the content of the license text view
        licenseTextView.string = licenseViewString
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
