//
//  AppDelegate.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa
import ServiceManagement

enum InterfaceStyle : String {
    case Dark, Light
    
    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        self = InterfaceStyle(rawValue: type)!
    }
}

extension NSColor {
    
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        let iRed = Int(fRed * 255.0)
        let iGreen = Int(fGreen * 255.0)
        let iBlue = Int(fBlue * 255.0)
        let iAlpha = Int(fAlpha * 255.0)
        return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    public static var VERSION = "1.0"
    /**
    * StatusBarItems, Buttons and Menus declaration
    */
    static let sItemFanSpeed = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnFanSpeed: NSStatusBarButton?
    var menuFanSpeed: NSMenu?
    
    static let sItemBandwidth = NSStatusBar.system.statusItem(withLength: 62.0)
    var btnBandwidth: NSStatusBarButton?
    var menuBandwidth: NSMenu?
    
    static let sItemMemUsage = NSStatusBar.system.statusItem(withLength: 27.0)
    let myMemMenuView = MemMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 110))
    let niceitem2 = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var btnMemUsage: NSStatusBarButton?
    var menuMemUsage: NSMenu?
    
    static let sItemCPUUtil = NSStatusBar.system.statusItem(withLength: 27.0)
    let myCPUMenuView = CPUMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 90))
    let niceitem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var btnCPUUtil: NSStatusBarButton?
    var menuCPUUtil: NSMenu?
    
    static let sItemCPUTemp = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnCPUTemp: NSStatusBarButton?
    var menuCPUTemp: NSMenu?
    
    static let sItemBattery = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnBattery: NSStatusBarButton?
    var menuBattery: NSMenu?
    
    //var command: AsyncCommand?
    
    var myWindowController: MyMainWindow?
    
    public enum TempUnit {
        case Celcius
        case Fahrenheit
    }
    
    struct UserSettings
    {
        static var userWantsFanSpeed = false
        static var userWantsBandwidth = false
        static var userWantsMemUsage = false
        static var userWantsCPUUtil = false
        static var userWantsCPUTemp = false
        static var userWantsAutostart = false
        static var cpuColor = NSColor.red
        static var memColor = NSColor.green
        static var updateInterval = 1.0
        static var tempUnit = TempUnit.Celcius
        static var userWantsCPUBorder = true
        static var userWantsMemBorder = true
        static var userWantsBatteryUtil = true
        static var userWantsBatteryNotification = true
        static var lowerBatteryNotificationValue = 20
        static var upperBatteryNotificationValue = 80
    }
    
    
    // Todo: Delete
    
    var mySystem: System?
    var myBattery: Battery?
    /*
    var myCPUView: CPUUsageView?
    var myMemView: MemUsageView?
    var myBandwidthView: BandwidthView?
    */
    
    /**
    * Bandwidth variables
    */
    var dSpeed: Int64?
    var uSpeed: Int64?
    var dSpeedLast: Int64?
    var uSpeedLast: Int64?
    
    var bandIMG: String?
    var bandColor: NSColor?
    var bandText: String?
    var finalDown: String?
    var finalUp: String?
    var pbFillRectBandwidth: NSRect?
    var len1: Int?
    var len2: Int?
    var firstBandwidth = true
    
    /**
    * CPU Button Image variables
    */
    var pbFillRectCPU: NSRect?
    var pixelHeightCPU: Double?
    var cpuIMG: String?
    
    /**
     * MEM Button Image variables
     */
    var pbFillRectMEM: NSRect?
    var pbMaxMEM: Double?
    var pixelHeightMEM: Double?
    var memIMG: String?
    
    /**
     *  Battery variables
     */
    var remainingTime: Battery.RemainingBatteryTime?
    var batteryCapacity: Double?
    
    /**
    * Shared variables
    */
    var pixelWidth: Double?
    var pbIMG: String?
    var pbMax: Double?
    
    //var myWindow: MyMainWindow?
    //var myWin: MyMainWin?
    
    //let popover = NSPopover()

    var intervalTimer: Timer?
    static var currTimeInterval = AppDelegate.UserSettings.updateInterval

    var bandwidthTask: Process?
    var curr: Array<Substring>?
    
    /*
     0: CPUUtil
     1: CPUTemp
     2: MemUtil
     3: Bandwidth
     4: FanSpeed
 
    enum StatusItems {
        case CPUUtil
        case CPUTemp
        case MemUtil
        case Bandwidth
        case FanSpeed
    }
 
    public static var StatusItemPos = [StatusItems.CPUTemp, StatusItems.CPUUtil, StatusItems.MemUtil, StatusItems.Bandwidth, StatusItems.FanSpeed]
    public static var validToIndex = 0
     */

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        AppDelegate.sItemCPUTemp.isVisible = false
        AppDelegate.sItemCPUUtil.isVisible = false
        AppDelegate.sItemFanSpeed.isVisible = false
        AppDelegate.sItemMemUsage.isVisible = false
        AppDelegate.sItemBandwidth.isVisible = false
        AppDelegate.sItemBattery.isVisible = false
        
        myWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "abcd")) as! MyMainWindow
        //UserDefaults.standard.set(4, forKey: "validToIndex")
        //NSApp.terminate(nil)
        
        
        /*
        UserDefaults.standard.set(false, forKey: "userWantsCPUUtil")
        UserDefaults.standard.set(false, forKey: "userWantsCPUTemp")
        UserDefaults.standard.set(false, forKey: "userWantsMemUsage")
        UserDefaults.standard.set(false, forKey: "userWantsBandwidth")
        UserDefaults.standard.set(false, forKey: "userWantsFanSpeed")
        UserDefaults.standard.set(6, forKey: "posArray0")
        UserDefaults.standard.set(6, forKey: "posArray1")
        UserDefaults.standard.set(6, forKey: "posArray2")
        UserDefaults.standard.set(6, forKey: "posArray3")
        UserDefaults.standard.set(6, forKey: "posArray4")
        UserDefaults.standard.set(0, forKey: "validToIndex")
        NSApp.terminate(nil)
        */
        
        loadSessionSettings()
        displayStatusItems()
        
        // Create a Task instance
        bandwidthTask = Process()
        
        // Set the task parameters
        bandwidthTask?.launchPath = "/usr/bin/env"
        bandwidthTask?.arguments = ["netstat", "-w1", "-l", "en0"]
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        bandwidthTask?.standardOutput = pipe
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        // When new data is available
        var dataAvailable : NSObjectProtocol!
        dataAvailable = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputHandle, queue: nil) {  notification -> Void in
                let data = pipe.fileHandleForReading.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        self.curr = [""]
                        self.curr = str.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").split(separator: " ")
                        if (self.curr == nil || (self.curr?.count)! < 6)
                        {
                            
                        }
                        else
                        {
                            if (Int64(self.curr![2]) == nil)
                            {
                                
                            }
                            else
                            {
                                self.dSpeed = Int64(self.curr![2])
                                self.uSpeed = Int64(self.curr![5])
                            }
                        }
                        
                    }
                    outputHandle.waitForDataInBackgroundAndNotify()
                } else {
                    NotificationCenter.default.removeObserver(dataAvailable)
                }
        }
        
        // When task has finished
        var dataReady : NSObjectProtocol!
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: pipe.fileHandleForReading, queue: nil) { notification -> Void in
                print("Task terminated!")
                NotificationCenter.default.removeObserver(dataReady)
            }
        
        // Launch the task
        bandwidthTask?.launch()
 

        // ------------ MISSING LOAD SESSION SETTINGS ------------------
        // -------------------------------------------------------------
        
        
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
        
        //myWindowController?.showWindow(self)
        //NSApp.activate(ignoringOtherApps: true)
        
        
        //popover.behavior = NSPopover.Behavior.transient;
        constructMenu()
        initCPUUtil()
        initCPUTemp()
        initMemUsage()
        initFanSpeed()
        initBandwidth()
        initBattery()
        
        
        do
        {
            try SMCKit.open()
        }
        catch
        {
            AppDelegate.dialogOK(question: "Fatal Error", text: "Couldn't open SMCKit")
            NSApp.terminate(nil)
        }
        
        intervalTimer = Timer.scheduledTimer(timeInterval: UserSettings.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
        RunLoop.current.add(intervalTimer!, forMode: RunLoopMode.commonModes)
    }
    
    /*
    func getPosArray()
    {
        for i in 0...AppDelegate.StatusItemPos.count - 1
        {
            let strKey = "posArray" + String(i)
            var item: AppDelegate.StatusItems
            if (UserDefaults.standard.integer(forKey: strKey) == 0)
            {
                break
            }
            else
            {
                switch(UserDefaults.standard.integer(forKey: strKey))
                {
                case 1:
                    item = AppDelegate.StatusItems.CPUUtil
                    break
                case 2:
                    item = AppDelegate.StatusItems.CPUTemp
                    break
                case 3:
                    item = AppDelegate.StatusItems.MemUtil
                    break
                case 4:
                    item = AppDelegate.StatusItems.Bandwidth
                    break
                case 5:
                    item = AppDelegate.StatusItems.FanSpeed
                    break
                default:
                    return
                }
                AppDelegate.StatusItemPos[i] = item
            }
        }
    }
    */
    
    func displayStatusItems()
    {
        var once = false
        
        MyStatusItems.initMembers()
        
        for i in stride(from: MyStatusItems.validToIndex, to: 0, by: -1)
        {
            switch (MyStatusItems.StatusItemPos[i])
            {
            case MyStatusItems.StatusItems.CPUUtil:
                if (AppDelegate.UserSettings.userWantsCPUUtil)
                {
                    AppDelegate.sItemCPUUtil.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.CPUTemp:
                if (AppDelegate.UserSettings.userWantsCPUTemp)
                {
                    AppDelegate.sItemCPUTemp.isVisible = true
                    once = true
                }
                break
            case MyStatusItems.StatusItems.MemUtil:
                if (AppDelegate.UserSettings.userWantsMemUsage)
                {
                    AppDelegate.sItemMemUsage.isVisible = true
                    print("2")
                    once = true
                }
                break
            case MyStatusItems.StatusItems.Bandwidth:
                if (AppDelegate.UserSettings.userWantsBandwidth)
                {
                    AppDelegate.sItemBandwidth.isVisible = true
                    print("3")
                    once = true
                }
                break
            case MyStatusItems.StatusItems.FanSpeed:
                if (AppDelegate.UserSettings.userWantsFanSpeed)
                {
                    AppDelegate.sItemFanSpeed.isVisible = true
                    print("4")
                    once = true
                }
                break
            case MyStatusItems.StatusItems.Battery:
                if(AppDelegate.UserSettings.userWantsBatteryUtil) {
                    AppDelegate.sItemBattery.isVisible = true
                    once = true
                }
            default:
                continue
            }
        }
        if (once == false)
        {
            // bring window to front, otherwise the user can't access it
            print("lol")
            settings_clicked()
        }
    }
    
    func loadSessionSettings()
    {
        var colRedMem: CGFloat = 0
        var colGreenMem: CGFloat = 0
        var colBlueMem: CGFloat = 0
        var colAlphaMem: CGFloat = 0
        var colRedCPU: CGFloat = 0
        var colGreenCPU: CGFloat = 0
        var colBlueCPU: CGFloat = 0
        var colAlphaCPU: CGFloat = 0
        
        if (UserDefaults.standard.value(forKey: "colRedMem") != nil)
        {
            colRedMem = UserDefaults.standard.value(forKey: "colRedMem") as! CGFloat
            colGreenMem = UserDefaults.standard.value(forKey: "colGreenMem") as! CGFloat
            colBlueMem = UserDefaults.standard.value(forKey: "colBlueMem") as! CGFloat
            colAlphaMem = UserDefaults.standard.value(forKey: "colAlphaMem") as! CGFloat
            UserSettings.memColor = NSColor(calibratedRed: colRedMem, green: colGreenMem, blue: colBlueMem, alpha: colAlphaMem)
        }
        
        if (UserDefaults.standard.value(forKey: "colRedCPU") != nil)
        {
            colRedCPU = UserDefaults.standard.value(forKey: "colRedCPU") as! CGFloat
            colGreenCPU = UserDefaults.standard.value(forKey: "colGreenCPU") as! CGFloat
            colBlueCPU = UserDefaults.standard.value(forKey: "colBlueCPU") as! CGFloat
            colAlphaCPU = UserDefaults.standard.value(forKey: "colAlphaCPU") as! CGFloat
            UserSettings.cpuColor = NSColor(calibratedRed: colRedCPU, green: colGreenCPU, blue: colBlueCPU, alpha: colAlphaCPU)
        }
        
        if (UserDefaults.standard.value(forKey: "userWantsCPUUtil") != nil)
        {
            UserSettings.userWantsCPUUtil = UserDefaults.standard.value(forKey: "userWantsCPUUtil") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsCPUTemp") != nil)
        {
            UserSettings.userWantsCPUTemp = UserDefaults.standard.value(forKey: "userWantsCPUTemp") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsFanSpeed") != nil)
        {
            UserSettings.userWantsFanSpeed = UserDefaults.standard.value(forKey: "userWantsFanSpeed") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsBandwidth") != nil)
        {
            UserSettings.userWantsBandwidth = UserDefaults.standard.value(forKey: "userWantsBandwidth") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsMemUsage") != nil)
        {
            UserSettings.userWantsMemUsage = UserDefaults.standard.value(forKey: "userWantsMemUsage") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsAutostart") != nil)
        {
            UserSettings.userWantsAutostart = UserDefaults.standard.value(forKey: "userWantsAutostart") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "updateInterval") != nil)
        {
            UserSettings.updateInterval = UserDefaults.standard.value(forKey: "updateInterval") as! Double
        }
        if (UserDefaults.standard.value(forKey: "tempUnit") != nil)
        {
            // 0 = Celsius
            // 1 = Fahrenheit
            UserSettings.tempUnit = (UserDefaults.standard.value(forKey: "tempUnit") as! Int == 0) ? TempUnit.Celcius : TempUnit.Fahrenheit
        }
        if (UserDefaults.standard.value(forKey: "userWantsCPUBorder") != nil)
        {
            UserSettings.userWantsCPUBorder = UserDefaults.standard.value(forKey: "userWantsCPUBorder") as! Bool
        }
        if (UserDefaults.standard.value(forKey: "userWantsMemBorder") != nil)
        {
            UserSettings.userWantsMemBorder = UserDefaults.standard.value(forKey: "userWantsMemBorder") as! Bool
        }
        if(UserDefaults.standard.value(forKey: "userWantsBatteryUtil") != nil) {
            UserSettings.userWantsBatteryUtil = UserDefaults.standard.value(forKey: "userWantsBatteryUtil") as! Bool
        }
        if(UserDefaults.standard.value(forKey: "userWantsBatteryNotification") != nil) {
            UserSettings.userWantsBatteryNotification = UserDefaults.standard.value(forKey: "userWantsBatteryNotification") as! Bool
        }
        if(UserDefaults.standard.value(forKey: "lowerBatteryNotificationValue") != nil) {
            UserSettings.lowerBatteryNotificationValue = UserDefaults.standard.value(forKey: "lowerBatteryNotificationValue") as! Int
        }
        if(UserDefaults.standard.value(forKey: "upperBatteryNotificationValue") != nil) {
            UserSettings.upperBatteryNotificationValue = UserDefaults.standard.value(forKey: "upperBatteryNotificationValue") as! Int
        }
    }
    
    static func dialogOK(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        //alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    

    func initCPUUtil()
    {
        pbMax = 16.0 // 32*0.5
        pixelWidth = 7 // 14*0.5
        pixelHeightCPU = 0
        mySystem = System()
        myBattery = Battery()
        btnCPUUtil = AppDelegate.sItemCPUUtil.button
    }
    
    @objc func settings_clicked()
    {
        myWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func constructMenu() {
        
        niceitem.view = myCPUMenuView
        niceitem2.view = myMemMenuView
        
        menuCPUUtil = NSMenu()
        menuCPUUtil?.addItem(niceitem)
        menuCPUUtil?.addItem(NSMenuItem.separator())
        menuCPUUtil?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuCPUUtil?.addItem(NSMenuItem.separator())
        menuCPUUtil?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        //menuCPUUtil?.addItem(NSMenuItem.separator())
        AppDelegate.sItemCPUUtil.menu = menuCPUUtil
        
        menuFanSpeed = NSMenu()
        menuFanSpeed?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuFanSpeed?.addItem(NSMenuItem.separator())
        menuFanSpeed?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.sItemFanSpeed.menu = menuFanSpeed
        
        menuMemUsage = NSMenu()
        menuMemUsage?.addItem(niceitem2)
        menuMemUsage?.addItem(NSMenuItem.separator())
        menuMemUsage?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuMemUsage?.addItem(NSMenuItem.separator())
        menuMemUsage?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.sItemMemUsage.menu = menuMemUsage
        
        menuCPUTemp = NSMenu()
        menuCPUTemp?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuCPUTemp?.addItem(NSMenuItem.separator())
        menuCPUTemp?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.sItemCPUTemp.menu = menuCPUTemp
        
        menuBandwidth = NSMenu()
        menuBandwidth?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuBandwidth?.addItem(NSMenuItem.separator())
        menuBandwidth?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.sItemBandwidth.menu = menuBandwidth
        
        menuBattery = NSMenu()
        menuBattery?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuBattery?.addItem(NSMenuItem.separator())
        menuBattery?.addItem(NSMenuItem(title: "Quite iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.sItemBattery.menu = menuBattery
    }
    
    @objc func updateCPUUsage()
    {
        let cpuStats = self.mySystem!.usageCPU()
        let cpuUser = Double(round(100*cpuStats.user)/100)
        let cpuSystem = Double(round(100*cpuStats.system)/100)
        let cpuIdle = Double(round(100*cpuStats.idle)/100)
        let cpuNice = Double(round(100*cpuStats.nice)/100)
        let cpuUsageTotal = cpuUser + cpuSystem
        //self.myCPUView?.setPercent(percent: cpuUsageTotal)
        
        myCPUMenuView.percentSystem.stringValue = String(Int(cpuSystem)) + "%"
        myCPUMenuView.percentUser.stringValue = String(Int(cpuUser)) + "%"
        myCPUMenuView.percentIdle.stringValue = String(Int(cpuIdle)) + "%"
        //myCPUMenuView.percentNice.stringValue = String(cpuNice)
        //myCPUMenuView.setPercentNice(val: String(Int(cpuNice)) + "%")
        myCPUMenuView.percentNice.stringValue = String(Int(cpuNice)) + "%"
        //RunLoop.current.add(Timer(timeInterval: 1.0, repeats: true, block: { (timer) in print("")}), forMode: RunLoopMode.commonModes)
        
        
        pixelHeightCPU = Double((pbMax! / 100.0) * cpuUsageTotal)
        
        if (InterfaceStyle() == InterfaceStyle.Dark)
        {
            cpuIMG = "menubar-label-cpu-white"
            pbIMG = "progressbar-white"
            
        }
        else
        {
            cpuIMG = "menubar-label-cpu-black"
            pbIMG = "progressbar-black"
            
        }
        let imgFinal = NSImage(size: NSSize(width: 20, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named:NSImage.Name(cpuIMG!))
        img1?.draw(at: NSPoint(x: 1, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if (AppDelegate.UserSettings.userWantsCPUBorder)
        {
            let img2 = NSImage(named:NSImage.Name(pbIMG!))
            img2?.draw(at: NSPoint(x: 11, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        }
        pbFillRectCPU = NSRect(x: 12.0, y: 1.0, width: pixelWidth!, height: pixelHeightCPU!)
        AppDelegate.UserSettings.cpuColor.setFill()
        pbFillRectCPU?.fill()
        NSColor.clear.setFill()
        imgFinal.unlockFocus()
        
        btnCPUUtil?.image = imgFinal
    }
    
    @objc func updateMemUsage()
    {
        let memStats = System.memoryUsage()
        let memActive = Double(round(100*memStats.active)/100)
        let memCompressed = Double(round(100*memStats.compressed)/100)
        let memFree = Double(round(100*memStats.free)/100)
        let memInactive = Double(round(100*memStats.inactive)/100)
        let memWired = Double(round(100*memStats.wired)/100)
        
        myMemMenuView.percentActive.stringValue = String(memActive) + " GB"
        myMemMenuView.percentCompressed.stringValue = String(memCompressed) + " GB"
        myMemMenuView.percentFree.stringValue = String(memFree) + " GB"
        myMemMenuView.percentInactive.stringValue = String(memInactive) + " GB"
        myMemMenuView.percentWired.stringValue = String(memWired) + " GB"
        
        /*
        print("active")
        print(memActive)
        print("compressed")
        print(memCompressed)
        print("free")
        print(memFree)
        print("inactive")
        print(memInactive)
        print("wired")
        print(memWired)
        print("")
         */
        let memTaken = memActive + memCompressed + memWired
        //print(System.physicalMemory())
        let memUtil = Double(memTaken / System.physicalMemory()) * 100
        //self.myMemView?.setPercent(percent: memUtil)
        
        pixelHeightMEM = Double((pbMax! / 100.0) * memUtil)

        
        if (InterfaceStyle() == InterfaceStyle.Dark)
        {
            memIMG = "menubar-label-mem-white"
            pbIMG = "progressbar-white"
            
        }
        else
        {
            memIMG = "menubar-label-mem-black"
            pbIMG = "progressbar-black"
            
        }
        let imgFinal = NSImage(size: NSSize(width: 20, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named:NSImage.Name(memIMG!))
        img1?.draw(at: NSPoint(x: 1, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if (AppDelegate.UserSettings.userWantsMemBorder)
        {
            let img2 = NSImage(named:NSImage.Name(pbIMG!))
            img2?.draw(at: NSPoint(x: 11, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
        }
        pbFillRectCPU = NSRect(x: 12.0, y: 1.0, width: pixelWidth!, height: pixelHeightMEM!)
        AppDelegate.UserSettings.memColor.setFill()
        pbFillRectCPU?.fill()
        NSColor.clear.setFill()
        imgFinal.unlockFocus()
        
        btnMemUsage?.image = imgFinal
    }
    
    @objc func updateAll()
    {
        if (AppDelegate.UserSettings.userWantsCPUTemp)
        {
            AppDelegate.sItemCPUTemp.isVisible = true
            updateCPUTemp()
        }
        else
        {
            AppDelegate.sItemCPUTemp.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsCPUUtil)
        {
            AppDelegate.sItemCPUUtil.isVisible = true
            updateCPUUsage()
        }
        else
        {
            AppDelegate.sItemCPUUtil.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsMemUsage)
        {
            AppDelegate.sItemMemUsage.isVisible = true
            updateMemUsage()
        }
        else
        {
            AppDelegate.sItemMemUsage.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsFanSpeed)
        {
            AppDelegate.sItemFanSpeed.isVisible = true
            updateFanSpeed()
        }
        else
        {
            AppDelegate.sItemFanSpeed.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsBandwidth)
        {
            AppDelegate.sItemBandwidth.isVisible = true
            if (firstBandwidth)
            {
                //updateBandwidth()
                firstBandwidth = false
            }
            else
            {
                /*
                if (command?.isRunning)!
                {
                    //print(command?.suspend())
                }
                */
            }
            reallyUpdateBandwidth()
        }
        else
        {
            AppDelegate.sItemBandwidth.isVisible = false
        }
        if(AppDelegate.UserSettings.userWantsBatteryNotification) {
            let battery = myBattery!
            
            // update the current capacity and notify the user if needed
            battery.notifyUser()
            batteryCapacity = battery.getBatteryCapacity()
            
            // get the remaining time
            remainingTime = battery.getRemainingBatteryTime()
        }
        if (AppDelegate.changeInterval())
        {
            intervalTimer?.invalidate()
            print(UserSettings.updateInterval)
            intervalTimer = Timer.scheduledTimer(timeInterval: UserSettings.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            //RunLoop.current.add(intervalTimer!, forMode: RunLoopMode.commonModes)
            AppDelegate.currTimeInterval = AppDelegate.UserSettings.updateInterval
        }
    }
    
    static func changeInterval() -> Bool
    {
        if (AppDelegate.currTimeInterval != AppDelegate.UserSettings.updateInterval)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    @objc func updateFanSpeed()
    {
        let allFans: [Fan]
        do {
            allFans = try SMCKit.allFans()
        } catch {
            print(error)
            return
        }
        
        if allFans.count == 0
        {
            print("No fans found")
            return;
        }
        
        for fan in allFans {
            guard let currentSpeed = try? SMCKit.fanCurrentSpeed(fan.id) else {
                print("\tCurrent:  NA")
                return
            }
            let currentMinus50 = currentSpeed - fan.minSpeed - 50
            if (currentMinus50 < 0)
            {
                btnFanSpeed?.title = "0"
            }
            else
            {
                btnFanSpeed?.title = String(((currentMinus50+50) / 5)*5)
            }
            break;
            
        }
    }
    
    @objc func reallyUpdateBandwidth()
    {
        var needUpdate: Bool?
        needUpdate = false
        if (dSpeed != dSpeedLast)
        {
            needUpdate = true
        }
        
        if (uSpeed != uSpeedLast)
        {
            needUpdate = true
        }
        
        if (needUpdate)!
        {
            updateBandText(down: dSpeed!, up: uSpeed!)
            dSpeedLast = dSpeed
            uSpeedLast = uSpeed
        }
        
        if (InterfaceStyle() == InterfaceStyle.Dark)
        {
            bandIMG = "bandwidth-white"
            bandColor = NSColor.white
        }
        else
        {
            bandIMG = "bandwidth-black"
            bandColor = NSColor.black
        }
        
        let imgFinal = NSImage(size: NSSize(width: 60, height: 18))
        imgFinal.lockFocus()
        let img1 = NSImage(named:NSImage.Name(bandIMG!))
        
        img1?.draw(at: NSPoint(x: 2, y: 3), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0.00000001
        
        len1 = finalDown?.count
        len2 = finalUp?.count
        
        
        
        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 11.0)
        let fontSmall = NSFont(name: "Apple SD Gothic Neo Bold", size: 8.0)
        let attrString = NSMutableAttributedString(string: finalDown ?? "0 KB/s")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: font as Any, range:NSMakeRange(0, attrString.length - 4))
        attrString.addAttribute(.font, value: fontSmall as Any, range:NSMakeRange(attrString.length - 4, 4))
        attrString.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range:NSMakeRange(0, attrString.length))
        attrString.draw(at: NSPoint(x:16, y:6))
        
        let attrString2 = NSMutableAttributedString(string: finalUp ?? "0 KB/s")
        attrString2.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString2.length))
        attrString2.addAttribute(.font, value: font as Any, range:NSMakeRange(0, attrString2.length - 4))
        attrString2.addAttribute(.font, value: fontSmall as Any, range:NSMakeRange(attrString2.length - 4, 4))
        attrString2.addAttribute(.foregroundColor, value: bandColor ?? NSColor.white, range:NSMakeRange(0, attrString2.length))
        attrString2.draw(at: NSPoint(x:16, y:-4))
        imgFinal.unlockFocus()
        btnBandwidth?.image = imgFinal
    }
    
    func updateBandText(down: Int64, up: Int64)
    {
        if (down < 1024)
        {
            // B
            finalDown = "0 KB/s"
        }
        else if (down < 1048576)
        {
            // KB
            finalDown = String((Int(down / 1024) / 4) * 4) + " KB/s"
        }
        else
        {
            // MB
            finalDown = String(format: "%.1f", Double(down) / 1048576.0) + " MB/s"
        }
        
        if (up < 1024)
        {
            // B
            finalUp = "0 KB/s"
        }
        else if (up < 1048576)
        {
            // KB
            finalUp = String((Int(up / 1024) / 4) * 4) + " KB/s"
        }
        else
        {
            // MB
            finalUp = String(format: "%.1f", Double(down) / 1048576.0) + " MB/s"
        }
        bandText = finalDown! + "\n" + finalUp!
    }
    
    @objc func updateBandwidth()
    {
        return
        //print("UPDATE CALLED")
        //command = runAsync("netstat","-w1 -l en0").onCompletion { command in
        /*
        command = runAsync("netstat","-w1 -l en0&\nt=$!\nsleep 3\nkill $t").onCompletion { command in
            print("fin")
        }
        var curr: Array<Substring>?
        
        curr = [""]
        //var str1: String?
        //var str2: String?
        
        command?.stdout.onOutput { stdout in
            for line in (self.command?.stdout.lines())!
            {
                print("aha")
                curr = line.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").split(separator: " ")
                if (curr == nil || (curr?.count)! < 6)
                {
                    continue
                }
                if (Int64(curr![2]) == nil)
                {
                    continue
                }
                else
                {
                    self.dSpeed = Int64(curr![2])
                    self.uSpeed = Int64(curr![5])
                }
                //print("-------")
            }
            
        }
        */
        
    }
    
    @objc func updateCPUTemp() {
        
        let core0 = TemperatureSensor(name: "CPU_0_DIE", code: FourCharCode(fromStaticString: "TC0F"))

        guard let temperature = try? SMCKit.temperature(core0.code) else {
            btnCPUTemp?.title = "NA"
            return
        }
        if (AppDelegate.UserSettings.tempUnit == AppDelegate.TempUnit.Fahrenheit)
        {
            let temperatureF = (temperature * 1.8) + 32
            btnCPUTemp?.title = String(Int(temperatureF)) + "°F"
        }
        else
        {
            btnCPUTemp?.title = String(Int(temperature)) + "°C"
        }
        }
    
    func initMemUsage()
    {
        btnMemUsage = AppDelegate.sItemMemUsage.button
        pixelHeightMEM = 0
    }
    
    func initCPUTemp()
    {
        btnCPUTemp = AppDelegate.sItemCPUTemp.button
    }
    
    func initFanSpeed()
    {
        btnFanSpeed = AppDelegate.sItemFanSpeed.button
    }
    
    func initBandwidth()
    {
        btnBandwidth = AppDelegate.sItemBandwidth.button
        
        len1 = 6
        len2 = 6
        bandText = ""
    }
    
    func initBattery() {
        btnBattery = AppDelegate.sItemBattery.button
        btnBattery?.title = "Battery"
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class NCConstants { // Notify constant
    static let KILLME = Notification.Name("killme")
    static let launcherApplicationIdentifier = "noorganization.iGlanceLauncher"
    
}

