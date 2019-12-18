//
//  ViewController.swift
//  iGlance
//
//  Created by Dominik on 15.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class PreferenceViewController: NSViewController {

    var contentManagerViewController: ContentManagerViewController?
    var sidebarViewController: SidebarViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        sidebarViewController?.addOnClickEventHandler(eventHandler: displayViewOf(sender:))
    }

    /**
     * Displays the main view of the given sidebar button view
     */
    private func displayViewOf(sender: SidebarButtonView) {
        if let viewController = storyboard?.instantiateController(withIdentifier: sender.mainViewStoryboardID!) {
            contentManagerViewController?.addNewViewController(viewController: ((viewController as? NSViewController)!))
        }
    }

    /**
     * Returns the content manager view controller which manages the main views of the preference window
     */
    func retrieveContentManagerController() -> ContentManagerViewController? {
        return self.contentManagerViewController
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.destinationController is ContentManagerViewController {
            contentManagerViewController = (segue.destinationController as? ContentManagerViewController)
        } else if segue.destinationController is SidebarViewController {
            sidebarViewController = (segue.destinationController as? SidebarViewController)
        }
    }
}
