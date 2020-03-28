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

class ContentManagerViewController: NSViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var subViewControllerManager: NSView!

    // MARK: -
    // MARK: Instance Variables
    var currentViewController: NSViewController!

    // MARK: -
    // MARK: Function Overrides

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // get the view controller that is currently displayed
        currentViewController = (segue.destinationController as? NSViewController)
    }

    // MARK: -
    // MARK: Instance Functions

    /**
     * Add the given view controller as a sub-view.
     * - Parameter viewController: The given view controller to display.
     */
    func addNewViewController(viewController: NSViewController) {
        // add the view controller as child
        addChild(viewController)
        // set the frame of the viewcontroller
        viewController.view.frame = (currentViewController?.view.frame)!
        // add the subview
        view.addSubview(viewController.view)
        // set the current view controller
        currentViewController = viewController
    }

    /**
     * Removes the current view controller.
     */
    func removeCurrentViewController() {
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
    }

    /**
     * Displays the given view controller as a sub-view.
     */
    func display(viewController: NSViewController) {
        // first remove the currently dispalyed view controller
        removeCurrentViewController()
        // add the new view controller to be displayed
        addNewViewController(viewController: viewController)
    }
}
