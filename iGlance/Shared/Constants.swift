//
//  Constants.swift
//  iGlance
//
//  Created by Dominik on 07.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

#if DEBUG
let DEBUG = true
let ddLogLevel = DDLogLevel.debug
#else
let DEBUG = false
let ddLogLevel = DDLogLevel.info
#endif

let LAUNCHER_BUNDLE_IDENTIFIER = "io.github.iglance.iGlanceLauncher"
let MAIN_APP_BUNDLE_IDENTIFIER = "io.github.iglance.iGlance"
