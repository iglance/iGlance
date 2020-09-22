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

/**
 * Structure to save the ID of a NSView of a sidebar button, its corresponding
 * main view storyboard ID which is displayed in the container view when the button is clicked
 * and the name of the icon of the sidebar button.
 */
struct SidebarButtonID {
    let buttonViewID: String
    let mainViewStoryboardID: String
    let buttonIconID: String
}

enum SidebarButton: CaseIterable {
    case Dashboard
    case Cpu
    case Memory
    case Network
    case Fan
    case Battery
    case Disk
    case Settings

    var instance: SidebarButtonID {
        switch self {
        case .Dashboard:
            return SidebarButtonID(buttonViewID: "DashboardButtonView", mainViewStoryboardID: "DashboardStoryboardID", buttonIconID: "DashboardMenuIcon")
        case .Cpu:
            return SidebarButtonID(buttonViewID: "CpuButtonView", mainViewStoryboardID: "CpuStoryboardID", buttonIconID: "CpuMenuIcon")
        case .Memory:
            return SidebarButtonID(buttonViewID: "MemoryButtonView", mainViewStoryboardID: "MemoryStoryboardID", buttonIconID: "MemoryMenuIcon")
        case .Network:
            return SidebarButtonID(buttonViewID: "NetworkButtonView", mainViewStoryboardID: "NetworkStoryboardID", buttonIconID: "NetworkMenuIcon")
        case .Fan:
            return SidebarButtonID(buttonViewID: "FanButtonView", mainViewStoryboardID: "FanStoryboardID", buttonIconID: "FanMenuIcon")
        case .Battery:
            return SidebarButtonID(buttonViewID: "BatteryButtonView", mainViewStoryboardID: "BatteryStoryboardID", buttonIconID: "BatteryMenuIcon")
        case .Disk:
            return SidebarButtonID(buttonViewID: "DiskButtonView", mainViewStoryboardID: "DiskStoryboardID", buttonIconID: "DiskMenuIcon")
        case .Settings:
            return SidebarButtonID(buttonViewID: "SettingsButtonView", mainViewStoryboardID: "SettingsStoryboardID", buttonIconID: "SettingsMenuIcon")
        }
    }
}

class SidebarViewController: NSViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var sidebarButtonStackView: NSStackView!

    // MARK: -
    // MARK: Function Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // set the storyboard ids of the main views and the the icon ids of the buttons
        for sidebarButton in SidebarButton.allCases {
            guard let buttonView = getSidebarButtonWith(identifier: sidebarButton.instance.buttonViewID) else {
                DDLogError("Could not get the sidebar button view with the identifier \(sidebarButton.instance.buttonViewID)")
                continue
            }

            // set the story board ids
            buttonView.mainViewStoryboardID = sidebarButton.instance.mainViewStoryboardID

            // set the icon ids
            buttonView.iconName = sidebarButton.instance.buttonIconID
        }

        // on startup select the dashboard
        getSidebarButtonWith(identifier: SidebarButton.Dashboard.instance.buttonViewID)?.highlighted = true

        // add a callback to change the logo depending on the current theme
        ThemeManager.onThemeChange(self, #selector(onThemeChange))

        // call the theme change callback once on startup to set the correct colors
        onThemeChange()
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Adds a on click event handler to each sidebar button view.
     * This event handler is called when one of the buttons is pressed.
     *
     * - Parameter eventHandler: The given callback function which is called when the button is clicked.
     */
    func addOnClickEventHandler(eventHandler: @escaping (_ sender: SidebarButtonView) -> Void) {
        // create a proxy event handler to trigger the onButtonClick function in this class
        let proxyEventHandler = { (_ sender: SidebarButtonView) -> Void in
            self.onButtonClick(sender)
            eventHandler(sender)
        }

        // set the on click events
        for sidebarButton in SidebarButton.allCases {
            getSidebarButtonWith(identifier: sidebarButton.instance.buttonViewID)?.onButtonClick(callback: proxyEventHandler)
        }
    }

    /**
     * Called when a button in the sidebar is clicked.
     *
     * - Parameter sender: The sidebar button view which was clicked.
     */
    func onButtonClick(_ sender: SidebarButtonView) {
        for sidebarButton in SidebarButton.allCases {
            guard let buttonView = getSidebarButtonWith(identifier: sidebarButton.instance.buttonViewID) else {
                DDLogError("Could not get the sidebar button view with the identifier \(sidebarButton.instance.buttonViewID)")
                continue
            }

            if buttonView.identifier == sender.identifier {
                buttonView.highlighted = true
                buttonView.updateFontColor()
            } else if buttonView.highlighted {
                buttonView.highlighted = false
                buttonView.updateFontColor()
            }
        }
    }

    func clickSidebarButton(sidebarButtonID: SidebarButtonID) {
        guard let buttonView = getSidebarButtonWith(identifier: sidebarButtonID.buttonViewID) else {
            DDLogError("Could not get the sidebar button view with the identifier \(sidebarButtonID.buttonViewID)")
            return
        }

        buttonView.mouseDown(with: NSEvent())
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Callback which is called when the theme is changed.
     */
    @objc
    private func onThemeChange() {
        // update the sidebar button font color
        for sidebarButton in SidebarButton.allCases {
            getSidebarButtonWith(identifier: sidebarButton.instance.buttonViewID)?.updateFontColor()
        }
    }

    /**
     * Gets the view instance of the button with the given identifier.
     * - Returns: The SidebarButtonView instance. If no button with the given identifier was found nil is returned.
     */
    private func getSidebarButtonWith(identifier: String) -> SidebarButtonView? {
        // search for the button in the sidebar using BFS
        var viewsToSearch: [NSView] = [self.view]
        while !viewsToSearch.isEmpty {
            // get the current view
            guard let currentSearchView = viewsToSearch.popLast() else {
                DDLogError("Could not search view since it is nil")
                continue
            }

            // check if the current view is the one we are searching
            if currentSearchView.identifier?.rawValue == identifier {
                return (currentSearchView as? SidebarButtonView)
            }

            // add all the subviews to the search stack
            for view in currentSearchView.subviews {
                viewsToSearch.insert(view, at: 0)
            }
        }

        return nil
    }
}
