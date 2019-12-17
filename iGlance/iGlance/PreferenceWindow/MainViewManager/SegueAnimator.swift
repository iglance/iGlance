//
//  SegueAnimator.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import AppKit

class SegueAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        let parentViewController = fromViewController.parent

        if(parentViewController != nil) && parentViewController is ContentManagerViewController {
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
