SystemKit
=========

An OS X system library in Swift based off of
[libtop](http://www.opensource.apple.com/source/top/top-100.1.2/libtop.c), from
Apple's top implementation.

- For an example usage of this library, see
  [dshb](https://github.com/beltex/dshb), an OS X system monitor in Swift
- For other system related statistics in Swift for OS X, see
  [SMCKit](https://github.com/beltex/SMCKit)


### Requirements

- [Xcode 6.3.2](https://developer.apple.com/xcode/downloads/)
- OS X 10.9+
    - This is due to Swift


### Example

Sample ouput from
[example](https://github.com/beltex/SystemKit/blob/master/Example/main.swift).

```
// MACHINE STATUS

-- CPU --
  PHYSICAL CORES:  2
  LOGICAL CORES:   2
  SYSTEM:          10%
  USER:            17%
  IDLE:            71%
  NICE:            0%

-- MEMORY --
  PHYSICAL SIZE:   7.75GB
  FREE:            1.33GB
  WIRED:           866MB
  ACTIVE:          5.04GB
  INACTIVE:        516MB
  COMPRESSED:      0MB

-- SYSTEM --
  MODEL:           MacBookPro7,1
  SYSNAME:         Darwin
  NODENAME:        beltex.local
  RELEASE:         13.4.0
  VERSION:         Darwin Kernel Version 13.4.0: Sun Aug 17 19:50:11 PDT 2014...
  MACHINE:         x86_64
  UPTIME:          6d 21h 4m 38s
  PROCESSES:       197
  THREADS:         967
  LOAD AVERAGE:    [3.18, 3.89, 3.99]
  MACH FACTOR:     [0.436, 0.385, 0.322]

-- POWER --
  CPU SPEED LIMIT: 100.0%
  CPUs AVAILABLE:  2
  SCHEDULER LIMIT: 100.0%
  THERMAL LEVEL:   Not Published

-- BATTERY --
  AC POWERED:      true
  CHARGED:         true
  CHARGING:        false
  CHARGE:          100.0%
  CAPACITY:        1675 mAh
  MAX CAPACITY:    1675 mAh
  DESGIN CAPACITY: 5450 mAh
  CYCLES:          646
  MAX CYCLES:      1000
  TEMPERATURE:     30.0°C
  TIME REMAINING:  0:45
```


### References

- [top](http://www.opensource.apple.com/source/top/)
- [hostinfo](http://www.opensource.apple.com/source/system_cmds/)
- [vm_stat](http://www.opensource.apple.com/source/system_cmds/)
- [PowerManagement](http://www.opensource.apple.com/source/PowerManagement/)
- iStat Pro


### License

This project is under the **MIT License**.
