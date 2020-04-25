//
//  Dialog.swift
//  iGlance
//
//  Created by Cemal on 24.04.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

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
