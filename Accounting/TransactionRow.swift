//
//  TransactionRow.swift
//  Accounting
//
//  Created by Petar Petrov on 14.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import Foundation

extension String {
  func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    guard let date = dateFormatter.date(from: self) else {
      preconditionFailure("Take a look to your format")
    }
    return date
  }
}

struct TransactionRow: View {
    public var transaction: Transaction
    public var account: Account
    static let stringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        HStack {
//            ZStack {
//                Rectangle()
////                    .fill(LinearGradient(
////                        gradient: .init(colors: [.red, .blue]),
////                        startPoint: .init(x: 0.5, y: 0),
////                        endPoint: .init(x: 0.5, y: 0.5)
////                    ))
//                    .foregroundColor(.clear)
//                    .background(LinearGradient(gradient:  Gradient(colors: [Color("second"), Color("first")]), startPoint: .top, endPoint: .bottom))
//                    .frame(width: 50, height: 50)
//                    .clipShape(RoundedRectangle(cornerRadius: 3))
//                Image(systemName: "dollarsign.circle")
//                .resizable()
//                .frame(width: 25, height: 25)
//                .foregroundColor(.white)
//            }
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(self.transaction.comment ?? "")
                        .lineLimit(1)
                            .padding(.bottom, 5)
                        Text(self.transaction.category?.category ?? "")
                            .font(.system(size: 10))
                        
                    }
                }
            }
            
            Spacer()
            
            HStack {
                VStack {
                    HStack {
                        transaction.type == "deposit" ? Text("+").foregroundColor(.green) : Text("-").foregroundColor(.red)
                        
                        Text(String(format: "%.2f", self.transaction.amount))
                            .fontWeight(.bold)
                            .foregroundColor(transaction.type == "deposit" ? .green : .red)
                        Text(self.account.currency.sign)
                            .font(.system(size: 10))
                    }
                    .padding(.bottom, 5)
                    HStack {
                        Text("\(self.transaction.createdAt.toDate(), formatter: TransactionRow.stringFormatter)")
                            .font(.system(size: 10))
                    }
                }
                
            }
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction(comment: "Some comment", simulation: true, date: "23/09/2019", id: 6, amount: 45, originalAmount: 45, currencyId: 5, userId: 7, type: "withdrawal", accountId: 5, category: Category(id: 9, category: "Food"), createdAt: "23/04/2019"), account: Account(id: 9, name: "Main", amount: 78, currencyId: 4, currency: Currency(id: 9, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")))
    }
}
