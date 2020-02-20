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
    @EnvironmentObject var store: Store
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
        LoadingView(isShowing: .constant(store.loading)) {
            NavigationView {
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            Text("\(self.account.name)")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.black)
                                .lineLimit(5)
                        }
                        Spacer()
                        HStack {
                            Text(String(format: "%.2f", self.account.amount))
                                .lineLimit(5)
                            Text(self.account.currency.sign)
                                .font(.system(size: 10))
                            .lineLimit(5)
                        }
                    }.padding()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: self.onTapHabdle)
                    GeometryReader { geo in
                        Form {
                            Section(header: Text("Select transaction date:").onTapGesture(perform: self.onTapHabdle)) {
                                DatePicker(selection: self.$date, displayedComponents: .date) {
                                    Text("Date")
                                }
                            }
                            Section(header: Text("Select transaction category:").onTapGesture(perform: self.onTapHabdle)) {
                                NavigationLink(destination: CategoryPickerView(categories: self.categories, category: self.category, onSelect: { cat in
                                    self.category = cat
                                    UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                                })) {
                                    Text(self.category.category)
                                }
                            }
                            Section(header: Text("Select transaction type:").onTapGesture(perform: self.onTapHabdle)) {
                                Picker(selection: self.$type, label: Text("Type")) {
                                    Text("Withdrawal")
                                        .tag(0)
                                    Text("Deposit")
                                        .tag(1)
                                }.pickerStyle(SegmentedPickerStyle())
                            }
                            Section(header: Text("Transaction amount in \(self.account.currency.sign):").onTapGesture(perform: self.onTapHabdle)) {
                                TextField("Amount", text: self.$amount)
                                .keyboardType(.decimalPad)
                            }
                            
                            Section(header: Text("Transaction note:").onTapGesture(perform: self.onTapHabdle)) {
                                TextField("Note", text: self.$comment)
                                .keyboardType(.asciiCapable)
                                .lineLimit(nil)
                            }
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
                            
                            let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                            if let id = defaults.string(forKey: "id") {
                                if !id.isEmpty {
                                    self.store.loading.toggle()
                                    let ammountFormatter = NumberFormatter()
                                    let number = ammountFormatter.number(from: self.amount)

                                    let transaction: Transaction = .init(comment: self.comment, simulation: true, date: String("\(self.date)"), id: nil, amount: Double(number?.doubleValue ?? 0), originalAmount: Double(number?.doubleValue ?? 0), currencyId: self.account.currency.id, userId: Int(id)!, type: self.type == 0 ? "withdrawal": "deposit", accountId: self.account.id, category: self.category, createdAt: "\(Date())", DeviceToken: "")
                                    TransactionService()
                                        .createTransaction(transaction: transaction) { created, _ in
                                            if created {
                                               
                                                DispatchQueue.main.async {
                                                    WatchManager.shared.sendParamsToWatch(dict: [
                                                        "force_send": UUID().uuidString,
                                                        "type": "accounts"
                                                    ])
                                                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                                                    generator.prepare()
                                                    generator.impactOccurred()
                                                    self.isPresented.toggle()
                                                    self.viewControllerHolder?.dismiss(animated: true)
                                                    self.onCreate(self.category, self.account)
                                                }
                                            }
                                            self.store.loading.toggle()
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
                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
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
    fileprivate func onTapHabdle() {
        UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
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
