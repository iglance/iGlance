//
//  SidebarViewController.swift
//  iGlance
//
//  Created by Dominik on 18.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {

    @IBOutlet weak var dashboardButtonView: SidebarButtonView!
    @IBOutlet weak var cpuButtonView: SidebarButtonView!
    @IBOutlet weak var memoryButtonView: SidebarButtonView!
    @IBOutlet weak var networkButtonView: SidebarButtonView!
    @IBOutlet weak var fanButtonView: SidebarButtonView!
    @IBOutlet weak var batteryButtonView: SidebarButtonView!

    public var displayViewOf: ((_ sender: SidebarButtonView) -> Void)?

    override func viewDidLoad() {
        // set the storyboard ids of the main views of the buttons
        dashboardButtonView.mainViewStoryboardID = "DashboardStoryboardID"
        cpuButtonView.mainViewStoryboardID = "CpuStoryboardID"
        memoryButtonView.mainViewStoryboardID = "MemoryStoryboardID"
        networkButtonView.mainViewStoryboardID = "NetworkStoryboardID"
        fanButtonView.mainViewStoryboardID = "FanStoryboardID"
        batteryButtonView.mainViewStoryboardID = "BatteryStoryboardID"
    }

    func addOnClickEventHandler(eventHandler: @escaping (_ sender: SidebarButtonView) -> Void) {
        // set the on click events
        dashboardButtonView.onButtonClick(callback: eventHandler)
        cpuButtonView.onButtonClick(callback: eventHandler)
        memoryButtonView.onButtonClick(callback: eventHandler)
        networkButtonView.onButtonClick(callback: eventHandler)
        fanButtonView.onButtonClick(callback: eventHandler)
        batteryButtonView.onButtonClick(callback: eventHandler)
    }
}
