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
    @IBOutlet weak var cpCPU: NSColorWell! {
        didSet {
            cpCPU.color = AppDelegate.UserSettings.cpuColor
        }
    }
    @IBOutlet weak var cbAutostart: NSButton! {
        didSet {
            cbAutostart.state = (AppDelegate.UserSettings.userWantsAutostart) ? NSButton.StateValue.on : NSButton.StateValue.off
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
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidDisappear()
    {
        super.viewDidDisappear()
        print("ohhhh")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func cbCPUTemp_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsCPUTemp = (cbCPUTemp.state == NSButton.StateValue.on)
    }
    
    @IBAction func cbCPUUtil_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsCPUUtil = (cbCPUUtil.state == NSButton.StateValue.on)
    }
    @IBAction func cpCPU_clicked(_ sender: NSColorWell) {
        AppDelegate.UserSettings.cpuColor = sender.color
    }
    @IBAction func ddTempUnit_clicked(_ sender: Any) {
        AppDelegate.UserSettings.tempUnit = ddTempUnit.indexOfSelectedItem == 0 ? AppDelegate.TempUnit.Celcius : AppDelegate.TempUnit.Fahrenheit
    }
    
    @IBAction func cbAutostart_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsAutostart = (cbAutostart.state == NSButton.StateValue.on)
        if (cbAutostart.state == NSButton.StateValue.on) {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, true) {
                print("The login item was not successfull")
            }
            else {
                UserDefaults.standard.set("true", forKey: "appLoginStart")
                print("autostart true")
            }
        }
        else {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, false) {
                print("The login item was not successfull")
            }
            else {
                UserDefaults.standard.set("false", forKey: "appLoginStart")
                print("autostart false")
            }
        }
    }
    @IBAction func ddUpdateInterval_clicked(_ sender: NSPopUpButton) {
        switch (ddUpdateInterval.indexOfSelectedItem)
            
        {
        case 0:
            AppDelegate.UserSettings.updateInterval = 1.0
            break
        case 1:
            AppDelegate.UserSettings.updateInterval = 2.0
            break
        case 2:
            AppDelegate.UserSettings.updateInterval = 3.0
            break
        default:
            AppDelegate.UserSettings.updateInterval = 2.0
        }
    }
    @IBAction func btnCheckUpdate_clicked(_ sender: NSButton) {
        /*
        let scriptUrl = "https://raw.githubusercontent.com/Moneypulation/iGlance/master/Version.txt"
        // Create NSURL Ibject
        let myUrl = NSURL(string: scriptUrl);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        // Set request HTTP method to GET. It could be POST as well
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(String(describing: error))")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString ?? "NA")")
            //AppDelegate.dialogOK(question: "hi",text: responseString! as String)
        }
        task.resume()
 */
        var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/Moneypulation/iGlance/master/Version.txt")!)
        //var htmltext = ""
        //request.httpBody = body
        request.httpMethod = "GET"
        let (htmltext, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            // print("Synchronous task ended with error: \(error)")
            let alert = NSAlert()
            alert.messageText = ""
            alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        else {
            // print("Synchronous task ended without errors.")
            // html = String(data: htmltext!, encoding: String.Encoding.utf8)!
            
            let pat = "\\[version\\](.*)\\[\\/version\\]"
            let res = matches(for: pat, in: String(data: htmltext!, encoding: String.Encoding.utf8)!)
            print(res)
            if res.count != 1
            {
                let alert = NSAlert()
                alert.messageText = ""
                alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            }
            else
            {
                let onlyversion = res[0].replacingOccurrences(of: "[version]", with: "").replacingOccurrences(of: "[/version]", with: "")
                print(onlyversion)
                if (onlyversion != AppDelegate.VERSION)
                {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "A new version (" + onlyversion + ") is available. Please visit: \n\n https://github.com/Moneypulation/iGlance"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                else
                {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "Running latest version (" + onlyversion + ")"
                    alert.alertStyle = .informational
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
        AppDelegate.UserSettings.userWantsMemUsage = (cbMemUtil.state == NSButton.StateValue.on)
    }
    
    @IBAction func cpMem_clicked(_ sender: NSColorWell) {
        AppDelegate.UserSettings.memColor = sender.color
    }
    
    @IBAction func cbNetUsage_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsBandwidth = (cbNetUsage.state == NSButton.StateValue.on)
    }
    
    @IBAction func cbFanSpeed_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsFanSpeed = (cbFanSpeed.state == NSButton.StateValue.on)
    }
    @IBAction func cbCPUBorder_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsCPUBorder = (cbCPUBorder.state == NSButton.StateValue.on)
    }
    @IBAction func cbMemBorder_clicked(_ sender: NSButton) {
        AppDelegate.UserSettings.userWantsMemBorder = (cbMemBorder.state == NSButton.StateValue.on)
    }
    //MARK: Actions
}

