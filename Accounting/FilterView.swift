//
//  FilterView.swift
//  Accounting
//
//  Created by Petar Petrov on 1.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct FilterView: View {
    @Binding var from: Date
    @Binding var to: Date
    var onDone: (Date, Date) -> ()
    
    var body: some View {
        VStack {
            VStack {
                Capsule()
                    .frame(width: 60, height: 7)
                    .offset(y: 10)
                    .foregroundColor(Color("primary"))
                HStack {
                    Text("Transaction Filter")
                        .font(.body)
                        .foregroundColor(Color("secondary-text"))
                     Spacer()
                     Button(action: {
                         self.onDone(self.from, self.to)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                     }) {
                         Text("Done")
                        .foregroundColor(Color("primary-text"))
                     }
                 }
                 .padding()
                 Form {
                    DatePicker("From", selection: $from, displayedComponents: .date)
                    DatePicker("To", selection: $to, displayedComponents: .date)
                }
                Spacer()
            }
        }
       
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(from: .constant(Date()), to:.constant(Date()), onDone: {from, to in })
    }
}
