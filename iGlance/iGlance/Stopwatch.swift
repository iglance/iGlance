//
//  Stopwatch.swift
//  iGlance
//
//  Created by Cemal on 03.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class Stopwatch: NSObject {
    
    private static var watches = [String:TimeInterval]()
    
    private static func intervalFromMachTime(time: TimeInterval, useNanos: Bool) -> TimeInterval {
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else { return -1 }
        let currentTime = mach_absolute_time()
        let nanos = currentTime * UInt64(info.numer) / UInt64(info.denom)
        if useNanos {
            return (TimeInterval(nanos) - time)
        }
        else {
            return (TimeInterval(nanos) - time) / TimeInterval(NSEC_PER_MSEC)
        }
    }
    
    static func start(name: String) {
        var info = mach_timebase_info()
        guard mach_timebase_info(&info) == KERN_SUCCESS else { return }
        let currentTime = mach_absolute_time()
        let nanos = currentTime * UInt64(info.numer) / UInt64(info.denom)
        watches[name] = TimeInterval(nanos)
    }
    
    static func timeElapsed(name: String) -> TimeInterval {
        return timeElapsed(name: name, useNanos: false)
    }
    
    private static func timeElapsed(name: String, useNanos: Bool) -> TimeInterval {
        if let start = watches[name] {
            //let unit = useNanos ? "nanos" : "ms"
            return intervalFromMachTime(time: start, useNanos: useNanos)
            //print("*** \(name) elapsed \(unit): \(intervalFromMachTime(time: start, useNanos: useNanos))")
        }
        return 0.0;
    }
}
