//
//  AccountCard.swift
//  Accounting
//
//  Created by Petar Petrov on 16.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountCard: View {
    var account: Account
    @EnvironmentObject var store: Store
    @State var daysToSalary: Int = 0
    var minHeight: CGFloat = 200
    var isSmall: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !isSmall {
                HStack {
                    
                    Text("A") .font(Font.custom("Superclarendon-BlackItalic", size: 14))
                        .shadow(color: Color("dark-blue"), radius: 1, x: 1, y: 1)
                    Spacer()
                }
            }
           
            
            HStack() {
                if !isSmall {
                    Text("Name")
                        .font(.system(size: 10))
                        .frame(minWidth: 30)
                    Spacer()
                }
                
                Text("\(account.name)")
                    .fontWeight(.black)
                    .font(.system(size: 50))
                    .lineLimit(1)
                .animation(.interpolatingSpring(mass: 1.0,
                stiffness: 100.0,
                damping: 10,
                initialVelocity: 0))
            }
            HStack() {
                if !isSmall {
                    Text("Amount")
                        .font(.system(size: 10))
                    Spacer()
                }
                
                Text(String(format: "%.2f", account.amount))
                    .fontWeight(.bold)
                    .fixedSize()
                    .font(.title)
                    .lineLimit(1)
                .animation(.interpolatingSpring(mass: 1.0,
                stiffness: 100.0,
                damping: 10,
                initialVelocity: 0))
                
                Text("\(account.currency.sign)")
                .font(.system(size: 10))
            }
            HStack() {
                if !isSmall {
                    Text("Remaining days")
                        .font(.system(size: 10))
                    Spacer()
                    Text("\(daysToSalary) /")
                    Text(String(format: "%.2f", (account.amount / Double(daysToSalary))))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Text("\(account.currency.sign)")
                    .font(.system(size: 10))
                }
                
            }
            if !isSmall {
                HStack(alignment: .top) {
                    Text("**** **** ****")
                        .font(.title)
                        .frame(height: 40)
                    Text(String(format: "%04d", self.account.id))
                        .font(.system(size: 20))
                        .frame(height: 30)
                    Spacer()
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight)
        .padding(.top)
        .padding(.bottom, 0)
        .padding(.leading)
        .padding(.trailing)
        .background(Color("primary"))
        .foregroundColor(Color("black-white-inverted"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding(.all, 5)
        .animation(.interpolatingSpring(mass: 1.0,
        stiffness: 100.0,
        damping: 10,
        initialVelocity: 0))

        .onAppear {
            self.daysToSalary = TransactionService.calculateDayToNextSalary(self.store.payDay)
        }
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        AccountCard(account: Account(id: 9, name: "Revolut VISA", amount: 98.5, currencyId: 0, currency: Currency(id: 0, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")), daysToSalary: 5)
    }
}
