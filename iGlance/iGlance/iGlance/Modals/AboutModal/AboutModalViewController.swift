//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Cocoa
import CocoaLumberjack

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
        ThemeManager.onThemeChange(self, #selector(onThemeChange))

        // add the correct logo image at startup
        changeLogo()

        DDLogInfo("View will appear")
    }

    // MARK: -
    // MARK: Private Functions

    @objc
    private func onThemeChange() {
        DDLogInfo("Theme changed")
        changeLogo()
    }

    /**
     * Set the version label to the current app version.
     */
    private func setVersionLabel() {
        // get the version of the app
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("Could not retrieve the version of the app")
            return
        }
        versionLabel.stringValue = appVersion
    }

    private func setLicenseView() {
        // get the property list as a dictionary
        guard let plistPath = Bundle.main.path(forResource: "Credits", ofType: "plist") else {
            DDLogError("Could not retrieve Credits.plist")
            return
        }
        guard let creditsDict = NSDictionary(contentsOfFile: plistPath) else {
            DDLogError("Could not cast Credits.plist to a dictionary")
            return
        }

        var licenseViewString = ""
        for key in creditsDict {
            guard let library = creditsDict[key.key] as? [String: String] else {
                DDLogError("Could not cast the library to a [String : String] dictionary")
                continue
            }

            guard let libUrl = library["URL"] else {
                DDLogError("Could not unpack the url of a library")
                continue
            }
            guard let libLicense = library["License"] else {
                DDLogError("Could not unpack the license of a library")
                continue
            }

            // add the title and the url of the library
            var libraryString = "\(key.key) \(libUrl) \n\n"

            // add the license of the library
            libraryString += libLicense

            // add the library string to the license view
            if key.key as? String == "iGlance" {
                // if the current license is from iGlance put it in front of any other license
                licenseViewString = libraryString + "\n\n\n\n" + licenseViewString
            } else {
                licenseViewString += (licenseViewString.isEmpty ? "" : "\n\n\n\n") + libraryString
            }
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
