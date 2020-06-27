//
//  iGlanceUITests.swift
//  iGlanceUITests
//
//  Created by Dominik on 27.06.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

// swiftlint:disable type_name
import XCTest

class iGlanceUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSidebarButtons() throws {
        let app = XCUIApplication()
        app.launch()

        openMainWindow(app: app)

        let iglanceWindow = app.windows["iGlance"]
        iglanceWindow.otherElements["CpuSidebarButton"].click()
        iglanceWindow.otherElements["MemorySidebarButton"].click()
        iglanceWindow.otherElements["NetworkSidebarButton"].click()
        iglanceWindow.otherElements["FanSidebarButton"].click()
        iglanceWindow.otherElements["BatterySidebarButton"].click()
        iglanceWindow.otherElements["DiskSidebarButton"].click()
        iglanceWindow.buttons[XCUIIdentifierCloseWindow].click()
    }

    // MARK: Private Functions
    // MARK: -

    private func openMainWindow(app: XCUIApplication) {
        // check if the window is already open
        // swiftlint:disable:next empty_count
        if app.windows.count > 0 {
            return
        }

        var foundActiveMenuBarIcon = false
        var index = 0
        var activeMenuBarItem: XCUIElement!
        while !foundActiveMenuBarIcon {
            activeMenuBarItem = app
            .children(matching: .menuBar)
            .element(boundBy: 1)
            .children(matching: .statusItem)
            .element(boundBy: index)

            foundActiveMenuBarIcon = activeMenuBarItem.isEnabled

            index += 1
        }

        activeMenuBarItem.click()
        app.menuBars/*@START_MENU_TOKEN@*/.menuItems["showMainWindow"]/*[[".statusItems",".menus",".menuItems[\"Show window\"]",".menuItems[\"showMainWindow\"]"],[[[-1,3],[-1,2],[-1,1,2],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/.click()
    }
}
