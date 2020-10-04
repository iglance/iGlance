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

class MainWindowViewController: NSViewController {
    // MARK: -
    // MARK: Instance Variables
    var contentManagerViewController: ContentManagerViewController?
    var sidebarViewController: SidebarViewController?

    // MARK: -
    // MARK: Function Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // add the on click event handler to the buttons of the sidebar
        sidebarViewController?.addOnClickEventHandler(eventHandler: displayViewOf(sender:))

        (self.view as! BackgroundColorView).backgroundColor = ThemeManager.currentTheme().borderColor
        ThemeManager.onThemeChange(self, #selector(self.onThemeChange))
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // get the view controller of the main view and the sidebar
        if segue.destinationController is ContentManagerViewController {
            contentManagerViewController = (segue.destinationController as? ContentManagerViewController)
        } else if segue.destinationController is SidebarViewController {
            sidebarViewController = (segue.destinationController as? SidebarViewController)
        }
    }

    override func viewWillAppear() {
        // show the dock icon of the app
        NSApp.setActivationPolicy(.regular)
    }

    // MARK: -
    // MARK: Private Functions
    /**
     * Displays the main view of the given sidebar button view.
     * This function is called when the sidebar button is clicked.
     */
    private func displayViewOf(sender: SidebarButtonView) {
        if let viewController = storyboard?.instantiateController(withIdentifier: sender.mainViewStoryboardID!) {
            contentManagerViewController?.addNewViewController(viewController: ((viewController as? MainViewViewController)!))
        }
    }

    @objc
    private func onThemeChange() {
        (self.view as! BackgroundColorView).backgroundColor = ThemeManager.currentTheme().borderColor
    }
}
