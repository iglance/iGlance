//
//  SidebarViewController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {

    struct SidebarButtonIDs {
        let buttonViewID: String
        let mainViewStoryboardID: String
    }

    @IBOutlet weak var sidebarButtonStackView: NSStackView!

    private var sidebarButtonViewIDs: [SidebarButtonIDs] = [
        SidebarButtonIDs(buttonViewID: "DashboardButtonView", mainViewStoryboardID: "DashboardStoryboardID"),
        SidebarButtonIDs(buttonViewID: "CpuButtonView", mainViewStoryboardID: "CpuStoryboardID"),
        SidebarButtonIDs(buttonViewID: "MemoryButtonView", mainViewStoryboardID: "MemoryStoryboardID"),
        SidebarButtonIDs(buttonViewID: "NetworkButtonView", mainViewStoryboardID: "NetworkStoryboardID"),
        SidebarButtonIDs(buttonViewID: "FanButtonView", mainViewStoryboardID: "FanStoryboardID"),
        SidebarButtonIDs(buttonViewID: "BatteryButtonView", mainViewStoryboardID: "BatteryStoryboardID")
    ]

    public var displayViewOf: ((_ sender: SidebarButtonView) -> Void)?

    override func viewDidLoad() {
        // set the storyboard ids of the main views of the buttons
        for identifier in sidebarButtonViewIDs {
            let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID)!

            buttonView.mainViewStoryboardID = identifier.mainViewStoryboardID
        }

        getSidebarButtonWith(identifier: sidebarButtonViewIDs[0].buttonViewID)?.highlighted = true
    }

    func addOnClickEventHandler(eventHandler: @escaping (_ sender: SidebarButtonView) -> Void) {
        // create a proxy event handler to trigger the onButtonClick function in this class
        let proxyEventHandler = { (_ sender: SidebarButtonView) -> Void in
            self.onButtonClick(sender)
            eventHandler(sender)
        }

        // set the on click events
        for identifier in sidebarButtonViewIDs {
            getSidebarButtonWith(identifier: identifier.buttonViewID)?.onButtonClick(callback: proxyEventHandler)
        }
    }

    func onButtonClick(_ sender: SidebarButtonView) {
        for identifier in sidebarButtonViewIDs {
            let buttonView = getSidebarButtonWith(identifier: identifier.buttonViewID)

            if buttonView?.identifier == sender.identifier {
                buttonView?.highlighted = true
            } else {
                buttonView?.highlighted = false
            }
        }
    }

    private func getSidebarButtonWith(identifier: String) -> SidebarButtonView? {
        for subView in sidebarButtonStackView.subviews where subView.identifier?.rawValue == identifier {
            return (subView as? SidebarButtonView)!
        }

        return nil
    }
}
