//
// Process.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
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
import Foundation

//------------------------------------------------------------------------------
// MARK: GLOBAL PUBLIC PROPERTIES
//------------------------------------------------------------------------------

// As defined in <mach/machine.h>

/// Assuming this is interpreted as unknown for now
public let CPU_TYPE_ANY: cpu_type_t = -1
public let CPU_TYPE_X86: cpu_type_t = 7
public let CPU_TYPE_I386: cpu_type_t = CPU_TYPE_X86   // For compatibility
public let CPU_TYPE_X86_64: cpu_type_t = CPU_TYPE_X86 | CPU_ARCH_ABI64
public let CPU_TYPE_ARM: cpu_type_t = 12
public let CPU_TYPE_ARM64: cpu_type_t = CPU_TYPE_ARM | CPU_ARCH_ABI64
public let CPU_TYPE_POWERPC: cpu_type_t = 18
public let CPU_TYPE_POWERPC64: cpu_type_t = CPU_TYPE_POWERPC | CPU_ARCH_ABI64

//------------------------------------------------------------------------------
// MARK: PUBLIC STRUCTS
//------------------------------------------------------------------------------

/// Process information
public struct SKProcessInfo {
    let pid: Int
    let ppid: Int
    let pgid: Int
    let uid: Int
    let command: String
    /// What architecture was this process compiled for?
    let arch: cpu_type_t
    /// sys/proc.h - SIDL, SRUN, SSLEEP, SSTOP, SZOMB
    var status: Int32
}

/// Process API
public struct SKProcessAPI {
    //--------------------------------------------------------------------------
    // MARK: PRIVATE PROPERTIES
    //--------------------------------------------------------------------------

    fileprivate static let machHost = mach_host_self()

    //--------------------------------------------------------------------------
    // MARK: PUBLIC INITIALIZERS
    //--------------------------------------------------------------------------

    public init() { }

    //--------------------------------------------------------------------------
    // MARK: PUBLIC METHODS
    //--------------------------------------------------------------------------

    /// Return list of currently running processes
    public static func list() -> [SKProcessInfo] {
        var list                                = [SKProcessInfo]()
        var psets: processor_set_name_array_t?  = processor_set_name_array_t.allocate(capacity: 1)
        var pcnt: mach_msg_type_number_t = 0

        // Need root
        var result = host_processor_sets(machHost, &psets, &pcnt)
        if result != KERN_SUCCESS {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - Need root - " +
                        "kern_return_t: \(result)")
            #endif
            return list
        }

        // For each CPU set
        for cpuSet in 0..<Int(pcnt) {
            var pset: processor_set_name_t = 0
            result = host_processor_set_priv(machHost, psets![cpuSet], &pset)

            if result != KERN_SUCCESS {
                #if DEBUG
                    print("ERROR - \(#file):\(#function) - CPU set " +
                            "\(cpuSet) - kern_return_t: \(result)")
                #endif
                continue
            }

            // Get port to each task
            var tasks: task_array_t?                = task_array_t.allocate(capacity: 1)
            var taskCount: mach_msg_type_number_t = 0
            result = processor_set_tasks(pset, &tasks, &taskCount)

            if result != KERN_SUCCESS {
                #if DEBUG
                    print("ERROR - \(#file):\(#function) - failed to "
                            + " get tasks - kern_return_t: \(result)")
                #endif
                continue
            }

            // For each task
            for x in 0 ..< Int(taskCount) {
                let task = tasks![x]
                var pid: pid_t = 0

                pid_for_task(task, &pid)

                // BSD layer only stuff
                var kinfo = kinfo_proc()
                var size = MemoryLayout<kinfo_proc>.stride
                var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]

                // TODO: Error check
                sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)

                let command = withUnsafePointer(to: &kinfo.kp_proc.p_comm) {
                    String(cString: UnsafeRawPointer($0).assumingMemoryBound(to: CChar.self))
                }

                list.append(
                    SKProcessInfo(
                        pid: Int(pid),
                        ppid: Int(kinfo.kp_eproc.e_ppid),
                        pgid: Int(kinfo.kp_eproc.e_pgid),
                        uid: Int(kinfo.kp_eproc.e_ucred.cr_uid),
                        command: command,
                        arch: arch(pid),
                        status: Int32(kinfo.kp_proc.p_stat)
                    )
                )

                mach_port_deallocate(mach_task_self_, task)
            }

            // TODO: Missing deallocate for tasks. Why do dealloc calls on tasks and psets fail?
            mach_port_deallocate(mach_task_self_, pset)
            mach_port_deallocate(mach_task_self_, psets![cpuSet])
        }

        return list
    }

    //--------------------------------------------------------------------------
    // MARK: PRIVATE METHODS
    //--------------------------------------------------------------------------

    /// What architecture was this process compiled for?
    fileprivate static func arch(_ pid: pid_t) -> cpu_type_t {
        var arch = CPU_TYPE_ANY

        // sysctl.proc_cputype not documented anywhere. Doesn't even show up
        // when running 'sysctl -A'. Have to call sysctlnametomib() before hand
        // due to this
        // TODO: Call sysctlnametomib() only once
        var mib       = [Int32](repeating: 0, count: Int(CTL_MAXNAME))
        var mibLength = size_t(CTL_MAXNAME)

        var result = sysctlnametomib("sysctl.proc_cputype", &mib, &mibLength)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function):\(#line) - "
                        + "\(result)")
            #endif

            return arch
        }

        mib[Int(mibLength)] = pid
        var size = MemoryLayout<cpu_type_t>.size

        result = sysctl(&mib, u_int(mibLength + 1), &arch, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function):\(#line) - "
                        + "\(result)")
            #endif

            arch = CPU_TYPE_ANY
        }

        return arch
    }
}
