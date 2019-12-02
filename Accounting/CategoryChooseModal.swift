//
//  CategoryChooseModal.swift
//  Accounting
//
//  Created by Petar Petrov on 5.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct CategoryChooseModal: View {
    
    @Binding var isPresented: Bool
    @State var categoryIndex: Int = 0
    @State var categories: [Category] = []
    var onSelect: (Int) -> ()
    var body: some View {
        NavigationView {
            VStack {
               Spacer()
               HStack(alignment: .center) {
                   Spacer()
                   Picker(selection: self.$categoryIndex, label: Text("")) {
                           ForEach(0..<self.categories.count) {
                            Text(self.categories[$0].category)
                           }
                   }.pickerStyle(WheelPickerStyle())
                   Spacer()
               }
               Spacer()
               Button(action: {
                   self.isPresented = false
                   self.onSelect(self.categoryIndex)
               }) {
                   Text("Select")
               }
            }.padding(.all, 50)
                .navigationBarTitle("\(self.categories[self.categoryIndex].category)", displayMode: .inline)
        }
    }
}
