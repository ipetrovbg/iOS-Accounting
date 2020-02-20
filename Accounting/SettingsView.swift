//
//  Settings.swift
//  Accounting
//
//  Created by Petar Petrov on 11.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import WatchConnectivity

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @ObservedObject var accountsModel = AccountViewModel()
    @State var loginPresented: Bool = false
    var body: some View {
        LoadingView(isShowing: .constant(self.store.loading)) {
            VStack(spacing: 20.0) {
                if self.accountsModel.isLogged {
                    Button(action: {
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        defaults.removeObject(forKey: "password")
                        defaults.removeObject(forKey: "email")
                    }) {
                        Text("Clear FaceID/TouchID Date")
                            .foregroundColor(Color.red)
                    }
                }
                Button(action: {
                    let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                    defaults.set("", forKey: "token")
                    defaults.set(nil, forKey: "id")
                    let interval = Calendar.current.dateInterval(of: .month, for: Date())
                    defaults.set(interval?.start ?? Date() , forKey: "from")
                    defaults.set(interval?.end ?? Date(), forKey: "to")
                    let watchAuthDict: [String: Any] = [
                        "type": "auth",
                        "force_send": UUID().uuidString,
                        "name": "",
                        "id": 0,
                        "token": ""
                    ]
                    
                    WatchManager.shared.sendParamsToWatch(dict: watchAuthDict)
                    self.accountsModel.isLogged = false
                    self.loginPresented = true
                }) {
                    self.accountsModel.isLogged ? Text("Log out") : Text("Log in")
                }
                .onAppear {
                    self.store.loading = true
                    let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                    if let token = defaults.string(forKey: "token") {
                        AccountService().getAccounts(token: token) { accounts, error in
                            self.accountsModel.isLogged = !(error == .unauthorize)
                            self.loginPresented = !self.accountsModel.isLogged
                            self.store.loading = false
                        }
                    }else {
                        self.accountsModel.isLogged = false
                        self.loginPresented = true
                        self.store.loading = false
                    }
                    
                }
                .sheet(isPresented: self.$loginPresented, onDismiss: {
                    if !self.accountsModel.isLogged {
                        self.loginPresented = true
                    }
                }) {
                    LoginView(isPresented: self.$loginPresented, didLogin: { logged in
                        if (logged) {
                            self.loginPresented = false
                        }
                        self.accountsModel.isLogged = logged
                    }).environmentObject(self.store)
                }
            }
        }
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
