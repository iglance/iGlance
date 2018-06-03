//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014, 2015  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Darwin
import IOKit.pwr_mgt
import Foundation

//------------------------------------------------------------------------------
// MARK: PRIVATE PROPERTIES
//------------------------------------------------------------------------------


// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_basic_info_data_t) / sizeof(integer_t))
private let HOST_LOAD_INFO_COUNT          : mach_msg_type_number_t =
                       UInt32(sizeof(host_load_info_data_t) / sizeof(integer_t))
private let HOST_CPU_LOAD_INFO_COUNT      : mach_msg_type_number_t =
                   UInt32(sizeof(host_cpu_load_info_data_t) / sizeof(integer_t))
private let HOST_VM_INFO64_COUNT          : mach_msg_type_number_t =
                      UInt32(sizeof(vm_statistics64_data_t) / sizeof(integer_t))
private let HOST_SCHED_INFO_COUNT         : mach_msg_type_number_t =
                      UInt32(sizeof(host_sched_info_data_t) / sizeof(integer_t))
private let PROCESSOR_SET_LOAD_INFO_COUNT : mach_msg_type_number_t =
              UInt32(sizeof(processor_set_load_info_data_t) / sizeof(natural_t))


public struct System {
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC PROPERTIES
    //--------------------------------------------------------------------------
    
    
    /**
    System page size.
    
    - Can check this via pagesize shell command as well
    - C lib function getpagesize()
    - host_page_size()
    
    TODO: This should be static right?
    */
    public static let PAGE_SIZE = vm_kernel_page_size
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC ENUMS
    //--------------------------------------------------------------------------
    
    
    /**
    Unit options for method data returns.
    
    TODO: Pages?
    */
    public enum Unit : Double {
        // For going from byte to -
        case Byte     = 1
        case Kilobyte = 1024
        case Megabyte = 1048576
        case Gigabyte = 1073741824
    }
    
    
    /// Options for loadAverage()
    public enum LOAD_AVG {
        /// 5, 30, 60 second samples
        case SHORT
        
        /// 1, 5, 15 minute samples
        case LONG
    }
    
    
    /// For thermalLevel()
    public enum ThermalLevel: String {
        // Comments via <IOKit/pwr_mgt/IOPM.h>

        /// Under normal operating conditions
        case Normal = "Normal"
        /// Thermal pressure may cause system slowdown
        case Danger = "Danger"
        /// Thermal conditions may cause imminent shutdown
        case Crisis = "Crisis"
        /// Thermal warning level has not been published
        case NotPublished = "Not Published"
        /// The platform may define additional thermal levels if necessary
        case Unknown = "Unknown"
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------
    

    private static let machHost = mach_host_self()
    private var loadPrevious = host_cpu_load_info()
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------
    
    
    public init() { }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------
    
    
    /**
    Get CPU usage (system, user, idle, nice). Determined by the delta between
    the current and last call. Thus, first call will always be inaccurate.
    */
    public mutating func usageCPU() -> (system : Double,
                                        user   : Double,
                                        idle   : Double,
                                        nice   : Double) {
        let load = System.hostCPULoadInfo()
        
        let userDiff = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sysDiff  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idleDiff = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let niceDiff = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        loadPrevious = load
        
        // TODO: 2 decimal places
        // TODO: Check that total is 100%
        return (sys, user, idle, nice)
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: PUBLIC STATIC METHODS
    //--------------------------------------------------------------------------
    
    
    /// Get the model name of this machine. Same as "sysctl hw.model"
    public static func modelName() -> String {
        let name: String
        var mib  = [CTL_HW, HW_MODEL]

        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = sizeof(io_name_t)

        var ptr    = UnsafeMutablePointer<io_name_t>.alloc(1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)


        if result == 0 { name = String.fromCString(UnsafePointer(ptr))! }
        else           { name = String() }


        ptr.dealloc(1)

        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
                        + "\(result)")
            }
        #endif

        return name
    }


    /**
    sysname       Name of the operating system implementation.
    nodename      Network name of this machine.
    release       Release level of the operating system.
    version       Version level of the operating system.
    machine       Machine hardware platform.

    Via uname(3) manual page.
    */
    public static func uname() -> (sysname: String, nodename: String,
                                                     release: String,
                                                     version: String,
                                                     machine: String) {
        // Takes a generic pointer type because the type were dealing with
        // (from the utsname struct) is a huge tuple of Int8s (once bridged to
        // Swift), so it would be really messy to go that route (would have to
        // type it all out explicitly)
        func toString<T>(ptr: UnsafePointer<T>) -> String {
            return String.fromCString(UnsafePointer<CChar>(ptr))!
        }

        let tuple: (String, String, String, String, String)
        var names  = utsname()
        let result = Foundation.uname(&names)

        #if DEBUG
            if result != 0 {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
                        + "\(result)")
            }
        #endif

        if result == 0 {
            let sysname  = withUnsafePointer(&names.sysname,  toString)
            let nodename = withUnsafePointer(&names.nodename, toString)
            let release  = withUnsafePointer(&names.release,  toString)
            let version  = withUnsafePointer(&names.version,  toString)
            let machine  = withUnsafePointer(&names.machine,  toString)

            tuple = (sysname, nodename, release, version, machine)
        }
        else {
            tuple = ("", "", "", "", "")
        }

        return tuple
    }


    /// Number of physical cores on this machine.
    public static func physicalCores() -> Int {
        return Int(System.hostBasicInfo().physical_cpu)
    }
    
    
    /**
    Number of logical cores on this machine. Will be equal to physicalCores()
    unless it has hyper-threading, in which case it will be double.
    
    https://en.wikipedia.org/wiki/Hyper-threading
    */
    public static func logicalCores() -> Int {
        return Int(System.hostBasicInfo().logical_cpu)
    }
    
    
    /**
    System load average at 3 intervals.
    
    "Measures the average number of threads in the run queue."
    
    - via hostinfo manual page
    
    https://en.wikipedia.org/wiki/Load_(computing)
    */
    public static func loadAverage(type: LOAD_AVG = .LONG) -> [Double] {
        var avg = [Double](count: 3, repeatedValue: 0)
        
        switch type {
            case .SHORT:
                let result = System.hostLoadInfo().avenrun
                avg = [Double(result.0) / Double(LOAD_SCALE),
                       Double(result.1) / Double(LOAD_SCALE),
                       Double(result.2) / Double(LOAD_SCALE)]
            case .LONG:
                getloadavg(&avg, 3)
        }
        
        return avg
    }
    
    
    /**
    System mach factor at 3 intervals.
    
    "A variant of the load average which measures the processing resources
    available to a new thread. Mach factor is based on the number of CPUs
    divided by (1 + the number of runnablethreads) or the number of CPUs minus
    the number of runnable threads when the number of runnable threads is less
    than the number of CPUs. The closer the Mach factor value is to zero, the
    higher the load. On an idle system with a fixed number of active processors,
    the mach factor will be equal to the number of CPUs."
    
    - via hostinfo manual page
    */
    public static func machFactor() -> [Double] {
        let result = System.hostLoadInfo().mach_factor
        
        return [Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE)]
    }
    

    /// Total number of processes & threads
    public static func processCounts() -> (processCount: Int, threadCount: Int) {
        let data = System.processorLoadInfo()
        return (Int(data.task_count), Int(data.thread_count))
    }
    
    
    /// Size of physical memory on this machine
    public static func physicalMemory(unit: Unit = .Gigabyte) -> Double {
        return Double(System.hostBasicInfo().max_mem) / unit.rawValue
    }
    
    
    /**
    System memory usage (free, active, inactive, wired, compressed).
    */
    public static func memoryUsage() -> (free       : Double,
                                         active     : Double,
                                         inactive   : Double,
                                         wired      : Double,
                                         compressed : Double) {
        let stats = System.VMStatistics64()
        
        let free     = Double(stats.free_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let active   = Double(stats.active_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        let wired    = Double(stats.wire_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        
        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE)
                                                        / Unit.Gigabyte.rawValue
        
        return (free, active, inactive, wired, compressed)
    }
    

    /// How long has the system been up?
    public static func uptime() -> (days: Int, hrs: Int, mins: Int, secs: Int) {
        var currentTime = time_t()
        var bootTime    = timeval()
        var mib         = [CTL_KERN, KERN_BOOTTIME]

        // NOTE: Use strideof(), NOT sizeof() to account for data structure
        // alignment (padding)
        // http://stackoverflow.com/a/27640066
        // https://devforums.apple.com/message/1086617#1086617
        var size = strideof(timeval)

        let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - errno = "
                        + "\(result)")
            #endif

            return (0, 0, 0, 0)
        }


        // Since we don't need anything more than second level accuracy, we use
        // time() rather than say gettimeofday(), or something else. uptime
        // command does the same
        time(&currentTime)

        var uptime = currentTime - bootTime.tv_sec

        let days = uptime / 86400   // Number of seconds in a day
        uptime %= 86400

        let hrs = uptime / 3600     // Number of seconds in a hour
        uptime %= 3600

        let mins = uptime / 60
        let secs = uptime % 60

        return (days, hrs, mins, secs)
    }


    //--------------------------------------------------------------------------
    // MARK: POWER
    //--------------------------------------------------------------------------


    /**
    As seen via 'pmset -g therm' command.

    Via <IOKit/pwr_mgt/IOPMLib.h>:

        processorSpeed: Defines the speed & voltage limits placed on the CPU.
                        Represented as a percentage (0-100) of maximum CPU
                        speed.

        processorCount: Reflects how many, if any, CPUs have been taken offline.
                        Represented as an integer number of CPUs (0 - Max CPUs).

                        NOTE: This doesn't sound quite correct, as pmset treats
                              it as the number of CPUs available, NOT taken
                              offline. The return value suggests the same.

        schedulerTime:  Represents the percentage (0-100) of CPU time available.
                        100% at normal operation. The OS may limit this time for
                        a percentage less than 100%.
    */
    public static func CPUPowerLimit() -> (processorSpeed: Double,
                                           processorCount: Int,
                                           schedulerTime : Double) {
        var processorSpeed = -1.0
        var processorCount = -1
        var schedulerTime  = -1.0

        var status = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.alloc(1)

        let result = IOPMCopyCPUPowerStatus(status)

        #if DEBUG
            // TODO: kIOReturnNotFound case as seen in pmset
            if result != kIOReturnSuccess {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        if result == kIOReturnSuccess,
           let data = status.move()?.takeRetainedValue() as? NSDictionary {
                // TODO: Force unwrapping here should be safe, as
                //       IOPMCopyCPUPowerStatus() defines the keys, but the
                //       the cast (from AnyObject) could be problematic
                processorSpeed = data[kIOPMCPUPowerLimitProcessorSpeedKey]!
                                                                      as! Double
                processorCount = data[kIOPMCPUPowerLimitProcessorCountKey]!
                                                                      as! Int
                schedulerTime  = data[kIOPMCPUPowerLimitSchedulerTimeKey]!
                                                                      as! Double
        }

        status.dealloc(1)

        return (processorSpeed, processorCount, schedulerTime)
    }


    /// Get the thermal level of the system. As seen via 'pmset -g therm'
    public static func thermalLevel() -> System.ThermalLevel {
        var thermalLevel: UInt32 = 0

        let result = IOPMGetThermalWarningLevel(&thermalLevel)

        if result == kIOReturnNotFound {
            return System.ThermalLevel.NotPublished
        }


        #if DEBUG
            if result != kIOReturnSuccess {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        // TODO: Thermal warning level values no longer available through
        //       IOKit.pwr_mgt module as of Xcode 6.3 Beta 3. Not sure if thats
        //       intended behaviour or a bug, will investigate. For now
        //       hardcoding values, will move all power related calls to a
        //       separate struct.
        switch thermalLevel {
            case 0:
                // kIOPMThermalWarningLevelNormal
                return System.ThermalLevel.Normal
            case 5:
                // kIOPMThermalWarningLevelDanger
                return System.ThermalLevel.Danger
            case 10:
                // kIOPMThermalWarningLevelCrisis
                return System.ThermalLevel.Crisis
            default:
                return System.ThermalLevel.Unknown
        }
    }


    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------
    
    
    private static func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?
        
        var size     = HOST_BASIC_INFO_COUNT
        var hostInfo = host_basic_info_t.alloc(1)
        
        let result = host_info(machHost, HOST_BASIC_INFO,
                                         UnsafeMutablePointer(hostInfo),
                                         &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }

    
    private static func hostLoadInfo() -> host_load_info {
        var size     = HOST_LOAD_INFO_COUNT
        var hostInfo = host_load_info_t.alloc(1)
        
        let result = host_statistics(machHost, HOST_LOAD_INFO,
                                               UnsafeMutablePointer(hostInfo),
                                               &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif
        
        return data
    }
    
    
    private static func hostCPULoadInfo() -> host_cpu_load_info {
        var size     = HOST_CPU_LOAD_INFO_COUNT
        var hostInfo = host_cpu_load_info_t.alloc(1)
        
        let result = host_statistics(machHost, HOST_CPU_LOAD_INFO,
                                               UnsafeMutablePointer(hostInfo),
                                               &size)
        
        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif

        return data
    }
    
    
    private static func processorLoadInfo() -> processor_set_load_info {
        // NOTE: Duplicate load average and mach factor here
        
        var pset   = processor_set_name_t()
        var result = processor_set_default(machHost, &pset)
        
        if result != KERN_SUCCESS {
            #if DEBUG
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            #endif

            return processor_set_load_info()
        }

        
        var count    = PROCESSOR_SET_LOAD_INFO_COUNT
        var info_out = processor_set_load_info_t.alloc(1)
        
        result = processor_set_statistics(pset,
                                          PROCESSOR_SET_LOAD_INFO,
                                          UnsafeMutablePointer(info_out),
                                          &count)


        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                        + "\(result)")
            }
        #endif


        // This is isn't mandatory as I understand it, just helps keep the ref
        // count correct. This is because the port is to the default processor
        // set which should exist by default as long as the machine is running
        mach_port_deallocate(mach_task_self_, pset)

        let data = info_out.move()
        info_out.dealloc(1)
        
        return data
    }
    
    
    /**
    64-bit virtual memory statistics. This should apply to all Mac's that run
    10.9 and above. For iOS, iPhone 5S, iPad Air & iPad Mini 2 and on.
    
    Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though its 7
    and above, with both ARM & ARM64.
    */
    private static func VMStatistics64() -> vm_statistics64 {
        var size     = HOST_VM_INFO64_COUNT
        var hostInfo = vm_statistics64_t.alloc(1)
        
        let result = host_statistics64(machHost,
                                       HOST_VM_INFO64,
                                       UnsafeMutablePointer(hostInfo),
                                       &size)

        let data = hostInfo.move()
        hostInfo.dealloc(1)
        
        #if DEBUG
            if result != KERN_SUCCESS {
                println("ERROR - \(__FILE__):\(__FUNCTION__) - kern_result_t = "
                    + "\(result)")
            }
        #endif
        
        return data
    }
}
