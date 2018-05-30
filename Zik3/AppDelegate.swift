//
//  AppDelegate.swift
//  Zik3
//
//  Created by Nicolas Thomas on 03/05/2018.
//  Copyright © 2018 Nicolas Thomas. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let deviceState = DeviceState()
    var service: BTCommunicationServiceInterface?
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    let iconOff = NSImage(named: NSImage.Name(rawValue: "disc"))
    let iconOn = NSImage(named: NSImage.Name(rawValue: "conn"))
    
    @objc
    func toggleNoiseCancellation(sender: AnyObject) {
        let _ = service?.toggleAsyncNoiseCancellation(!self.deviceState.noiseCancellationEnabled)
    }
    
    @objc
    func toggleEqualizer(sender: AnyObject) {
        let _ = service?.toggleAsyncEqualizerStatus(!self.deviceState.equalizerEnabled)
    }
    
    @objc
    func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc
    func doMenu() {
        if self.deviceState.name == "" {
            iconOff?.isTemplate = true

            statusItem.button?.image = iconOff
        }else{
            iconOn?.isTemplate = true
            statusItem.button?.image = iconOn

        }
        
        let menu = NSMenu(title: "Contextual menu")
        var menuItem = menu.addItem(withTitle: self.deviceState.name, action: nil, keyEquivalent: "")
        
        var title = "Battery level: " + self.deviceState.batteryLevel + "%"
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        title = "Power Source: " + (self.deviceState.batteryStatus == "charging" ? "Power Adapter" : "Battery")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        menuItem = menu.addItem(withTitle: "Noise cancellation", action: #selector(self.toggleNoiseCancellation), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.noiseCancellationEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Equalizer", action: #selector(self.toggleEqualizer), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.equalizerEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Quit", action: #selector(self.quit), keyEquivalent: "")
        menuItem.indentationLevel = 1
        statusItem.menu = menu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.service = BTCommunicationService(api: ParrotZik2Api(),
                                              zikResponseHandler: ZikResponseHandler(deviceState: deviceState))
        let _ = BTConnectionService(service: self.service!)
        
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.doMenu),
                             userInfo: nil,
                             repeats: true)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}
