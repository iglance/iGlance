//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
