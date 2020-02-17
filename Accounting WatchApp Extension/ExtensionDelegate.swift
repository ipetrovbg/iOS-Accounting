//
//  ExtensionDelegate.swift
//  Accounting WatchApp Extension
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        let type = applicationContext["type"] as! String
        
        switch type {
        case "accounts":
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .loadAccounts, object: self, userInfo: nil)
            }
            break
        case "auth":
            DispatchQueue.main.async {
                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                defaults.set(applicationContext["name"], forKey: "name")
                defaults.set(applicationContext["id"], forKey: "id")
                defaults.set(applicationContext["token"], forKey: "token")
                defaults.synchronize()
                
                NotificationCenter.default.post(name: .auth, object: self, userInfo: applicationContext)
            }
            break
        default:
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .loadAccounts, object: self, userInfo: nil)
            }
        }
       
    }
    

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .loadAccounts, object: self, userInfo: nil)
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}


extension Notification.Name {
    static let auth = Notification.Name("didReceiveData")
    static let loadAccounts = Notification.Name("loadAccounts")
}
