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

        var mainView = iglanceWindow.otherElements["DashboardMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["CpuSidebarButton"].click()
        mainView = iglanceWindow.otherElements["CpuMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["MemorySidebarButton"].click()
        mainView = iglanceWindow.otherElements["MemoryMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["NetworkSidebarButton"].click()
        mainView = iglanceWindow.otherElements["NetworkMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["FanSidebarButton"].click()
        mainView = iglanceWindow.otherElements["FanMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["BatterySidebarButton"].click()
        mainView = iglanceWindow.otherElements["BatteryMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.otherElements["DiskSidebarButton"].click()
        mainView = iglanceWindow.otherElements["DiskMainView"].waitForExistence(timeout: 5)
        XCTAssert(mainView)

        iglanceWindow.buttons[XCUIIdentifierCloseWindow].click()
    }

    func testPreferenceWindow() throws {
        let app = XCUIApplication()
        app.launch()

        openMainWindow(app: app)

        app.windows["iGlance"].children(matching: .button).element(boundBy: 0).click()
        app.dialogs["Preference Modal View Controller"].buttons[XCUIIdentifierCloseWindow].click()
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
