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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(printTemperatureInformation), userInfo: nil, repeats: true)
        
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
    
    @objc func printTemperatureInformation(known: Bool = true) {
        print("-- Temperature --")
        
        let sensors: [TemperatureSensor]
        do {
            if known {
                sensors = try SMCKit.allKnownTemperatureSensors().sorted
                    { $0.name < $1.name }
            } else {
                sensors = try SMCKit.allUnknownTemperatureSensors()
            }
            
        } catch {
            print(error)
            return
        }
        
        
        let sensorWithLongestName = sensors.max { $0.name.count <
            $1.name.count }
        
        guard let longestSensorNameCount = sensorWithLongestName?.name.count else {
            print("No temperature sensors found")
            return
        }
        
        
        for sensor in sensors {
            let padding = String(repeating: " ",
                                 count: longestSensorNameCount - sensor.name.count)
            
            let smcKey  = "(\(sensor.code.toString()))"
            print("\(sensor.name + padding)   \(smcKey)  ", terminator: "")
            
            
            guard let temperature = try? SMCKit.temperature(sensor.code) else {
                print("NA")
                return
            }
            
            //let warning = warningLevel(value: temperature, maxValue: maxTemperatureCelsius)
            //let level   = "(\(warning.name))"
            //let color   = warning.color
            
            //print("\(color.rawValue)\(temperature)°C \(level)" +
            //  "\(ANSIColor.Off.rawValue)")
            print("\(temperature)°C")
        }
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
        let myBWView = BandwidthView()
        myBWView.frame = (btnBandwidth?.frame)!
        btnBandwidth?.addSubview(myBWView)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

