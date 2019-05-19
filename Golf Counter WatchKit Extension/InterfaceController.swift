//
//  InterfaceController.swift
//  Golf Counter WatchKit Extension
//
//  Created by Aaron Sears on 9/2/18.
//  Copyright © 2018 SearsStudio. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var strokeCounter: WKInterfaceLabel!
    @IBOutlet var puttCounter: WKInterfaceLabel!
    
    var strokeCount = 0
    var puttCount = 0
    
    let session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePhoneData), name: NSNotification.Name(rawValue: "receivedPhoneData"), object: nil)
        
        strokeCounter.setText("\(strokeCount)")
        puttCounter.setText("\(puttCount)")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    @IBAction func plusStrokeButtonPressed() {
        strokeCount += 1
        strokeCounter.setText("\(strokeCount)")
        toPhoneTapped()
    }
    
    @IBAction func minusStrokeButtonPressed() {
        strokeCount -= 1
        strokeCounter.setText("\(strokeCount)")
    }
    
    @IBAction func plusPuttButtonPressed() {
        puttCount += 1
        puttCounter.setText("\(puttCount)")
    }
    
    @IBAction func minusPuttButtonPressed() {
        puttCount -= 1
        puttCounter.setText("\(puttCount)")
    }
    
    @objc func didReceivePhoneData(info: NSNotification) {
        
        let msg = info.userInfo!
        self.strokeCounter.setText(msg["Msg"] as? String)
        print(msg["Msg"] as? String ?? "failed")
        print(info)
    }
    
    func toPhoneTapped() {
        self.session.sendMessage(["Msg" : "9"], replyHandler: nil, errorHandler: nil)
    }
    
    

}
