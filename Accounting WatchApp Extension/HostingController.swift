//
//  HostingController.swift
//  Accounting WatchApp Extension
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    var store: Store = Store()
    var content: AnyView = AnyView(Text("init"))
    override init() {
        super.init()
        self.content = AnyView(ContentView().environmentObject(self.store))
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: .auth, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadAccounts), name: .loadAccounts, object: nil)
        
    }
    
    @objc func onLoadAccounts() {
        if !self.store.token.isEmpty {
             self.store.getAccounts()
        } else {
            self.store.accounts = []
        }
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        
        if let data = notification.userInfo as? [String: Any] {
            if let name = data["name"] {
                self.store.name = name as! String
            }
            if let token = data["token"] {
                self.store.token = token as? String ?? ""
                self.onLoadAccounts()
//                if !self.store.token.isEmpty {
//                     self.store.getAccounts()
//                } else {
//                    self.store.accounts = []
//                }
               
            }
        }
    }
    
    override var body: AnyView {
        return self.content
    }
}
