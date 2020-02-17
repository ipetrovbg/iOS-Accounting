//
//  AccountDetails.swift
//  Accounting WatchApp Extension
//
//  Created by Petar Petrov on 9.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountDetails: View {
    @EnvironmentObject var store: Store
    let account: Account
    
    @State var selection: Int? = nil
    @State var decimal = 0
    @State var single = 0
    @State var afterComma = 0
    @State var phrase = 0
    @State var category = 0
    var phrases: [String] = [
        "For food",
        "For lunch",
        "For dinner",
        "For breakfast",
        "For coffee",
        "For groceries",
        "For Mall",
        "For Starbucks",
        "For T-shirt",
        "For city transport",
        "For movie",
        "For flowers",
        "For B-day present",
        "For gift",
        "Other"
    ]
    var rowHeight: CGFloat = 50
    
    var body: some View {
        VStack {
            if !self.store.token.isEmpty {
                ScrollView {
                    HStack(alignment: .bottom) {
                        HStack {
                            Picker("Tens", selection: $decimal) {
                                ForEach(0..<10) { cat in
                                    Text("\(cat)")
                                        .padding()
                                        .font(.system(.body, design: .rounded))
                                }
                            }.frame(height: self.rowHeight)
                        }
                        
                        HStack {
                            Picker("Ones", selection: $single) {
                                ForEach(0..<10) { cat in
                                    Text("\(cat)")
                                        .padding()
                                        .font(.system(.body, design: .rounded))
                                }
                            }.frame(height: rowHeight)
                        }
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Picker("Tenths", selection: $afterComma) {
                                ForEach(0..<10) { cat in
                                    Text("\(cat)")
                                        .padding()
                                        .font(.system(.body, design: .rounded))
                                }
                            }.frame(height: rowHeight)
                        }
                    }
                    HStack {
                        Picker("Categories", selection: $category) {
                            ForEach(0..<self.store.categories.count, id: \.self) { c in
                                Text(self.store.categories[c].category).tag(c)
                            }
                        }.frame(height: rowHeight)
                    }
                    HStack {
                        Picker("Phrases", selection: $phrase) {
                            ForEach(0..<phrases.count, id: \.self) {
                                Text(self.phrases[$0]).tag($0)
                            }
                        }.frame(height: rowHeight)
                    }
                    HStack {
                        NavigationLink(destination: ContentView(), tag: 1, selection: $selection) {
                            Button(action: {
                                self.selection = 1
                                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                                if let id = defaults.string(forKey: "id") {
                                    let ammountFormatter = NumberFormatter()
                                    let number = ammountFormatter.number(from: "\(self.decimal)\(self.single),\(self.afterComma)")
                                    let category: Category = self.store.categories[self.category]
                                    let note = self.phrases[self.phrase]
                                    
                                    
                                    let transaction = Transaction(comment: note, simulation: true, date: String("\(Date())"), id: nil, amount: Double(number?.doubleValue ?? 0), originalAmount: Double(number?.doubleValue ?? 0.0), currencyId: self.account.currency.id, userId: Int(id)!, type: "withdrawal", accountId: self.account.id, category: category, createdAt: String("\(Date())"), DeviceToken: "")
                                    
                                    self.store.createTransaction(transaction: transaction)
                                }
                            }) {
                                HStack {
                                    Text("Add")
                                    Image(systemName: "plus")
                                }
                            }
                            .background(self.account.currencyId != 0 ? Color.green : Color.gray)
                            .cornerRadius(8)
                            .disabled(!(self.account.currencyId != 0))
                        }
                        
                        
                    }
                }
            } else {
                Text("Unauthorize")
            }
        }
        .onAppear {
            self.store.getCategories()
        }
        .navigationBarBackButtonHidden(self.store.token.isEmpty)
        .navigationBarHidden(self.store.token.isEmpty)
    }
}

struct AccountDetails_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetails(account: Account(id: 9, name: "Main", amount: 98.9, currencyId: 3, currency: Currency(id: 3, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria"))).environmentObject(Store())
    }
}
