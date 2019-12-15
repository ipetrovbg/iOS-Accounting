//
//  NewTransactionModal.swift
//  Accounting
//
//  Created by Petar Petrov on 5.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct NewTransactionModal: View {
    @Environment(\.viewController) private var viewControllerHolder
    
    @Binding var isPresented: Bool
    @State var isCategoryPresented: Bool = false
    @State var categories: [Category] = [.init(id: 0, category: "Select Category")]
    @State var filteredCategories: [Category] = []
    @State var categoryIndex: Int = 0;
    @State var account: Account = Account(id: 0, name: "", amount: 0, currencyId: 0, currency: .init(id: 0, sign: "", currency: "", country: ""))
    @State var category: Category = Category(id: 0, category: "Select Category")
    @State var amount: String = ""
    @State var comment: String = ""
    @State var date: Date = Date()
    @State var type: Int = 0
    @State var categorySearch: String = ""
    var onCreate: (Category, Account) -> ()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Text("\(account.name)")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .lineLimit(5)
                    }
                    Spacer()
                    HStack {
                        Text(String(format: "%.2f", account.amount))
                            .lineLimit(5)
                        Text(account.currency.sign)
                            .font(.system(size: 10))
                        .lineLimit(5)
                    }
                }.padding()
                Form {
                    Section(header: Text("Select transaction date:")) {
                        DatePicker(selection: $date, displayedComponents: .date) {
                            Text("Date")
                        }
                    }
                    Section(header: Text("Select transaction category:")) {
                        NavigationLink(destination: CategoryPickerView(categories: self.categories, category: self.category, onSelect: { cat in
                            self.category = cat
                        })) {
                            Text(self.category.category)
                        }
                    }
                    Section(header: Text("Select transaction type:")) {
                        Picker(selection: $type, label: Text("Type")) {
                            Text("Withdrawal")
                                .tag(0)
                            Text("Deposit")
                                .tag(1)
                        }
                    }
                    Section(header: Text("Transaction amount in \(self.account.currency.sign):")) {
                        TextField("Amount", text: $amount)
                        .keyboardType(.numbersAndPunctuation)
                    }
                    
                    Section(header: Text("Transaction note:")) {
                        TextField("Note", text: $comment)
                        .keyboardType(.asciiCapable)
                        .lineLimit(nil)
                    }
                    
                }
            }
            .navigationBarTitle("New Transaction", displayMode: .inline)
            .navigationBarItems(leading: HStack {
                Button(action: {
                    self.isPresented.toggle()
                    self.viewControllerHolder?.dismiss(animated: true)
                }) {
                    Image(systemName: "xmark")
                }.padding(.init(top: 16, leading: 0, bottom: 16, trailing: 16))
                }, trailing: HStack {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        let defaults = UserDefaults.standard
                        if let id = defaults.string(forKey: "id") {
                            if !id.isEmpty {
                                let transaction: Transaction = .init(comment: self.comment, simulation: true, date: String("\(self.date)"), id: nil, amount: Double(self.amount), originalAmount: Double(self.amount), currencyId: self.account.currency.id, userId: Int(id)!, type: self.type == 0 ? "withdrawal": "deposit", accountId: self.account.id, category: self.category, createdAt: "\(Date())")
                                TransactionService()
                                    .createTransaction(transaction: transaction) { created, _ in
                                        if created {
                                           
                                            DispatchQueue.main.async {
                                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                                generator.prepare()
                                                generator.impactOccurred()
                                                self.isPresented.toggle()
                                                self.viewControllerHolder?.dismiss(animated: true)
                                                self.onCreate(self.category, self.account)
                                            }
                                        }
                                }
                            }
                        }
                    }) {
                        HStack {
                            Text("Add")
                            Image(systemName: "plus")
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                        
                    }
            })
            
        }
        .onAppear {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                self.viewControllerHolder?.modalPresentationStyle = .fullScreen
            }
            let defaults = UserDefaults.standard
            if let token = defaults.string(forKey: "token") {
                CategoryService().getCategories(withToken: token) { (result: Result<CategoryResponse, APIError>) in
                    switch result {
                    case .success(let categories):
                        self.categories = categories.results!
                        self.category = categories.results![0]
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}

//struct NewTransactionModal_Previews: PreviewProvider {
//    static var previews: some View {
//        @State var isPresented: Bool = true
//        NewTransactionModal(isPresented: isPresented)
//    }
//}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
        }
    }
}
