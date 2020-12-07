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

class MainWindowController: NSWindowController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var mainWindow: NSWindow! {
        didSet {
            mainWindow.delegate = self.mainWindowDelegate
            mainWindow.backgroundColor = ThemeManager.currentTheme().titleBarBackgroundColor
        }
    }

    // MARK: -
    // MARK: Instance Variables

    // swiftlint:disable:next weak_delegate
    private let mainWindowDelegate = MainWindowDelegate()

    override init(window: NSWindow?) {
        super.init(window: window)

        // show the dock icon if no menu bar item is visible
        // this prevents that the app is running but the user has no means to interact with the app
        if AppDelegate.menuBarItemManager.menuBarItems.contains(where: { $0.statusItem.isVisible == true }) {
            NSApp.setActivationPolicy(.regular)
            DDLogInfo("Dock icon is shown because no menu bar icon is visible")
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // show the dock icon if no menu bar item is visible
        // this prevents that the app is running but the user has no means to interact with the app
        if !AppDelegate.menuBarItemManager.menuBarItems.contains(where: { $0.statusItem.isVisible == true }) {
            NSApp.setActivationPolicy(.regular)
            DDLogInfo("Dock icon is shown because no menu bar icon is visible")
        }
    }

    // MARK: -
    // MARK: Function Overrides
    override func windowDidLoad() {
        // set a callback to adjust the background color of the window if the theme changes
        ThemeManager.addThemeChangeObserver(self) { _ in
            self.mainWindow.backgroundColor = ThemeManager.currentTheme().titleBarBackgroundColor
            self.mainWindow.update()
        }

        // hide the zoom window button
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true

        // center the window
        self.window?.center()
    }
}
