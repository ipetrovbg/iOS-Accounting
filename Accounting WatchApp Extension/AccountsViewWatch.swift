//
//  AccountsViewWatch.swift
//  Accounting WatchApp Extension
//
//  Created by Petar Petrov on 6.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct AccountsViewWatch: View {
    let isLogged: Bool
    @EnvironmentObject var store: Store
    
    var body: some View {
        if isLogged {
            return
                AnyView(
                            List(self.store.accounts) { account in
                                NavigationLink(destination: AccountDetails(account: account).environmentObject(self.store)) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Spacer()
                                        Text("\(account.currency.sign)")
                                            .font(.system(size: 10))
                                    }
                                    Text(account.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .lineLimit(3)
                                    Text(String(format: "%.2f", account.amount))
                                        .foregroundColor(account.amount > 0 ? .green : .red )
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                }
                                .frame(maxHeight: 150)
                                .padding()
                                }
                            }
                            .listStyle(CarouselListStyle()))
            
        } else {
            return AnyView(Text("Unauthorize"))
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsViewWatch(isLogged: true)
        .environmentObject(Store())
    }
}
