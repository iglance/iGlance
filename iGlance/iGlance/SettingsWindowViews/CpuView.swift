//
//  CpuTempView.swift
//  iGlance
//
//  Created by Dominik on 27.10.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CpuView: NSViewController {
    // define the color values of the cpu icon
    var colRedCPU: CGFloat = 0
    var colBlueCPU: CGFloat = 0
    var colGreenCPU: CGFloat = 0
    var colAlphaCPU: CGFloat = 0

    // define the outlet and the action of the checkbox which is activating and deactivating the cpu utilization icon
    @IBOutlet var cbCPUUtil: NSButton! {
        didSet {
            cbCPUUtil.state = AppDelegate.UserSettings.userWantsCPUUtil ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbCPUUtil_clicked(_: NSButton) {
        let checked = (cbCPUUtil.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsCPUUtil = checked
        CpuUsageComponent.sItemCpuUtil.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsCPUUtil")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.cpuUtil) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.cpuUtil)
    }

    // define the outlet and the action of the checkbox which is displaying the temperature of the cpu
    @IBOutlet var cbCPUTemp: NSButton! {
        didSet {
            cbCPUTemp.state = AppDelegate.UserSettings.userWantsCPUTemp ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbCPUTemp_clicked(_: NSButton) {
        let checked = (cbCPUTemp.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsCPUTemp = checked
        CpuTempComponent.sItemCPUTemp.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsCPUTemp")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.cpuTemp) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.cpuTemp)
    }

    // define the outlet and the action of the drop down menu to choose celcius or fahrenheit as measurement unit
    @IBOutlet var ddTempUnit: NSPopUpButton! {
        didSet {
            switch AppDelegate.UserSettings.tempUnit
            {
            case CpuTempComponent.TempUnit.Celcius:
                ddTempUnit.selectItem(at: 0)
                break
            case CpuTempComponent.TempUnit.Fahrenheit:
                ddTempUnit.selectItem(at: 1)
                break
            }
        }
    }

    @IBAction func ddTempUnit_clicked(_: Any) {
        AppDelegate.UserSettings.tempUnit = ddTempUnit.indexOfSelectedItem == 0 ? CpuTempComponent.TempUnit.Celcius : CpuTempComponent.TempUnit.Fahrenheit
        UserDefaults.standard.set((ddTempUnit.indexOfSelectedItem == 0) ? 0 : 1, forKey: "tempUnit")
    }

    // define the outlet and the action of the color well to choose a color
    @IBOutlet var cpCPU: NSColorWell! {
        didSet {
            cpCPU.color = AppDelegate.UserSettings.cpuColor
        }
    }

    @IBAction func cpCPU_clicked(_ sender: NSColorWell) {
        AppDelegate.UserSettings.cpuColor = sender.color
        sender.color.usingColorSpace(NSColorSpace.genericRGB)?.getRed(&colRedCPU, green: &colGreenCPU, blue: &colBlueCPU, alpha: &colAlphaCPU)
        UserDefaults.standard.set(CGFloat(round(colRedCPU * 10000) / 10000), forKey: "colRedCPU")
        UserDefaults.standard.set(CGFloat(round(colGreenCPU * 10000) / 10000), forKey: "colGreenCPU")
        UserDefaults.standard.set(CGFloat(round(colBlueCPU * 10000) / 10000), forKey: "colBlueCPU")
        UserDefaults.standard.set(CGFloat(round(colAlphaCPU * 10000) / 10000), forKey: "colAlphaCPU")
    }

    // define the outlet and the action of the checkbox to enable and disable the border of the cpu icon
    @IBOutlet var cbCPUBorder: NSButton! {
        didSet {
            cbCPUBorder.state = AppDelegate.UserSettings.userWantsCPUBorder ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbCPUBorder_clicked(_: NSButton) {
        AppDelegate.UserSettings.userWantsCPUBorder = (cbCPUBorder.state == NSButton.StateValue.on)
        UserDefaults.standard.set((cbCPUBorder.state == NSButton.StateValue.on), forKey: "userWantsCPUBorder")
    }
    
    // define the outlet and the action of the pop up button for choosing how to visualize the cpu usage
    @IBOutlet weak var popUpCPUGraphType: NSPopUpButton! {
        didSet {
            switch AppDelegate.UserSettings.cpuUsageVisualization {
                case CpuUsageComponent.VisualizationType.Bar:
                    popUpCPUGraphType.selectItem(at: 0)
                    break
                case CpuUsageComponent.VisualizationType.Graph:
                    popUpCPUGraphType.selectItem(at: 1)
                    break
            }
        }
    }
    
    @IBAction func popUpCPUGraphType(_ sender: Any) {
        AppDelegate.UserSettings.cpuUsageVisualization = popUpCPUGraphType.indexOfSelectedItem == 0 ? CpuUsageComponent.VisualizationType.Bar : CpuUsageComponent.VisualizationType.Graph
        // adjust the length of the status item according to the visualization type
        CpuUsageComponent.sItemCpuUtil.length = popUpCPUGraphType.indexOfSelectedItem == 0 ? 27 : 53
        UserDefaults.standard.set((popUpCPUGraphType.indexOfSelectedItem == 0) ? 0 : 1, forKey: "cpuUsageVisualization")
    }
    
}
