//
//  AccountDetails.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountDetails: View {
    var account: Account
    @State var isAddPresented: Bool = false
    @State var fullScreen: Bool = false
    @Environment(\.viewController) var viewControllerHolder
    @State var transactions = [Transaction]()
    @State var daysToSalary: Int = 0
    @EnvironmentObject var store: Store
    
    fileprivate func openNewTransactionScreen(with style: UIModalPresentationStyle) {
        self.viewControllerHolder?.present(style: style) {
            KeyboardHost {
                NewTransactionModal(isPresented: self.$isAddPresented, categories: [], account: self.account, onCreate: {
                    print("Account Details",$0)
                    print("Account", $1)
                    self.getTransactions()
                })
            }
            
        }
    }
    
    fileprivate func getTransactions() {
        self.store.loading = true
        guard let interval = Calendar.current.dateInterval(of: .month, for: Date()) else { return }
        TransactionService().getByAccountAndDates(account: self.account.id, from: interval.start, to: interval.end) { response in
            switch response {
            case .success(let transactions):
                self.transactions = transactions.response
                break;
            case .failure(let error):
                print(error)
                break
            }
            DispatchQueue.main.async {
                self.store.loading = false
            }
        }
    }
    
    var body: some View {
//        VStack {
            
//            Section {
//                AccountCard(account: self.account)
//            }
//            HStack(alignment: .firstTextBaseline) {
//                Text("Transactions")
//                    .font(.title)
//                    .fontWeight(.black)
//                    .foregroundColor(Color("secondary-text"))
//                    .padding(.top)
//                    .padding(.leading)
//                    .padding(.trailing)
//                    .padding(.bottom, 2)
//                Spacer()
//                Button(action: {
//                    let generator = UIImpactFeedbackGenerator(style: .heavy)
//                    generator.prepare()
//                    generator.impactOccurred()
//                    self.openNewTransactionScreen(with: .automatic)
//                }) {
//                    HStack {
//                        Text("Add")
//                            .foregroundColor(Color("primary-text"))
//                        Image(systemName: "plus")
//                            .foregroundColor(Color("primary-text"))
//                    }
//                    .padding(.leading, 10)
//                    .padding(.trailing, 10)
//                    .padding(.top, 5)
//                    .padding(.bottom, 5)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 15)
//                            .stroke(self.account.currencyId != 0 ? Color("primary-text") : .gray, lineWidth: 2)
//                    )
//                        .contextMenu {
//                            if (self.account.currencyId != 0) {
//                                Button(action: {
//                                    self.openNewTransactionScreen(with: .fullScreen)
//                                }) {
//                                    Text("Full screen")
//                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
//                                }
//                            }
//                    }
//                }
//                .disabled(!(self.account.currencyId != 0))
//                .onAppear{
//                    self.daysToSalary = TransactionService.calculateDayToNextSalary(5)
//                    self.getTransactions()
//
//                }
//            }
//            .padding(.trailing)
//            List {
//                ForEach(self.transactions) { transaction in
//                    TransactionRow(transaction: transaction, account: self.account)
//                }
//                .onDelete(perform: { offset in
//                    self.transactions.remove(atOffsets: offset)
//                })
//            }
//        }
        CardsRoundedView(transactions: self.transactions, account: self.account)
        .onAppear{
                            self.daysToSalary = TransactionService.calculateDayToNextSalary(5)
                            self.getTransactions()
        
                        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
