//
//  BudgetView.swift
//  Accounting
//
//  Created by Petar Petrov on 7.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct BudgetView: View {
    var body: some View {
//        ZStack {
//            VStack {
//                HStack {
//                    Text("Coming soon...")
//                        .font(.largeTitle)
//                        .fontWeight(.black)
//                        .foregroundColor(Color("primary"))
//                }
//            }
//            
//        }
        CardsRoundedView()
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            BudgetView()
        }
    }
}
