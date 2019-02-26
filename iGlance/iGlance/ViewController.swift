//
//  ViewController.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Cocoa
import ServiceManagement

extension Data {
    func toString() -> String {
        return String(data: self, encoding: .utf8)!
    }
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // define the outlet and action of the checkbox which activates and deactivates autostart
    @IBOutlet var cbAutostart: NSButton! {
        didSet {
            cbAutostart.state = (AppDelegate.UserSettings.userWantsAutostart) ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbAutostart_clicked(_: NSButton) {
        AppDelegate.UserSettings.userWantsAutostart = (cbAutostart.state == NSButton.StateValue.on)
        if cbAutostart.state == NSButton.StateValue.on {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, true) {
                _ = AppDelegate.dialogOK(question: "Error", text: "Something went wrong, sorry")
                cbAutostart.state = NSButton.StateValue.off
            } else {
                UserDefaults.standard.set(true, forKey: "userWantsAutostart")
            }
        } else {
            if !SMLoginItemSetEnabled(NCConstants.launcherApplicationIdentifier as CFString, false) {
                _ = AppDelegate.dialogOK(question: "Error", text: "Something went wrong, sorry")
            } else {
                UserDefaults.standard.set(false, forKey: "userWantsAutostart")
            }
        }
    }

    // define the outlet to the logo
    @IBOutlet var imgLogo: NSImageView! {
        didSet {
            imgLogo.image = NSImage(named: "logo")
        }
    }

    // define the outlet and the action of the drop down menu to specify the update interval
    @IBOutlet var ddUpdateInterval: NSPopUpButton! {
        didSet {
            switch AppDelegate.UserSettings.updateInterval
            {
            case 1.0:
                ddUpdateInterval.selectItem(at: 0)
                break
            case 2.0:
                ddUpdateInterval.selectItem(at: 1)
                break
            case 3.0:
                ddUpdateInterval.selectItem(at: 2)
                break
            default:
                ddUpdateInterval.selectItem(at: 1)
            }
        }
    }

    @IBAction func ddUpdateInterval_clicked(_: NSPopUpButton) {
        switch ddUpdateInterval.indexOfSelectedItem

        {
        case 0:
            AppDelegate.UserSettings.updateInterval = 1.0
            UserDefaults.standard.set(1.0, forKey: "updateInterval")
            break
        case 1:
            AppDelegate.UserSettings.updateInterval = 2.0
            UserDefaults.standard.set(2.0, forKey: "updateInterval")
            break
        case 2:
            AppDelegate.UserSettings.updateInterval = 3.0
            UserDefaults.standard.set(3.0, forKey: "updateInterval")
            break
        default:
            AppDelegate.UserSettings.updateInterval = 2.0
        }
    }

    // define the outlet and the action of the update button
    @IBOutlet var btnCheckUpdate: NSButton!
    @IBAction func btnCheckUpdate_clicked(_: NSButton) {
        var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/Moneypulation/iGlance/master/Version.txt")!)
        request.httpMethod = "GET"
        let (htmltext, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance\n\n\(error)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            let pat = "\\[version\\](.*)\\[\\/version\\]"
            let res = matches(for: pat, in: String(data: htmltext!, encoding: String.Encoding.utf8)!)
            if res.count != 1 {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Unable to check for updates. Please check yourself on https://github.com/Moneypulation/iGlance\n\nError: Version.txt incompatible"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
            } else {
                let onlyversion = res[0].replacingOccurrences(of: "[version]", with: "").replacingOccurrences(of: "[/version]", with: "")
                if onlyversion != AppDelegate.VERSION {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "A new version (" + onlyversion + ") is available at: \n\n https://github.com/Moneypulation/iGlance"
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "Visit Website")
                    alert.addButton(withTitle: "OK")
                    if alert.runModal() == .alertFirstButtonReturn {
                        if let url = URL(string: "https://github.com/Moneypulation/iGlance"), NSWorkspace.shared.open(url) {}
                    }
                } else {
                    let alert = NSAlert()
                    alert.messageText = ""
                    alert.informativeText = "Running latest version (" + onlyversion + ")"
                    alert.alertStyle = .informational
                    let btnvisit = NSButtonCell(textCell: "Visit website")
                    btnvisit.bezelStyle = .rounded
                    btnvisit.isHighlighted = true
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }

    /**
     * Searches for a string in a given text.
     */
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch {
            NSLog("Error invalid regex: ", error.localizedDescription)
            return []
        }
    }
}
