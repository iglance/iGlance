//
//  AppDelegate.swift
//  iGlance
//
//  Created by Cemal on 01.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

enum InterfaceStyle : String {
    case Dark, Light
    
    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        self = InterfaceStyle(rawValue: type)!
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let sItemFanSpeed = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnFanSpeed: NSStatusBarButton?
    
    let sItemBandwidth = NSStatusBar.system.statusItem(withLength: 60.0)
    var btnBandwidth: NSStatusBarButton?
    
    let sItemMemUsage = NSStatusBar.system.statusItem(withLength: 25.0)
    var btnMemUsage: NSStatusBarButton?
    
    let sItemCPUUtil = NSStatusBar.system.statusItem(withLength: 25.0)
    var btnCPUUtil: NSStatusBarButton?
    
    let sItemCPUTemp = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var btnCPUTemp: NSStatusBarButton?
    
    var mySystem: System?
    var myCPUView: CPUUsageView?
    var myMemView: MemUsageView?
    var myBandwidthView: BandwidthView?
    
    var finalDown: Int64?
    var finalUp: Int64?
    var finalDownLast: Int64?
    var finalUpLast: Int64?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initCPUUtil()
        initCPUTemp()
        initMemUsage()
        initFanSpeed()
        initBandwidth()
        
        updateBandwidth()
        
        do
        {
            try SMCKit.open()
        }
        catch
        {
        
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
        
        /*
        DispatchQueue.global(qos: .background).async {
            while (true)
            {
                self.updateCPUUsage()
                sleep(1)
            }
        }
    */
    }

    func initCPUUtil()
    {
        btnCPUUtil = sItemCPUUtil.button
        myCPUView = CPUUsageView()
        myCPUView?.frame = (btnCPUUtil?.frame)!
        btnCPUUtil?.addSubview(myCPUView!)
        /*
        let str = Bundle.main.executableURL!.absoluteString
        let components = str.split(separator: "/")
        let head = "/" + components.dropLast(1).dropFirst(1).map(String.init).joined(separator: "/") + "/cpu_mem_util"
        print(head)
        */
        
        mySystem = System()
        
    }
    
    @objc func updateCPUUsage()
    {
        let cpuStats = self.mySystem!.usageCPU()
        let cpuUser = Double(round(100*cpuStats.user)/100)
        let cpuSystem = Double(round(100*cpuStats.system)/100)
        let cpuIdle = Double(round(100*cpuStats.idle)/100)
        let cpuNice = Double(round(100*cpuStats.nice)/100)
        let cpuUsageTotal = cpuUser + cpuSystem
        self.myCPUView?.setPercent(percent: cpuUsageTotal)
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
        print(System.physicalMemory())
        let memUtil = Double(memTaken / System.physicalMemory()) * 100
        self.myMemView?.setPercent(percent: memUtil)
    }
    
    @objc func updateAll()
    {
        updateCPUTemp()
        updateCPUUsage()
        updateMemUsage()
        updateFanSpeed()
        reallyUpdateBandwidth()
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
        if (finalDown != finalDownLast)
        {
            needUpdate = true
        }
        
        if (finalUp != finalUpLast)
        {
            needUpdate = true
        }
        
        if (needUpdate)!
        {
            myBandwidthView?.updateBandwidth(down: finalDown!, up: finalUp!)
            finalUpLast = finalUp
            finalDownLast = finalDown
        }
    }
    
    @objc func updateBandwidth()
    {
        let command = runAsync("netstat","-w1 -l en0").onCompletion { command in
            print("fin")
        }
        var curr: Array<Substring>?
        
        curr = [""]
        var str1: String?
        var str2: String?
        
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
                    print(curr ?? "")
                    str1 = "Download: " + curr![2]
                    str2 = "Upload: " + curr![5]
                    print(str1 ?? "")
                    print(str2 ?? "")
                    //self.myBandwidthView?.updateBandwidth(down: Int64(curr![2])!, up: Int64(curr![5])!)
                    self.finalDown = Int64(curr![2])
                    self.finalUp = Int64(curr![5])
                }
                print("-------")
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
            print("---------")
        }
    }
    
    @objc func updateCPUTemp() {
        
        let core0 = TemperatureSensor(name: "CPU_0_DIE", code: FourCharCode(fromStaticString: "TC0F"))

        guard let temperature = try? SMCKit.temperature(core0.code) else {
            btnCPUTemp?.title = "NA"
            return
        }
        btnCPUTemp?.title = String(Int(temperature)) + "°"
        }
    
    func initMemUsage()
    {
        btnMemUsage = sItemMemUsage.button
        myMemView = MemUsageView()
        myMemView?.frame = (btnMemUsage?.frame)!
        btnMemUsage?.addSubview(myMemView!)
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
    }
    
    func initCPUTemp()
    {
        btnCPUTemp = sItemCPUTemp.button
        btnCPUTemp?.title = "53°"
    }
    
    func initFanSpeed()
    {
        btnFanSpeed = sItemFanSpeed.button
        btnFanSpeed?.title = "1330"
    }
    
    func initBandwidth()
    {
        btnBandwidth = sItemBandwidth.button
        //btnBandwidth?.image = NSImage(named:NSImage.Name("menubar-label-network"))
        myBandwidthView = BandwidthView()
        myBandwidthView?.frame = (btnBandwidth?.frame)!
        btnBandwidth?.addSubview(myBandwidthView!)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

