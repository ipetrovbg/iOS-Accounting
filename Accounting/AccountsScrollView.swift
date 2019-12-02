//
//  AccountsScrollView.swift
//  Accounting
//
//  Created by Petar Petrov on 16.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountsScrollView: View {
    var accounts: [Account]
    var body: some View {
        NavigationView {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(self.accounts) { account in
                        GeometryReader { geometry in
                            NavigationLink(destination: AccountDetails(account: account)) {
                                AccountCard(account: account)
                                    .rotation3DEffect(Angle(degrees:
                                        (Double(geometry.frame(in: .global).minX) - 40) / -20
                                    ), axis: (x: 0, y: 10, z: 0))
                            }
                        }
                    }
                    .frame(width: 300, height: 250)
                    .shadow(color: Color("black-transparent"), radius: 15, x: 0, y: 5)
                }
                .padding(40)
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        //        .frame(height: 150)
    }
}

struct AccountsScrollView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsScrollView(accounts: [
            Account(id: 6, name: "Main", amount: 56.90, currencyId: 3, currency: Currency(id: 3, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")),
            Account(id: 1, name: "VISA", amount: 1906.56, currencyId: 9, currency: Currency(id: 9, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")),
            Account(id: 3, name: "MasterCard", amount: 345.89, currencyId: 4, currency: Currency(id: 4, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria"))
        ])
    }
}
