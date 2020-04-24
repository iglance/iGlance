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

/**
 * Parent class for the main views.
 */
class MainViewViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // create the visual effect view for the background blur
        let visualEffectView = NSVisualEffectView(frame: self.view.frame)
        visualEffectView.material = NSVisualEffectView.Material.menu
        // add the visual effect view
        self.view.addSubview(visualEffectView, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
        // trigger didSet methods of all outlets to update GUI
        updateGUIComponents()
    }


    func updateGUIComponents() {
        // Implement in inherited class
        fatalError("Function 'updateGUIComponents' not implemented")
    }
}
