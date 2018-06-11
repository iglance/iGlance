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
        
        case CPUUtil
        case CPUTemp
        case MemUtil
        case Bandwidth
        case FanSpeed
        case INVALID
    }
    
    // Default settings
    public static var StatusItemPos = [StatusItems.INVALID, StatusItems.INVALID, StatusItems.INVALID, StatusItems.INVALID, StatusItems.INVALID] as [StatusItems]
    public static var validToIndex = 0
    
    
    public static func insertItem(item: StatusItems)
    {
        if (validToIndex >= (StatusItemPos.count - 1))
        {
            return
        }
        else
        {
            for i in stride(from: validToIndex, to: -1, by: -1)
            {
                StatusItemPos[i+1] = StatusItemPos[i]
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
            for i in at...(StatusItemPos.count - 2)
            {
                StatusItemPos[i] = StatusItemPos[i+1]
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
        for i in 0...StatusItemPos.count - 1
        {
            let strKey = "posArray" + String(i)
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
                    item = StatusItems.CPUUtil
                    break
                case 2:
                    item = StatusItems.CPUTemp
                    break
                case 3:
                    item = StatusItems.MemUtil
                    break
                case 4:
                    item = StatusItems.Bandwidth
                    break
                case 5:
                    item = StatusItems.FanSpeed
                    break
                case 6:
                    item = StatusItems.INVALID
                default:
                    return
                }
                StatusItemPos[i] = item
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
        for i in 0...StatusItemPos.count - 1
        {
            var idx: Int?
            switch(StatusItemPos[i])
            {
            case StatusItems.CPUUtil:
                idx = 1
                break
            case StatusItems.CPUTemp:
                idx = 2
                break
            case StatusItems.MemUtil:
                idx = 3
                break
            case StatusItems.Bandwidth:
                idx = 4
                break
            case StatusItems.FanSpeed:
                idx = 5
                break
            case StatusItems.INVALID:
                idx = 6
                break
            default:
                idx = 0
            }
            let strKey = "posArray" + String(i)
            UserDefaults.standard.set(idx, forKey: strKey)
        }
        printNow()
    }
    
    private static func printNow()
    {
        for i in 0...StatusItemPos.count - 1
        {
            print(StatusItemPos[i])
        }
        print(validToIndex)
        print("---------")
    }
    
    
}
