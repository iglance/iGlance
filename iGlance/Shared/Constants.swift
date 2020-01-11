//
//  Constants.swift
//  iGlance
//
//  Created by Dominik on 07.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

let LAUNCHER_BUNDLE_IDENTIFIER = "io.github.iglance.iGlanceLauncher"
let MAIN_APP_BUNDLE_IDENTIFIER = "io.github.iglance.iGlance"

// set the log level of the app to info on release builds
#if DEBUG
let ddLogLevel = DDLogLevel.debug
#else
let ddLogLevel = DDLogLevel.info
#endif
