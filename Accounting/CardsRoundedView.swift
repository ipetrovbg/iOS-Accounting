//
//  CardsRoundedView.swift
//  Accounting
//
//  Created by Petar Petrov on 27.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct ScrollRow: View {
    var transaction: Transaction
    var account: Account
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.white)
                .shadow(radius: 1, y: 1)
                .frame(width: UIScreen.main.bounds.width - 32, height: 65)
                    
            HStack {
                TransactionRow(transaction: transaction, account: account)
                .padding()
            }
        }
        .padding([.leading, .trailing])
        
        
    }
}

struct Header: View {
    var text: Text
    var minHeight: CGFloat = 200
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                text
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.all, 5)
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1000))
        }
        
    }
}

struct MyText: View {
    var minY: GeometryProxy
    @Binding var scroll: Double
    @Binding var fixed: Bool
    var body: some View {
        self.fixed = Double(self.minY.frame(in: .global).minY) <= 150
        return Text("")
    }
}

struct CardsRoundedView: View {
    @State var fixed: Bool = false
    @State var scroll: Double = 0
    var transactions: [Transaction] = []
    var account: Account
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                AccountCard(
                    account: account, daysToSalary: 5, minHeight: fixed ? 150 : 200, isSmall: self.fixed)
            }.zIndex(2)
            ScrollView {
                GeometryReader { geo in
                    MyText(minY: geo, scroll: self.$scroll, fixed: self.$fixed)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0.1, maxHeight: 0.1)
                .zIndex(1)
                
                ForEach(self.transactions) { transaction in
                    ScrollRow(transaction: transaction, account: self.account)
                }
            }.padding(.bottom)
        }.onAppear {
            self.fixed = false
        }
    }
}

struct CardsRoundedView_Previews: PreviewProvider {
    static var previews: some View {
        CardsRoundedView(transactions: [Transaction(comment: "Some comment", simulation: true, date: "22.3.2019", id: 8, amount: 45.7, originalAmount: 45.7, currencyId: 23, userId: 7, type: "withdrawal", accountId: 8, category: Category(id: 9, category: "Food"), createdAt: "22.3.2019"), Transaction(comment: "Some comment", simulation: true, date: "22.3.2019", id: 9, amount: 45.7, originalAmount: 45.7, currencyId: 23, userId: 7, type: "withdrawal", accountId: 8, category: Category(id: 9, category: "Food"), createdAt: "22.3.2019")], account: Account(id: 9, name: "Main", amount: 45.7, currencyId: 9, currency: Currency(id: 8, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")))
    }
}
