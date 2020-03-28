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

import Foundation
import AppKit

class SegueAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let parentViewController = fromViewController.parent

        if parentViewController != nil && parentViewController is ContentManagerViewController {
            // add the new view controller
            (parentViewController as? ContentManagerViewController)!
                .addNewViewController(viewController: viewController)
        } else if let contentManagerViewControllerHolder = fromViewController as? ContentManagerViewControllerHolder {
            let contentManagerController = contentManagerViewControllerHolder.retrieveContentManagerController()
            contentManagerController.addNewViewController(viewController: viewController)
        }
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let parentVC = viewController.parent as? ContentManagerViewController {
            parentVC.removeCurrentViewController()
        }
    }
}
