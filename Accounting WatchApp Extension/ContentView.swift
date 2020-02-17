//
//  ContentView.swift
//  Accounting WatchApp Extension
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    var accountService: AccountService = AccountService()
    
    
    fileprivate func sync() {
        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")
        self.store.name = defaults?.string(forKey: "name") ?? "Petar Petrov"
        self.store.token = defaults?.string(forKey: "token") ?? "hhh"
        if !self.store.token.isEmpty {
            self.accountService.getAccounts(token: self.store.token) { accounts, error in
                if (error == .success) {
                    self.store.accounts = accounts
                } else {
                    self.store.accounts = []
                }
                if error == .unauthorize {
                    self.store.resetDefaults()
                }
            }
        } else {
            self.store.accounts = []
            self.store.mainScreen = 1
        }
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if !self.store.token.isEmpty {
                HStack(alignment: .lastTextBaseline) {
                    Text(self.store.name)
                        .fontWeight(.bold)
                        .layoutPriority(1)
                        .lineLimit(3)

                    Spacer()
                    Text("\(TransactionService.calculateDayToNextSalary())")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.black)
                    .layoutPriority(3)
                    Text("d")
                        .font(.system(size: 12, design: .rounded))
                    .layoutPriority(2)
                }
                
            }
            Spacer().frame(height: 30)
            GeometryReader { geo in
                ZStack {
                    AccountsViewWatch(isLogged: !self.store.token.isEmpty)
                        .environmentObject(self.store)
                    if self.store.loading && !self.store.token.isEmpty {
                        Rectangle()
                            .frame(width: geo.frame(in: .global).width, height: geo.frame(in: .global).height + 80)
                            .opacity(0.89)
                            .foregroundColor(.black)
                        Text("Loading...")
                            .foregroundColor(.white)
                            .offset(y: -15)

                    }
                }
            }
            
        }
        .onAppear {
            self.sync()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(Store())
    }
}
