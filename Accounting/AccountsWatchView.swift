//
//  AccountsWatchView.swift
//  AccountingWatchApp Extension
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountsWatchView: View {
    var body: some View {
        VStack {
            Text("Hello \(UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")?.string(forKey: "token") ?? "nil")")
        }.onAppear {
            let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
            if let token = defaults.string(forKey: "token") {
                print("TOKEN", token)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsWatchView()
    }
}
