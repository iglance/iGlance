//
//  ContentManagerViewController.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class ContentManagerViewController: NSViewController {

    // MARK: -
    // MARK: Outlets
    @IBOutlet weak var subViewControllerManager: NSView!

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
