//
//  CPUViewController.swift
//  iGlance
//
//  Created by Cemal on 05.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class CPUViewController: NSViewController {

    @IBOutlet weak var cbCPUUtil: NSButton!
    @IBOutlet weak var cbCPUTemp: NSButton!
    @IBOutlet weak var ddTempUnit: NSPopUpButton!
    @IBOutlet weak var cpCPU: NSColorWell!
    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("xddddddd")
    }
    
    @IBAction func cbCPUUtil_clicked(_ sender: NSButton) {
    }
    @IBAction func cbCPUTemp_clicked(_ sender: NSButton) {
    }
    @IBAction func ddTempUnit_clicked(_ sender: NSPopUpButton) {
    }
    @IBAction func cpCPU_clicked(_ sender: NSColorWell) {
    }
    //MARK: Actions
}
