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

public class Dialog: NSObject {
    /**
     * Displays an error modal with the given message and informative text.
     */
    public static func showErrorModal(messageText: String, informativeText: String) {
        let errorAlert = NSAlert()
        errorAlert.messageText = messageText
        errorAlert.informativeText = informativeText
        errorAlert.alertStyle = .critical
        errorAlert.addButton(withTitle: "OK")
        errorAlert.runModal()
    }

    /**
     * Displays a confimation modal in which the user has the option to accept or cancel.
     */
    public static func showConfirmModal(messageText: String, informativeText: String) -> NSApplication.ModalResponse {
        let confirm = NSAlert()
        confirm.messageText = messageText
        confirm.informativeText = informativeText
        confirm.alertStyle = .warning
        confirm.addButton(withTitle: "Yes")
        confirm.addButton(withTitle: "Cancel")
        return confirm.runModal()
    }
}
