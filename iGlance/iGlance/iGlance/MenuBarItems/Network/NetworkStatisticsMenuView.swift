//
//  NetworkStatisticsMenuView.swift
//  iGlance
//
//  Created by Dominik on 27.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class NetworkStatisticsMenuView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // load the nib of the view
        if !Bundle.main.loadNibNamed("NetworkStatisticsMenuView", owner: self, topLevelObjects: nil) {
            DDLogError("Failed to load the 'NetworkStatisticsMenuView' nib")
            return
        }

        // create the frame for the content view
        contentView.frame = NSRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        // add the content view as a subview
        addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: -
    // MARK: Outlets

    /// The reference to the custom view
    @IBOutlet private var contentView: NSView!

    /// Reference to the upload label
    @IBOutlet private var uploadLabel: NSTextField!

    /// Reference to the download
    @IBOutlet private var downloadLabel: NSTextField!

    /// Reference to the total transmitted data label
    @IBOutlet private var totalLabel: NSTextField!

    // MARK: -
    // MARK: Instance Functions

    /**
     * Sets the upload label of the view.
     */
    func setUploadLabel(_ value: String) {
        self.uploadLabel.stringValue = value
    }

    /**
     * Sets the download label of the view.
     */
    func setDownloadLabel(_ value: String) {
        self.downloadLabel.stringValue = value
    }

    /**
     * Sets the label for the total transmitted data.
     */
    func setTotalLabel(_ value: String) {
        self.totalLabel.stringValue = value
    }
}
