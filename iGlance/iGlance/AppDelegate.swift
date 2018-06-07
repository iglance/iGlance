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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    public static var VERSION = "1.0"
    /**
    * StatusBarItems, Buttons and Menus declaration
    */
    let sItemFanSpeed = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnFanSpeed: NSStatusBarButton?
    var menuFanSpeed: NSMenu?
    
    let sItemBandwidth = NSStatusBar.system.statusItem(withLength: 60.0)
    var btnBandwidth: NSStatusBarButton?
    var menuBandwidth: NSMenu?
    
    let sItemMemUsage = NSStatusBar.system.statusItem(withLength: 25.0)
    var btnMemUsage: NSStatusBarButton?
    var menuMemUsage: NSMenu?
    
    let sItemCPUUtil = NSStatusBar.system.statusItem(withLength: 25.0)
    let myCPUMenuView = CPUMenuView(frame: NSRect(x: 0, y: 0, width: 170, height: 90))
    let niceitem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    var btnCPUUtil: NSStatusBarButton?
    var menuCPUUtil: NSMenu?
    
    let sItemCPUTemp = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnCPUTemp: NSStatusBarButton?
    var menuCPUTemp: NSMenu?
    
    var myWindowController: MyMainWindow?
    
    public enum TempUnit {
        case Celcius
        case Fahrenheit
    }
    
    struct UserSettings
    {
        static var userWantsFanSpeed = true
        static var userWantsBandwidth = true
        static var userWantsMemUsage = true
        static var userWantsCPUUtil = true
        static var userWantsCPUTemp = true
        static var userWantsAutostart = true
        static var cpuColor = NSColor.blue
        static var memColor = NSColor.green
        static var updateInterval = 1.0
        static var tempUnit = TempUnit.Celcius
        static var userWantsCPUBorder = true
        static var userWantsMemBorder = true
    }
    
    
    // Todo: Delete
    
    var mySystem: System?
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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Replace with loadSessionSettings
        /*
        AppDelegate.UserSettings.userWantsCPUUtil = true
        AppDelegate.UserSettings.userWantsCPUTemp = true
        AppDelegate.UserSettings.userWantsFanSpeed = true
        AppDelegate.UserSettings.userWantsMemUsage = true
        AppDelegate.UserSettings.userWantsBandwidth = true
        AppDelegate.UserSettings.userWantsAutostart = true
        */
        
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
        
        
        myWindowController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "abcd")) as! MyMainWindow
        myWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        
        
        //popover.behavior = NSPopover.Behavior.transient;
        constructMenu()
        initCPUUtil()
        initCPUTemp()
        initMemUsage()
        initFanSpeed()
        initBandwidth()
        
        
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
        btnCPUUtil = sItemCPUUtil.button
        /*
 
        //myCPUView = CPUUsageView()
        //myCPUView?.giveContext(contextNew: self)
        //myCPUView?.frame = (AppDelegate.btnCPUUtil?.frame)!
        //popover.contentViewController = CPUUsageViewController.freshController()
        //AppDelegate.btnCPUUtil?.addSubview(myCPUView!)
        btnCPUUtil?.target = self
        sItemCPUUtil.target = self;
        //sItemCPUUtil.action = #selector(mouseDown(_:));
        //sItemCPUUtil.sendAction(on: NSEvent.EventTypeMask.leftMouseDown)
        
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
        let img4 = NSImage(size: NSSize(width: 20, height: 18))
        img4.lockFocus()
        let img1 = NSImage(named:NSImage.Name(cpuIMG!))
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        let img2 = NSImage(named:NSImage.Name(pbIMG!))
        img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        pbFillRectCPU = NSRect(x: 13.0, y: 4.0, width: pixelWidth!, height: pixelHeightCPU!)
        AppDelegate.UserSettings.cpuColor.setFill()
        pbFillRectCPU?.fill()
        NSColor.clear.setFill()
        img4.unlockFocus()
        
        //btnCPUUtil?.image = img4
        
        /*
        let str = Bundle.main.executableURL!.absoluteString
        let components = str.split(separator: "/")
        let head = "/" + components.dropLast(1).dropFirst(1).map(String.init).joined(separator: "/") + "/cpu_mem_util"
        print(head)
        */
 
    */
        
        
        
    }
    
    @objc func settings_clicked()
    {
        myWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func constructMenu() {
        menuCPUUtil = NSMenu()
        /*
        let niceattr = NSMutableAttributedString(string: "haharechts")
        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 11.0)
        let fontSmall = NSFont(name: "Apple SD Gothic Neo Bold", size: 8.0)
        niceattr.addAttribute(.font, value: font as Any, range: NSMakeRange(0,4))
        let myParagraphStyle2 = NSMutableParagraphStyle()
        myParagraphStyle2.alignment = .left
        niceattr.addAttribute(.paragraphStyle, value: myParagraphStyle2, range: NSMakeRange(0, 4))
        let myParagraphStyle = NSMutableParagraphStyle()
        myParagraphStyle.alignment = .right
        niceattr.addAttribute(.paragraphStyle, value: myParagraphStyle, range: NSMakeRange(4, 6))
        niceitem.attributedTitle = niceattr*/
        
        niceitem.view = myCPUMenuView
        
        
        menuCPUUtil?.addItem(niceitem)
        menuCPUUtil?.addItem(NSMenuItem.separator())
        menuCPUUtil?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuCPUUtil?.addItem(NSMenuItem.separator())
        menuCPUUtil?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        //menuCPUUtil?.addItem(NSMenuItem.separator())
        sItemCPUUtil.menu = menuCPUUtil
        
        menuFanSpeed = NSMenu()
        menuFanSpeed?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuFanSpeed?.addItem(NSMenuItem.separator())
        menuFanSpeed?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        sItemFanSpeed.menu = menuFanSpeed
        
        menuMemUsage = NSMenu()
        menuMemUsage?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuMemUsage?.addItem(NSMenuItem.separator())
        menuMemUsage?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        sItemMemUsage.menu = menuMemUsage
        
        menuCPUTemp = NSMenu()
        menuCPUTemp?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuCPUTemp?.addItem(NSMenuItem.separator())
        menuCPUTemp?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        sItemCPUTemp.menu = menuCPUTemp
        
        menuBandwidth = NSMenu()
        menuBandwidth?.addItem(NSMenuItem(title: "Settings", action: #selector(settings_clicked), keyEquivalent: "s"))
        menuBandwidth?.addItem(NSMenuItem.separator())
        menuBandwidth?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        sItemBandwidth.menu = menuBandwidth
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
        myCPUMenuView.setPercentNice(val: String(Int(cpuNice)) + "%")
        RunLoop.current.add(Timer(timeInterval: 1.0, repeats: true, block: { (timer) in print("Hi!")}), forMode: RunLoopMode.commonModes)
        
        
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
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if (AppDelegate.UserSettings.userWantsCPUBorder)
        {
            let img2 = NSImage(named:NSImage.Name(pbIMG!))
            img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        }
        pbFillRectCPU = NSRect(x: 11.0, y: 1.0, width: pixelWidth!, height: pixelHeightCPU!)
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
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        if (AppDelegate.UserSettings.userWantsMemBorder)
        {
            let img2 = NSImage(named:NSImage.Name(pbIMG!))
            img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
        }
        pbFillRectCPU = NSRect(x: 11.0, y: 1.0, width: pixelWidth!, height: pixelHeightMEM!)
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
            sItemCPUTemp.isVisible = true
            updateCPUTemp()
        }
        else
        {
            sItemCPUTemp.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsCPUUtil)
        {
            sItemCPUUtil.isVisible = true
            updateCPUUsage()
        }
        else
        {
            sItemCPUUtil.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsMemUsage)
        {
            sItemMemUsage.isVisible = true
            updateMemUsage()
        }
        else
        {
            sItemMemUsage.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsFanSpeed)
        {
            sItemFanSpeed.isVisible = true
            updateFanSpeed()
        }
        else
        {
            sItemFanSpeed.isVisible = false
        }
        if (AppDelegate.UserSettings.userWantsBandwidth)
        {
            sItemBandwidth.isVisible = true
            if (firstBandwidth)
            {
                updateBandwidth()
                firstBandwidth = false
            }
            reallyUpdateBandwidth()
        }
        else
        {
            sItemBandwidth.isVisible = false
        }
        if (AppDelegate.changeInterval())
        {
            intervalTimer?.invalidate()
            print(UserSettings.updateInterval)
            intervalTimer = Timer.scheduledTimer(timeInterval: UserSettings.updateInterval, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            RunLoop.current.add(intervalTimer!, forMode: RunLoopMode.commonModes)
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
        
        img1?.draw(at: NSPoint(x: 0, y: 3), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
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
        let command = runAsync("netstat","-w1 -l en0").onCompletion { command in
            print("fin")
        }
        var curr: Array<Substring>?
        
        curr = [""]
        //var str1: String?
        //var str2: String?
        
        command.stdout.onOutput { stdout in
            for line in command.stdout.lines()
            {
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
                    /*
                    print(curr ?? "")
                    str1 = "Download: " + curr![2]
                    str2 = "Upload: " + curr![5]
                    print(str1 ?? "")
                    print(str2 ?? "")
                    */
                    //self.myBandwidthView?.updateBandwidth(down: Int64(curr![2])!, up: Int64(curr![5])!)
                    self.dSpeed = Int64(curr![2])
                    self.uSpeed = Int64(curr![5])
                }
                //print("-------")
            }
            /*
            let str = command.stdout.readSome() ?? ""
            let trimmedString = str.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: "  ", with: " ").split(separator: " ")
            
            if (Int64(trimmedString[0]) != nil)
            {
                print(trimmedString)
                let str1 = "Download: " + trimmedString[2]
                let str2 = "Upload: " + trimmedString[5]
                print(str1)
                print(str2)
            }
             */
            //print("---------")
        }
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
        btnMemUsage = sItemMemUsage.button
        pixelHeightMEM = 0
        
        //myMemView = MemUsageView()
        //myMemView?.frame = (btnMemUsage?.frame)!
        //btnMemUsage?.addSubview(myMemView!)
        /*
        let img1 = NSImage(named:NSImage.Name("menubar-label-mem-white"))
        let img2 = NSImage(named:NSImage.Name("progressbar-white"))
        let img3 = NSImage(size: NSSize(width: 20, height: 18))
        img3.lockFocus()
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        img3.unlockFocus()
        btnMemUsage?.image = img3
         */
        
        
        /*
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
        img1?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        let img2 = NSImage(named:NSImage.Name(pbIMG!))
        img2?.draw(at: NSPoint(x: 10, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        pbFillRectCPU = NSRect(x: 11.0, y: 1.0, width: pixelWidth!, height: pixelHeightMEM!)
        AppDelegate.UserSettings.memColor.setFill()
        pbFillRectCPU?.fill()
        NSColor.clear.setFill()
        imgFinal.unlockFocus()
        
        //btnMemUsage?.image = imgFinal
        */
    }
    
    func initCPUTemp()
    {
        btnCPUTemp = sItemCPUTemp.button
    }
    
    func initFanSpeed()
    {
        btnFanSpeed = sItemFanSpeed.button
    }
    
    func initBandwidth()
    {
        btnBandwidth = sItemBandwidth.button
        //btnBandwidth?.image = NSImage(named:NSImage.Name("menubar-label-network"))
        //myBandwidthView = BandwidthView()
        //myBandwidthView?.frame = (btnBandwidth?.frame)!
        //btnBandwidth?.addSubview(myBandwidthView!)
        
        len1 = 6
        len2 = 6
        bandText = ""
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

class NCConstants { // Notify constant
    static let KILLME = Notification.Name("killme")
    static let launcherApplicationIdentifier = "noorganization.iGlanceLauncher"
    
}

