//
//  WatchManager.swift
//  Accounting
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchManager: NSObject {
    fileprivate var watchSession: WCSession?
    static let shared: WatchManager = WatchManager()
    
    override init() {
        super.init()
        if !WCSession.isSupported() {
            watchSession = nil
            return
        }
        watchSession = WCSession.default
        watchSession?.delegate = self
        watchSession?.activate()
    }
    
    func sendParamsToWatch(dict: [String: Any]) {
        
        do {
            try watchSession?.updateApplicationContext(dict)
        } catch {
            print("Error sending dictionary \(dict) to Apple Watch")
        }
    }
}

extension WatchManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
}
