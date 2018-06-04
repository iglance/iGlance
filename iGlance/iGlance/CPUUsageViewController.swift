//
//  CPUUsageViewController.swift
//  iGlance
//
//  Created by Cemal on 04.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUUsageViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension CPUUsageViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> CPUUsageViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "CPUUsageViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? CPUUsageViewController else {
            fatalError("Why cant i find CPUUsageViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
