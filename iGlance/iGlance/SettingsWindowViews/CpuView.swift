//
//  CpuTempView.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

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
                case AppDelegate.VisualizationType.Bar:
                    popUpCPUGraphType.selectItem(at: 0)
                    break
                case AppDelegate.VisualizationType.Graph:
                    popUpCPUGraphType.selectItem(at: 1)
                    // if the graph was selected make the width textfield visible
                    cpuGraphwidth.isHidden = popUpCPUGraphType.indexOfSelectedItem == 0;
                    graphPixelLabel.isHidden = cpuGraphwidth.isHidden
                    graphWidthLabel.isHidden = cpuGraphwidth.isHidden
                    break
            }
        }
    }
    @IBAction func popUpCPUGraphType(_ sender: Any) {
        AppDelegate.UserSettings.cpuUsageVisualization = popUpCPUGraphType.indexOfSelectedItem == 0 ? AppDelegate.VisualizationType.Bar : AppDelegate.VisualizationType.Graph
        // adjust the length of the status item according to the visualization type
        CpuUsageComponent.sItemCpuUtil.length = popUpCPUGraphType.indexOfSelectedItem == 0 ? 27 : CGFloat(AppDelegate.UserSettings.cpuGraphWidth)
        UserDefaults.standard.set((popUpCPUGraphType.indexOfSelectedItem == 0) ? 0 : 1, forKey: "cpuUsageVisualization")
        
        // if the graph was selected make the width textfield visible
        cpuGraphwidth.isHidden = popUpCPUGraphType.indexOfSelectedItem == 0
        graphPixelLabel.isHidden = cpuGraphwidth.isHidden
        graphWidthLabel.isHidden = cpuGraphwidth.isHidden
    }
    
    // outlets and actions of the labels and textfield to define the width of the menu bar graph
    @IBOutlet weak var cpuGraphwidth: NSTextField! {
        didSet {
            // subtract 3 pixel because of the border of the graph
            cpuGraphwidth.intValue = Int32(CpuUsageComponent.sItemCpuUtil.length)
            UserDefaults.standard.set(cpuGraphwidth.intValue, forKey: "cpuGraphWidth")
        }
    }
    @IBAction func cpuGraphwidth(_ sender: Any) {
        // if the graph option is not selected just return and do nothing
        if popUpCPUGraphType.indexOfSelectedItem == 0 {
            return
        }
        
        // set the length of the status item. We have to add 3 pixel because of the border of the graph and the label
        if cpuGraphwidth.stringValue.isNumber
        {
            CpuUsageComponent.sItemCpuUtil.length = CGFloat(cpuGraphwidth.intValue)
            // save it to the user settings
            UserDefaults.standard.set(cpuGraphwidth.intValue, forKey: "cpuGraphWidth")
        }
        else
        {
            // reset if it is not a positive number
            cpuGraphwidth.intValue = Int32(UserDefaults.standard.value(forKey: "cpuGraphWidth") as! Int)
        }
    }
    @IBOutlet weak var graphPixelLabel: NSTextField!
    @IBOutlet weak var graphWidthLabel: NSTextField!
}
