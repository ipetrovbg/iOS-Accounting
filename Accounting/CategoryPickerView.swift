//
//  CategoryPickerView.swift
//  Accounting
//
//  Created by Petar Petrov on 25.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var categories: [Category] = []
    @State var search: String = ""
    @State var category: Category
     var onSelect: (Category) -> ()
    
    var body: some View {
        VStack {
           HStack {
                TextField("Search", text: self.$search)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }.padding()
            Divider()
            
            List(self.categories.filter {
                if self.search.isEmpty {
                    return true
                }
                return ($0.category.range(of: self.search, options: .caseInsensitive) != nil)
            }, id: \.id) { cat in
                HStack {
                    Text(cat.category)
                    Spacer()
                    if self.category.id == cat.id {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .scaledToFit()
                            .foregroundColor(.blue)
                    }
                }
                .padding([.top, .bottom], 10)
                .gesture(TapGesture().onEnded({
                    self.category = cat
                    self.onSelect(cat)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }))
            }
        }
    }
}

//struct CategoryPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryPickerView(categories: [
//            Category(id: 9, category: "Food"),
//            Category(id: 8, category: "Salary"),
//            Category(id: 2, category: "Entertainment"),
//            Category(id: 3, category: "Bills"),
//            Category(id: 44, category: "Unknown"),
//            Category(id: 32, category: "Abonaments"),
//            Category(id: 7, category: "Clothes"),
//            Category(id: 5, category: "Tech")
//        ], category: Category(id: 9, category: "Food"), onSelect: {_ in })
//    }
//}
