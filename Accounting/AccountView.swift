//
//  AccountView.swift
//  Accounting
//
//  Created by Petar Petrov on 7.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

struct AccountView: View {
    @EnvironmentObject var store: Store
    @ObservedObject var accountsModel = AccountViewModel()
    @State var searchQuery: String = ""
    @State var isLoginPresented: Bool = false

    
    var body: some View {
        NavigationView {
            LoadingView(isShowing: .constant(self.store.loading)) {
                    VStack() {
                        if (self.accountsModel.isLogged) {
                            VStack {
                                if (!self.accountsModel.error.isEmpty) {
                                    Text(self.accountsModel.error)
                                    Button(action: {
                                        self.isLoginPresented.toggle()
                                    }) {
                                        Text("Login")
                                    }.sheet(isPresented: self.$isLoginPresented, onDismiss: {
                                        if !self.accountsModel.isLogged {
                                            self.isLoginPresented = true
                                        }
                                    }, content: {
                                        LoginView(isPresented: self.$isLoginPresented, didLogin: { isLogged in
                                            self.accountsModel.isLogged = isLogged
                                        }).environmentObject(self.store)
                                    })
                                } else {
                                    VStack {
                                        HStack {
                                            Text("Hello, \(UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")?.string(forKey: "name") ?? "")")
                                            .font(.largeTitle)
                                            .fontWeight(.black)
                                            .foregroundColor(Color("primary"))
                                            Spacer()
                                        }
                                        .padding()
                                        
                                            HStack {
                                                Text("Cards")
                                                    .fontWeight(.bold)
                                                    .padding(.leading, 10)
                                                Spacer()
                                                Image(systemName: "creditcard.fill")
                                                    .foregroundColor(Color("primary"))
                                                    .padding(.trailing, 10)
                                            }.padding()
                                        
                                            List(self.accountsModel.accounts) { account in
                                                NavigationLink(destination: AccountDetails(account: account)) {
                                                    VStack(alignment: .leading) {
                                                        Text(account.name)
                                                            .font(.body)
                                                            .padding(.bottom, 5)
                                                        HStack {
                                                            Text(String(format: "%.2f", account.amount))
                                                                .font(.system(size: 10))
                                                            Text(account.currency.sign)
                                                                .font(.system(size: 10))
                                                        }
                                                    }.background(Color.clear)
                                                }.padding(.all, 10)
                                                .background(Color.blue.opacity(0.07))
                                                .cornerRadius(10)
                                            }
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                            
                        } else {
                            VStack {
                                Button(action: {
                                    self.isLoginPresented.toggle()
                                }) {
                                    Text("Login")
                                }
                                .sheet(isPresented: self.$isLoginPresented, onDismiss: {
                                    if !self.accountsModel.isLogged {
                                        self.isLoginPresented = true
                                    }
                                }, content: {
                                    LoginView(isPresented: self.$isLoginPresented, didLogin: { isLogged in
                                        self.accountsModel.isLogged = isLogged
                                        if (isLogged) {
                                            if let token = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")?.string(forKey: "token") {
                                                self.accountsModel.fetchAccounts(token: token) {
                                                    self.isLoginPresented = true
                                                }
                                            }
                                        }
                                        
                                    }).environmentObject(self.store)
                                })
                            }
                        }
                    }
                    .onAppear {
                        self.store.loading = false
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        if let token = defaults.string(forKey: "token") {
                            if (!token.isEmpty) {
                                AccountService().getAccounts(token: token) { response, error in
                                    self.accountsModel.isLogged = !(error == .unauthorize)
                                    if (error == .success) {
                                        self.accountsModel.accounts = response;
                                        self.accountsModel.error = ""
                                    }
                                    if (error == .unauthorize) {
                                        self.accountsModel.error = "Access Error"
                                        self.accountsModel.isLogged = false
                                    }
                                    self.isLoginPresented = !self.accountsModel.isLogged
                                    self.store.loading = false
                                }
                            } else {
                                self.accountsModel.isLogged = false
                                self.isLoginPresented = true
                                self.store.loading = false
                            }
                        } else {
                            self.accountsModel.isLogged = false
                            self.isLoginPresented = true
                            self.store.loading = false
                        }
                    }
                    .navigationBarHidden(true)
                    .navigationBarTitle("", displayMode: .inline)
                }
            
        }
        
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
        .environmentObject(Store())
    }
}
