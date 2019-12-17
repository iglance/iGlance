//
//  SegueBetweenEmbedded.swift
//  iGlance
//
//  Created by Dominik on 17.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class SegueBetweenEmbedded: NSStoryboardSegue {
    override func perform() {
        if let viewController = sourceController as? NSViewController {
            viewController.present(destinationController as! NSViewController, animator: SegueAnimator())
        }
    }
}
