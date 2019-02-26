//
//  AppDelegate.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa
import ServiceManagement

enum InterfaceStyle: String {
    case Dark, Light

    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        self = InterfaceStyle(rawValue: type)!
    }
}

extension NSColor {
    func rgb() -> (red: Int, green: Int, blue: Int, alpha: Int)? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        let iRed = Int(fRed * 255.0)
        let iGreen = Int(fGreen * 255.0)
        let iBlue = Int(fBlue * 255.0)
        let iAlpha = Int(fAlpha * 255.0)
        return (red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public static var VERSION = "1.3.1"

    var myWindowController: MyMainWindow?
    
    public enum VisualizationType {
        case Graph
        case Bar
    }

    struct UserSettings {
        static var userWantsFanSpeed = false
        static var userWantsUnitFanSpeed = false
        static var userWantsBandwidth = false
        static var userWantsMemUsage = false
        static var userWantsCPUUtil = false
        static var userWantsCPUTemp = false
        static var userWantsAutostart = false
        static var cpuColor = NSColor.red
        static var cpuUsageVisualization = VisualizationType.Bar
        static var cpuGraphWidth = 27
        static var memColor = NSColor.green
        static var memUsageVisualization = VisualizationType.Bar
        static var memGraphWidth = 27
        static var updateInterval = 1.0
        static var tempUnit = CpuTempComponent.TempUnit.Celcius
        static var userWantsCPUBorder = true
        static var userWantsMemBorder = true
        static var userWantsBatteryUtil = true
        static var userWantsBatteryNotification = true
        static var lowerBatteryNotificationValue = 20
        static var upperBatteryNotificationValue = 80
    }

    /**
     *  Instantiate the components
     */
    /// The battery instance.
    static let myBattery = BatteryComponent()
    /// The fan instance
    static let myFan = FanComponent()
    /// The cpu temperatur instance
    static let myCpuTemp = CpuTempComponent()
    /// The cpu usage instance
    static let myCpuUsage = CpuUsageComponent()
    /// The memory usage instance
    static let myMemUsage = MemUsageComponent()
    /// The bandwith instance
    static let myNetUsage = NetUsageComponent()

    var intervalTimer: Timer?
    static var currTimeInterval = AppDelegate.UserSettings.updateInterval

    func applicationDidFinishLaunching(_: Notification) {
        checkForUpdate()
        
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(self, selector: #selector(AppDelegate.wakeUpListener), name: NSWorkspace.didWakeNotification, object: nil)

        CpuTempComponent.sItemCPUTemp.isVisible = false
        CpuUsageComponent.sItemCpuUtil.isVisible = false
        MemUsageComponent.sItemMemUsage.isVisible = false
        NetUsageComponent.sItemBandwidth.isVisible = false
        FanComponent.sItemFanSpeed.isVisible = false
        BatteryComponent.sItemBattery.isVisible = false

        loadSessionSettings()

        myWindowController = (NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "abcd") as! MyMainWindow)

        displayStatusItems()

        var startedAtLogin = false
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == NCConstants.launcherApplicationIdentifier {
                startedAtLogin = true
            }
        }

        // If the app's started, post to the notification center to kill the launcher app
        if startedAtLogin {
            DistributedNotificationCenter.default().postNotificationName(NCConstants.KILLME, object: Bundle.main.bundleIdentifier, userInfo: nil, options: DistributedNotificationCenter.Options.deliverImmediately)
        }

        do {
            try SMCKit.open()
        } catch {
            _ = AppDelegate.dialogOK(question: "Fatal Error", text: "Couldn't open SMCKit")
            NSApp.terminate(nil)
        }

        // initialize the components
        AppDelegate.myCpuUsage.initialize()
        AppDelegate.myCpuTemp.initialize()
        AppDelegate.myMemUsage.initialize()
        AppDelegate.myNetUsage.initialize()
        AppDelegate.myFan.initialize()
        AppDelegate.myBattery.initialize()

        intervalTimer = Timer.scheduledTimer(timeInterval: UserSettings.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
        RunLoop.current.add(intervalTimer!, forMode: RunLoop.Mode.common)
    }

    func checkForUpdate() {
        var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/iglance/iGlance/master/Version.txt")!)
        request.httpMethod = "GET"
        let (htmltext, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            // Do nothing
            NSLog("Error: ", error.localizedDescription)
        } else {
            let pat = "\\[version\\](.*)\\[\\/version\\]"
            let res = matches(for: pat, in: String(data: htmltext!, encoding: String.Encoding.utf8)!)
            if res.count != 1 {
                // Do nothing again
            } else {
                let onlyversion = res[0].replacingOccurrences(of: "[version]", with: "").replacingOccurrences(of: "[/version]", with: "")
                if onlyversion != AppDelegate.VERSION {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "A new version (" + onlyversion + ") is available at: \n\n https://github.com/iglance/iGlance"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Visit Website")
                    alert.addButton(withTitle: "OK")
                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: "https://github.com/iglance/iGlance"), NSWorkspace.shared.open(url) {}
                    }
                }
            }
        }
    }
    
    @objc func wakeUpListener(note: NSNotification)
    {
        checkForUpdate()
    }

    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch {
            NSLog("Error invalid regex: ", error.localizedDescription)
            return []
        }
    }

    func displayStatusItems() {
        var once = false

        MyStatusItems.initMembers()

        for i in stride(from: MyStatusItems.validToIndex, to: 0, by: -1) {
            switch MyStatusItems.StatusItemPos[i]
            {
            case MyStatusItems.StatusItems.cpuUtil:
                if AppDelegate.UserSettings.userWantsCPUUtil {
                    CpuUsageComponent.sItemCpuUtil.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.cpuTemp:
                if AppDelegate.UserSettings.userWantsCPUTemp {
                    CpuTempComponent.sItemCPUTemp.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.memUtil:
                if AppDelegate.UserSettings.userWantsMemUsage {
                    MemUsageComponent.sItemMemUsage.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.bandwidth:
                if AppDelegate.UserSettings.userWantsBandwidth {
                    NetUsageComponent.sItemBandwidth.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.fanSpeed:
                if AppDelegate.UserSettings.userWantsFanSpeed {
                    FanComponent.sItemFanSpeed.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.battery:
                if AppDelegate.UserSettings.userWantsBatteryUtil {
                    BatteryComponent.sItemBattery.isVisible = true
                    once = true
                }
            default:
                continue
            }
        }
        if once == false {
            // bring window to front, otherwise the user can't access it
            settings_clicked()
        }
    }

    func loadSessionSettings() {
        var colRedMem: CGFloat = 0
        var colGreenMem: CGFloat = 0
        var colBlueMem: CGFloat = 0
        var colAlphaMem: CGFloat = 0
        var colRedCPU: CGFloat = 0
        var colGreenCPU: CGFloat = 0
        var colBlueCPU: CGFloat = 0
        var colAlphaCPU: CGFloat = 0

        if UserDefaults.standard.value(forKey: "colRedMem") != nil {
            colRedMem = UserDefaults.standard.value(forKey: "colRedMem") as! CGFloat
            colGreenMem = UserDefaults.standard.value(forKey: "colGreenMem") as! CGFloat
            colBlueMem = UserDefaults.standard.value(forKey: "colBlueMem") as! CGFloat
            colAlphaMem = UserDefaults.standard.value(forKey: "colAlphaMem") as! CGFloat
            UserSettings.memColor = NSColor(calibratedRed: colRedMem, green: colGreenMem, blue: colBlueMem, alpha: colAlphaMem)
        }

        if UserDefaults.standard.value(forKey: "colRedCPU") != nil {
            colRedCPU = UserDefaults.standard.value(forKey: "colRedCPU") as! CGFloat
            colGreenCPU = UserDefaults.standard.value(forKey: "colGreenCPU") as! CGFloat
            colBlueCPU = UserDefaults.standard.value(forKey: "colBlueCPU") as! CGFloat
            colAlphaCPU = UserDefaults.standard.value(forKey: "colAlphaCPU") as! CGFloat
            UserSettings.cpuColor = NSColor(calibratedRed: colRedCPU, green: colGreenCPU, blue: colBlueCPU, alpha: colAlphaCPU)
        }

        if UserDefaults.standard.value(forKey: "userWantsCPUUtil") != nil {
            UserSettings.userWantsCPUUtil = UserDefaults.standard.value(forKey: "userWantsCPUUtil") as! Bool
        }
        if UserDefaults.standard.value(forKey: "cpuUsageVisualization") != nil {
            UserSettings.cpuUsageVisualization = (UserDefaults.standard.value(forKey: "cpuUsageVisualization") as! Int == 0) ? VisualizationType.Bar : VisualizationType.Graph
        }
        if UserDefaults.standard.value(forKey: "cpuGraphWidth") != nil {
            UserSettings.cpuGraphWidth = UserDefaults.standard.value(forKey: "cpuGraphWidth") as! Int
        }
        if UserDefaults.standard.value(forKey: "userWantsCPUTemp") != nil {
            UserSettings.userWantsCPUTemp = UserDefaults.standard.value(forKey: "userWantsCPUTemp") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsFanSpeed") != nil {
            UserSettings.userWantsFanSpeed = UserDefaults.standard.value(forKey: "userWantsFanSpeed") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsBandwidth") != nil {
            UserSettings.userWantsBandwidth = UserDefaults.standard.value(forKey: "userWantsBandwidth") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsMemUsage") != nil {
            UserSettings.userWantsMemUsage = UserDefaults.standard.value(forKey: "userWantsMemUsage") as! Bool
        }
        if UserDefaults.standard.value(forKey: "memUsageVisualization") != nil {
             UserSettings.memUsageVisualization = (UserDefaults.standard.value(forKey: "memUsageVisualization") as! Int == 0) ? VisualizationType.Bar : VisualizationType.Graph
        }
        if UserDefaults.standard.value(forKey: "memGraphWidth") != nil {
            UserSettings.memGraphWidth = UserDefaults.standard.value(forKey: "memGraphWidth") as! Int
        }
        if UserDefaults.standard.value(forKey: "userWantsAutostart") != nil {
            UserSettings.userWantsAutostart = UserDefaults.standard.value(forKey: "userWantsAutostart") as! Bool
        }
        if UserDefaults.standard.value(forKey: "updateInterval") != nil {
            UserSettings.updateInterval = UserDefaults.standard.value(forKey: "updateInterval") as! Double
        }
        if UserDefaults.standard.value(forKey: "tempUnit") != nil {
            // 0 = Celsius
            // 1 = Fahrenheit
            UserSettings.tempUnit = (UserDefaults.standard.value(forKey: "tempUnit") as! Int == 0) ? CpuTempComponent.TempUnit.Celcius : CpuTempComponent.TempUnit.Fahrenheit
        }
        if UserDefaults.standard.value(forKey: "userWantsCPUBorder") != nil {
            UserSettings.userWantsCPUBorder = UserDefaults.standard.value(forKey: "userWantsCPUBorder") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsMemBorder") != nil {
            UserSettings.userWantsMemBorder = UserDefaults.standard.value(forKey: "userWantsMemBorder") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsBatteryUtil") != nil {
            UserSettings.userWantsBatteryUtil = UserDefaults.standard.value(forKey: "userWantsBatteryUtil") as! Bool
        }
        if UserDefaults.standard.value(forKey: "userWantsBatteryNotification") != nil {
            UserSettings.userWantsBatteryNotification = UserDefaults.standard.value(forKey: "userWantsBatteryNotification") as! Bool
        }
        if UserDefaults.standard.value(forKey: "lowerBatteryNotificationValue") != nil {
            UserSettings.lowerBatteryNotificationValue = UserDefaults.standard.value(forKey: "lowerBatteryNotificationValue") as! Int
        }
        if UserDefaults.standard.value(forKey: "upperBatteryNotificationValue") != nil {
            UserSettings.upperBatteryNotificationValue = UserDefaults.standard.value(forKey: "upperBatteryNotificationValue") as! Int
        }
    }

    static func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }

    @objc func settings_clicked() {
        myWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func updateAll() {
        if AppDelegate.UserSettings.userWantsCPUTemp {
            CpuTempComponent.sItemCPUTemp.isVisible = true
            AppDelegate.myCpuTemp.updateCPUTemp()
        } else {
            CpuTempComponent.sItemCPUTemp.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsCPUUtil {
            CpuUsageComponent.sItemCpuUtil.isVisible = true
            AppDelegate.myCpuUsage.updateCPUUsage()
        } else {
            CpuUsageComponent.sItemCpuUtil.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsMemUsage {
            MemUsageComponent.sItemMemUsage.isVisible = true
            AppDelegate.myMemUsage.updateMemUsage()
        } else {
            MemUsageComponent.sItemMemUsage.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsFanSpeed {
            FanComponent.sItemFanSpeed.isVisible = true
            do {
                try AppDelegate.myFan.updateFanSpeed()
            } catch {
                NSLog("Error: ", error.localizedDescription)
            }
        } else {
            FanComponent.sItemFanSpeed.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsBandwidth {
            NetUsageComponent.sItemBandwidth.isVisible = true
            AppDelegate.myNetUsage.updateNetUsage()
        } else {
            NetUsageComponent.sItemBandwidth.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsBatteryUtil {
            BatteryComponent.sItemBattery.isVisible = true
            AppDelegate.myBattery.updateBatteryItem()
        } else {
            BatteryComponent.sItemBattery.isVisible = false
        }
        if AppDelegate.UserSettings.userWantsBatteryNotification {
            // notify the user if needed
            AppDelegate.myBattery.notifyUser()
        }
        if AppDelegate.changeInterval() {
            intervalTimer?.invalidate()
            intervalTimer = Timer.scheduledTimer(timeInterval: UserSettings.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            AppDelegate.currTimeInterval = AppDelegate.UserSettings.updateInterval
            RunLoop.current.add(intervalTimer!, forMode: RunLoop.Mode.common)
        }
    }

    static func changeInterval() -> Bool {
        if AppDelegate.currTimeInterval != AppDelegate.UserSettings.updateInterval {
            return true
        } else {
            return false
        }
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}

class NCConstants { // Notify constant
    static let KILLME = Notification.Name("killme")
    static let launcherApplicationIdentifier = "noorganization.iGlanceLauncher"
}
