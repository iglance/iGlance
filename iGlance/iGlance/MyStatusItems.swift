//
//  MyStatusItems.swift
//  iGlance
//
//  Created by Cemal on 10.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class MyStatusItems: NSObject {

    enum StatusItems {
        case cpuUtil
        case cpuTemp
        case memUtil
        case bandwidth
        case fanSpeed
        case battery
        case INVALID
    }
    // Default settings
    public static var StatusItemPos = [StatusItems.INVALID, StatusItems.INVALID,
                                       StatusItems.INVALID, StatusItems.INVALID, StatusItems.INVALID] as [StatusItems]
    public static var validToIndex = 0
    public static func insertItem(item: StatusItems)
    {
        if (validToIndex >= (StatusItemPos.count - 1))
        {
            return
        }
        else
        {
            for index in stride(from: validToIndex, to: -1, by: -1)
            {
                StatusItemPos[index+1] = StatusItemPos[index]
            }
            StatusItemPos[0] = item
            validToIndex += 1
        }
        UserDefaults.standard.set(validToIndex, forKey: "validToIndex")
        savePosArray()
    }
    public static func removeItem(item: StatusItems)
    {
        if (StatusItemPos.index(of: item) == nil)
        {
            return
        }
        else
        {
            removeItemHelper(at: StatusItemPos.index(of: item)!)
            UserDefaults.standard.set(validToIndex, forKey: "validToIndex")
            savePosArray()
        }
    }
    private static func removeItemHelper(at: Int)
    {
        if (at > validToIndex)
        {
            return
        }
        else if (at == validToIndex)
        {
            StatusItemPos[at] = StatusItems.INVALID
            validToIndex -= 1
        }
        else
        {
            for index in at...(StatusItemPos.count - 2)
            {
                StatusItemPos[index] = StatusItemPos[index+1]
            }
            StatusItemPos[StatusItemPos.count - 1] = StatusItems.INVALID
            validToIndex -= 1
        }
    }
    
    public static func initMembers()
    {
        loadIndex()
        loadPosArray()
    }
    private static func loadIndex()
    {
        let idx = UserDefaults.standard.integer(forKey: "validToIndex")
        if (idx == 0)
        {
            validToIndex = -1
        }
        else if (idx == -1)
        {
            validToIndex = 0
        }
        else
        {
            validToIndex = idx
        }
    }
    private static func saveIndex()
    {
        if (validToIndex == 0)
        {
            UserDefaults.standard.set(-1, forKey: "validToIndex")
        }
        else if (validToIndex == -1)
        {
            UserDefaults.standard.set(0, forKey: "validToIndex")
        }
        else
        {
            UserDefaults.standard.set(validToIndex, forKey: "validToIndex")
        }
    }
    private static func loadPosArray()
    {
        for index in 0...StatusItemPos.count - 1
        {
            let strKey = "posArray" + String(index)
            var item: StatusItems
            if (UserDefaults.standard.integer(forKey: strKey) == 0)
            {
                break
            }
            else
            {
                switch(UserDefaults.standard.integer(forKey: strKey))
                {
                case 1:
                    item = StatusItems.cpuUtil
                    break
                case 2:
                    item = StatusItems.cpuTemp
                    break
                case 3:
                    item = StatusItems.memUtil
                    break
                case 4:
                    item = StatusItems.bandwidth
                    break
                case 5:
                    item = StatusItems.fanSpeed
                    break
                case 6:
                    item = StatusItems.battery
                    break
                case 7:
                    item = StatusItems.INVALID
                default:
                    return
                }
                StatusItemPos[index] = item
            }
        }
        printNow()
    }
    private static func savePosArray()
    {
        /*
         0: CPUUtil
         1: CPUTemp
         2: MemUtil
         3: Bandwidth
         4: FanSpeed
         5: INVALID
         
         Incremented every index on purpose by 1 because userdefault.standard.data(..) returns 0 if no value found
         */
        for index in 0...StatusItemPos.count - 1
        {
            var idx: Int?
            switch(StatusItemPos[index])
            {
            case StatusItems.cpuUtil:
                idx = 1
                break
            case StatusItems.cpuTemp:
                idx = 2
                break
            case StatusItems.memUtil:
                idx = 3
                break
            case StatusItems.bandwidth:
                idx = 4
                break
            case StatusItems.fanSpeed:
                idx = 5
                break
            case StatusItems.battery:
                idx = 6
                break
            case StatusItems.INVALID:
                idx = 7
                break
            default:
                idx = 0
            }
            let strKey = "posArray" + String(index)
            UserDefaults.standard.set(idx, forKey: strKey)
        }
        printNow()
    }
    private static func printNow()
    {
        for index in 0...StatusItemPos.count - 1
        {
            print(StatusItemPos[index])
        }
        print(validToIndex)
        print("---------")
    }
}
