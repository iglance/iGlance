//
//  ViewController.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa
import ServiceManagement

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

class ViewController: NSViewController {

    
    var colRedCPU: CGFloat = 0
    var colBlueCPU: CGFloat = 0
    var colGreenCPU: CGFloat = 0
    var colAlphaCPU: CGFloat = 0
    var colRedMem: CGFloat = 0
    var colBlueMem: CGFloat = 0
    var colGreenMem: CGFloat = 0
    var colAlphaMem: CGFloat = 0
    
    
    // checkbox items
    @IBOutlet weak var cbCPUUtil: NSButton! {
        didSet {
            cbCPUUtil.state = AppDelegate.UserSettings.userWantsCPUUtil ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbCPUTemp: NSButton! {
        didSet {
            cbCPUTemp.state = AppDelegate.UserSettings.userWantsCPUTemp ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbAutostart: NSButton! {
        didSet {
            cbAutostart.state = (AppDelegate.UserSettings.userWantsAutostart) ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    
    // the logo
    @IBOutlet weak var imgLogo: NSImageView! {
        didSet {
            imgLogo.image = NSImage(named:NSImage.Name("logo"))
        }
    }
    
    // drop down elements
    @IBOutlet weak var ddTempUnit: NSPopUpButton! {
        didSet {
            switch(AppDelegate.UserSettings.tempUnit)
            {
            case AppDelegate.TempUnit.Celcius:
                ddTempUnit.selectItem(at: 0)
                break;
            case AppDelegate.TempUnit.Fahrenheit:
                ddTempUnit.selectItem(at: 1)
                break;
            default:
                ddTempUnit.selectItem(at: 0)
            }
            
        }
    }
    
    // color selector
    @IBOutlet weak var cpCPU: NSColorWell! {
        didSet {
            cpCPU.color = AppDelegate.UserSettings.cpuColor
        }
    }
    
    @IBOutlet weak var ddUpdateInterval: NSPopUpButton! {
        didSet {
            switch (AppDelegate.UserSettings.updateInterval)
            {
            case 1.0:
                ddUpdateInterval.selectItem(at: 0)
                break;
            case 2.0:
                ddUpdateInterval.selectItem(at: 1)
                break;
            case 3.0:
                ddUpdateInterval.selectItem(at: 2)
                break;
            default:
                ddUpdateInterval.selectItem(at: 1)
            }
            
        }
    }
    @IBOutlet weak var btnCheckUpdate: NSButton!
    @IBOutlet weak var cbMemUtil: NSButton! {
        didSet {
            cbMemUtil.state = AppDelegate.UserSettings.userWantsMemUsage ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cpMemUtil: NSColorWell! {
        didSet {
            cpMemUtil.color = AppDelegate.UserSettings.memColor
            AppDelegate.UserSettings.memColor.getRed(&colRedMem, green: &colGreenMem, blue: &colBlueMem, alpha: &colAlphaMem)
        }
    }
    @IBOutlet weak var cbNetUsage: NSButton! {
        didSet {
            cbNetUsage.state = AppDelegate.UserSettings.userWantsBandwidth ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbFanSpeed: NSButton! {
        didSet {
            cbFanSpeed.state = AppDelegate.UserSettings.userWantsFanSpeed ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbCPUBorder: NSButton! {
        didSet {
            cbCPUBorder.state = AppDelegate.UserSettings.userWantsCPUBorder ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbMemBorder: NSButton! {
        didSet {
            cbMemBorder.state = AppDelegate.UserSettings.userWantsMemBorder ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbBatteryUtil: NSButton! {
        didSet {
            cbBatteryUtil.state = AppDelegate.UserSettings.userWantsBatteryUtil ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var cbBatteryNotification: NSButton! {
        didSet {
            cbBatteryNotification.state = AppDelegate.UserSettings.userWantsBatteryNotification ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet weak var tfLowerBatteryValue: NSTextField! {
        didSet {
            tfLowerBatteryValue.intValue = Int32(AppDelegate.UserSettings.lowerBatteryNotificationValue)
        }
    }
    @IBOutlet weak var tfUpperBatteryValue: NSTextField! {
        didSet {
            tfUpperBatteryValue.intValue = Int32(AppDelegate.UserSettings.upperBatteryNotificationValue)
        }
    }
    // MARK: Properties
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func cbBatteryUtil_clicked(_ sender: NSButton) {
        let checked = (cbBatteryUtil.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBatteryUtil = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBatteryUtil")
        AppDelegate.sItemBattery.isVisible = checked
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.battery) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.battery)
    }
    @IBAction func cbBatterNotification_clicked(_ sender: NSButton) {
        let checked = (cbBatteryNotification.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBatteryNotification = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBatteryNotification")
    }
    @IBAction func tfLowerBatteryValue_changed(_ sender: NSTextField) {
        let value: Int = Int(tfLowerBatteryValue.intValue)
        AppDelegate.UserSettings.lowerBatteryNotificationValue = value
        UserDefaults.standard.set(value, forKey: "lowerBatteryNotificationValue")
    }
    @IBAction func tfUpperBatteryValue_changed(_ sender: NSTextField) {
        let value: Int = Int(tfUpperBatteryValue.intValue)
        AppDelegate.UserSettings.upperBatteryNotificationValue = value
        UserDefaults.standard.set(value, forKey: "upperBatteryNotificationValue")
    }
    @IBAction func cbCPUTemp_clicked(_ sender: NSButton) {
        let checked = (cbCPUTemp.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsCPUTemp = checked
        AppDelegate.sItemCPUTemp.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsCPUTemp")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.cpuTemp) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.cpuTemp)
    }
    
    @IBAction func cbCPUUtil_clicked(_ sender: NSButton) {
        let checked = (cbCPUUtil.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsCPUUtil = checked
        AppDelegate.sItemCPUUtil.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsCPUUtil")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.cpuUtil) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.cpuUtil)
    }
    @IBAction func cpCPU_clicked(_ sender: NSColorWell) {
        AppDelegate.UserSettings.cpuColor = sender.color
        sender.color.usingColorSpace(NSColorSpace.genericRGB)?.getRed(&colRedCPU, green: &colGreenCPU, blue: &colBlueCPU, alpha: &colAlphaCPU)
        UserDefaults.standard.set(CGFloat(round(colRedCPU * 10000)/10000), forKey: "colRedCPU")
        UserDefaults.standard.set(CGFloat(round(colGreenCPU * 10000)/10000), forKey: "colGreenCPU")
        UserDefaults.standard.set(CGFloat(round(colBlueCPU * 10000)/10000), forKey: "colBlueCPU")
        UserDefaults.standard.set(CGFloat(round(colAlphaCPU * 10000)/10000), forKey: "colAlphaCPU")
    }
    @IBAction func ddTempUnit_clicked(_ sender: Any) {
        AppDelegate.UserSettings.tempUnit = ddTempUnit.indexOfSelectedItem == 0 ? AppDelegate.TempUnit.Celcius : AppDelegate.TempUnit.Fahrenheit
        UserDefaults.standard.set((ddTempUnit.indexOfSelectedItem == 0) ? 0 : 1, forKey: "tempUnit")
    }
    
    @IBAction func cbAutostart_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsAutostart = (cbAutostart.state == NSButton.StateValue.on)
        if (cbAutostart.state == NSButton.StateValue.on) {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, true) {
                AppDelegate.dialogOK(question: "Error", text: "Something went wrong, sorry")
                cbAutostart.state = NSButton.StateValue.off
            }
            else {
                UserDefaults.standard.set(true, forKey: "userWantsAutostart")
            }
        }
        else {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, false) {
                AppDelegate.dialogOK(question: "Error", text: "Something went wrong, sorry")
            }
            else {
                UserDefaults.standard.set(false, forKey: "userWantsAutostart")
            }
        }
    }
    @IBAction func ddUpdateInterval_clicked(_ sender: NSPopUpButton) {
        switch (ddUpdateInterval.indexOfSelectedItem)
            
        {
        case 0:
            AppDelegate.UserSettings.updateInterval = 1.0
            UserDefaults.standard.set(1.0, forKey: "updateInterval")
            break
        case 1:
            AppDelegate.UserSettings.updateInterval = 2.0
            UserDefaults.standard.set(2.0, forKey: "updateInterval")
            break
        case 2:
            AppDelegate.UserSettings.updateInterval = 3.0
            UserDefaults.standard.set(3.0, forKey: "updateInterval")
            break
        default:
            AppDelegate.UserSettings.updateInterval = 2.0
        }
    }
    @IBAction func btnCheckUpdate_clicked(_ sender: NSButton) {
        var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/Moneypulation/iGlance/master/Version.txt")!)
        request.httpMethod = "GET"
        let (htmltext, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance\n\n\(error)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        else
        {
            let pat = "\\[version\\](.*)\\[\\/version\\]"
            let res = matches(for: pat, in: String(data: htmltext!, encoding: String.Encoding.utf8)!)
            if res.count != 1
            {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance\n\nError: Version.txt incompatible"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            else
            {
                let onlyversion = res[0].replacingOccurrences(of: "[version]", with: "").replacingOccurrences(of: "[/version]", with: "")
                if (onlyversion != AppDelegate.VERSION)
                {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "A new version (" + onlyversion + ") is available at: \n\n https://github.com/Moneypulation/iGlance"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Visit Website")
                    alert.addButton(withTitle: "OK")
                    if (alert.runModal() == .alertFirstButtonReturn)
                    {
                        if let url = URL(string: "https://github.com/Moneypulation/iGlance"), NSWorkspace.shared.open(url) {
                            
                        }
                    }
                }
                else
                {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "Running latest version (" + onlyversion + ")"
                    alert.alertStyle = .informational
                    let btnvisit = NSButtonCell(textCell: "Visit website")
                    btnvisit.bezelStyle = .rounded
                    btnvisit.isHighlighted = true
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    @IBAction func cbMemUtil_clicked(_ sender: NSButton) {
        let checked = (cbMemUtil.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsMemUsage = checked
        AppDelegate.sItemMemUsage.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsMemUsage")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.memUtil) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.memUtil)
    }
    
    @IBAction func cpMem_clicked(_ sender: NSColorWell) {
        AppDelegate.UserSettings.memColor = sender.color
        sender.color.usingColorSpace(NSColorSpace.genericRGB)?.getRed(&colRedMem, green: &colGreenMem, blue: &colBlueMem, alpha: &colAlphaMem)
        UserDefaults.standard.set(CGFloat(round(colRedMem * 10000)/10000), forKey: "colRedMem")
        UserDefaults.standard.set(CGFloat(round(colGreenMem * 10000)/10000), forKey: "colGreenMem")
        UserDefaults.standard.set(CGFloat(round(colBlueMem * 10000)/10000), forKey: "colBlueMem")
        UserDefaults.standard.set(CGFloat(round(colAlphaMem * 10000)/10000), forKey: "colAlphaMem")
    }
    
    @IBAction func cbNetUsage_clicked(_ sender: NSButton) {
        let checked = (cbNetUsage.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBandwidth = checked
        AppDelegate.sItemBandwidth.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBandwidth")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.bandwidth) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.bandwidth)
    }
    
    @IBAction func cbFanSpeed_clicked(_ sender: NSButton) {
        let checked = (cbFanSpeed.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsFanSpeed = checked
        AppDelegate.sItemFanSpeed.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsFanSpeed")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.fanSpeed) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.fanSpeed)
    }
    @IBAction func cbCPUBorder_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsCPUBorder = (cbCPUBorder.state == NSButton.StateValue.on)
        UserDefaults.standard.set((cbCPUBorder.state == NSButton.StateValue.on), forKey: "userWantsCPUBorder")
    }
    @IBAction func cbMemBorder_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsMemBorder = (cbMemBorder.state == NSButton.StateValue.on)
        UserDefaults.standard.set((cbMemBorder.state == NSButton.StateValue.on), forKey: "userWantsMemBorder")
    }
    //MARK: Actions
}
