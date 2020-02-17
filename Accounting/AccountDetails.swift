//
//  AccountDetails.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import UIKit

struct AccountDetails: View {
    var account: Account
    @State var isAddPresented: Bool = false
    @State var fullScreen: Bool = false
    @Environment(\.viewController) private var viewControllerHolder
    @State var transactions = [Transaction]()
    @State var daysToSalary: Int = 0
    @EnvironmentObject var store: Store
    @State var scroll: Double = 0;
    @State var fixed: Bool = false
    
    @State var filterToggle: Bool = false
    var interval = Calendar.current.dateInterval(of: .month, for: Date())
    var blurAmount: CGFloat = 2
    @State var from: Date = Date()
    @State var to: Date = Date()
    @State private var search: String = ""
    @State private var input: UITextField = UITextField()
    
    fileprivate func openNewTransactionScreen(with style: UIModalPresentationStyle) {
        self.viewControllerHolder?.present(style: style) {
            KeyboardHost {
                NewTransactionModal(isPresented: self.$isAddPresented, categories: [], account: self.account, onCreate: { a, b in
                    self.getTransactions()
                }).environmentObject(self.store)
            }
            
        }
    }
    
    fileprivate func getTransactions() {
        self.store.loading.toggle()
        TransactionService().getByAccountAndDates(account: self.account.id, from: from, to: to) { response in
            switch response {
            case .success(let transactions):
                self.transactions = transactions.response
                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                WatchManager.shared.sendParamsToWatch(dict: [
                    "force_send": UUID().uuidString,
                    "type": "auth",
                    "name": defaults.string(forKey: "name") ?? "",
                    "token": transactions.token.token,
                    "id": transactions.token.userId
                ])
                break;
            case .failure(let error):
                print(error)
                break
            }
            DispatchQueue.main.async {
                self.store.loading.toggle()
            }
        }
    }
    
    fileprivate func textFieldEditingDidChange() {
        print("edit")
    }
    
    var body: some View {
        VStack {
            Section {
                AccountCard(account: self.account)
                .blur(radius: self.filterToggle ? blurAmount : 0)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Transactions")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(Color("secondary-text"))
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom, 2)
                    .layoutPriority(1)
                Spacer()
                HStack {
                    Button(action: {
                        self.filterToggle.toggle()
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                    }) {
                     Image(systemName: "line.horizontal.3.decrease.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                         .foregroundColor(Color("primary-text"))
                    }
                    
                    
                    
                    Spacer()
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        generator.impactOccurred()
                        self.openNewTransactionScreen(with: .automatic)
                    }) {
                        HStack {
                            Text("Add")
                                .foregroundColor(Color("primary-text"))
                            Image(systemName: "plus")
                                .foregroundColor(Color("primary-text"))
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(self.account.currencyId != 0 ? Color("primary-text") : .gray, lineWidth: 2)
                        )
                            .contextMenu {
                                if (self.account.currencyId != 0) {
                                    Button(action: {
                                        self.openNewTransactionScreen(with: .fullScreen)
                                    }) {
                                        Text("Full screen")
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    }
                                    Button(action: {}) {
                                        Text("New transfer")
                                        Image(systemName: "dollarsign.square")
                                    }
                                }
                        }
                    }
                    .disabled(!(self.account.currencyId != 0))
                    .onAppear{
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        if (defaults.object(forKey: "from") != nil && defaults.object(forKey: "to") != nil) {
                            self.from = defaults.object(forKey: "from") as! Date
                            self.to = defaults.object(forKey: "to") as! Date
                        } else {
                            let interval = Calendar.current.dateInterval(of: .month, for: Date())
                            self.from  = interval?.start ?? Date()
                            self.to = interval?.end ?? Date()
                        }
                       
                        self.daysToSalary = TransactionService.calculateDayToNextSalary(5)
                        self.getTransactions()
                    }
                }
            }
            .padding(.trailing)
            .blur(radius: self.filterToggle ? blurAmount : 0)
            HStack {
                
                ResponderTextField() { textView in
                    textView.addTarget(self.store, action: #selector(self.store.textFieldEditingDidChange(_:)), for: UIControl.Event.editingDidBegin)
                    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
                    textView.leftView = paddingView
                    textView.backgroundColor = .gray
                    textView.layer.cornerRadius=8.0
                    textView.leftViewMode = .always
                    textView.frame.size.height = 50
//                    textView.
                }
                .padding()
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                }) {
                    Image(systemName: "xmark.circle.fill")
                }.padding()
            }
            .frame(height: 50)
                List {
                    
                        ForEach(self.transactions) { transaction in
                            TransactionRow(transaction: transaction, account: self.account)
                                .frame(height: 50)
                        }
                        .onDelete(perform: { offset in
                            self.transactions.remove(atOffsets: offset)
                        })
                }
                .blur(radius: self.filterToggle ? self.blurAmount : 0)
                .overlay(
                    PopupPicker(toggle: self.$filterToggle, view: AnyView(FilterView(from: self.$from, to: self.$to, onDone: { (from, to) in
                        self.from = from
                        self.to = to
                        self.filterToggle.toggle()
                        self.getTransactions()
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        defaults.set(from, forKey: "from")
                        defaults.set(to, forKey: "to")
                        defaults.synchronize()
                    })))
                )
            
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
struct ResponderTextField: UIViewRepresentable {

    typealias TheUIView = UITextField
    var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
