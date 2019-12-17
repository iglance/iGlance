//
//  ContentManagerViewController.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class ContentManagerViewController: NSViewController {

    @IBOutlet weak var subViewControllerManager: NSView!

    var currentViewController: NSViewController!

    /**
     * Displays the given view
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
     * Removes the current view controller
     */
    func removeCurrentViewController() {
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()
    }

    func display(viewController: NSViewController) {
        // first remove the currently dispalyed view controller
        removeCurrentViewController()
        // add the new view controller to be displayed
        addNewViewController(viewController: viewController)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        currentViewController = (segue.destinationController as? NSViewController)
    }
}
