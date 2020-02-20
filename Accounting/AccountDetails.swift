//
//  AccountDetails.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import UIKit

struct AccountDetails: View {
    var account: Account
    @State var isAddPresented: Bool = false
    @State var fullScreen: Bool = false
    @Environment(\.viewController) private var viewControllerHolder
    @State var transactions = [Transaction]()
    @State var daysToSalary: Int = 0
    @EnvironmentObject var store: Store
    @State var scroll: Double = 0;
    @State var fixed: Bool = false
    @State private var clearShow: Bool = false
    @State private var shouldFocus: Bool = false
    @State private var isFocused: Bool = false
    
    @State var filterToggle: Bool = false
    var interval = Calendar.current.dateInterval(of: .month, for: Date())
    var blurAmount: CGFloat = 2
    @State var from: Date = Date()
    @State var to: Date = Date()
    @State private var search: String = ""
    @State private var input: UITextField = UITextField()
    @State private var showSearchFilter: Bool = false
    @State private var showAccount: Bool = false
    
    fileprivate func openNewTransactionScreen(with style: UIModalPresentationStyle) {
        self.viewControllerHolder?.present(style: style) {
            KeyboardHost {
                NewTransactionModal(isPresented: self.$isAddPresented, categories: [], account: self.account, onCreate: { a, b in
                    self.getTransactions()
                }).environmentObject(self.store)
            }
            
        }
    }
    
    fileprivate func getTransactions() {
        self.store.loading.toggle()
        TransactionService().getByAccountAndDates(account: self.account.id, from: from, to: to) { response in
            switch response {
            case .success(let transactions):
                self.transactions = transactions.response
//                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
//                WatchManager.shared.sendParamsToWatch(dict: [
//                    "force_send": UUID().uuidString,
//                    "type": "auth",
//                    "name": defaults.string(forKey: "name") ?? "",
//                    "token": transactions.token.token,
//                    "id": transactions.token.userId
//                ])
                break;
            case .failure(let error):
                print(error)
                break
            }
            DispatchQueue.main.async {
                self.store.loading.toggle()
            }
        }
    }
    
    var body: some View {
        VStack {
            if self.showAccount {
                Section {
                    AccountCard(account: self.account)
                    .gesture(
                        DragGesture()
                            .onEnded({ value in
                                if value.translation.height < 5 {
                                    withAnimation {
                                        self.showAccount = false
                                    }
                                }
                            })
                    )
                    .blur(radius: self.filterToggle ? blurAmount : 0)
                }
            } else {
                HStack {
                    Text(self.account.name)
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(Color("primary"))
                    Spacer()
                    Text(String(format: "%.2f", account.amount))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Text("\(account.currency.sign)")
                        .font(.system(size: 10))
                }
                .padding([.top, .leading, .trailing])
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded({ value in
                            if value.translation.height > 20 {
                                withAnimation {
                                    self.showAccount = true
                                }
                            }
                        })
                )
            }
            
            
            HStack(alignment: .center) {
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                    self.filterToggle.toggle()
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                }) {
                 Image(systemName: "line.horizontal.3.decrease.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                     .foregroundColor(Color("primary-text"))
                }
                .padding()
                Spacer()
                HStack {
                    Text("Transactions")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(Color("secondary-text"))
                        .layoutPriority(1)
                        .onTapGesture {
                            withAnimation {
                                self.closeFilter()
                            }
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.prepare()
                        generator.impactOccurred()
                        self.openNewTransactionScreen(with: .automatic)
                        UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                    }) {
                        HStack {
                            Text("Add")
                                .foregroundColor(Color("primary-text"))
                            Image(systemName: "plus")
                                .foregroundColor(Color("primary-text"))
                        }
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(self.account.currencyId != 0 ? Color("primary-text") : .gray, lineWidth: 2)
                        )
                            .contextMenu {
                                if (self.account.currencyId != 0) {
                                    Button(action: {
                                        self.openNewTransactionScreen(with: .fullScreen)
                                    }) {
                                        Text("Full screen")
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    }
                                    Button(action: {}) {
                                        Text("New transfer")
                                        Image(systemName: "dollarsign.square")
                                    }
                                }
                        }
                    }
                    .disabled(!(self.account.currencyId != 0))
                    .onAppear{
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        if (defaults.object(forKey: "from") != nil && defaults.object(forKey: "to") != nil) {
                            self.from = defaults.object(forKey: "from") as! Date
                            self.to = defaults.object(forKey: "to") as! Date
                        } else {
                            let interval = Calendar.current.dateInterval(of: .month, for: Date())
                            self.from  = interval?.start ?? Date()
                            self.to = interval?.end ?? Date()
                        }
                       
                        self.daysToSalary = TransactionService.calculateDayToNextSalary(5)
                        self.getTransactions()
                    }
                }
            }
            .padding(.trailing)
            .blur(radius: self.filterToggle ? blurAmount : 0)
            if self.showSearchFilter {
                HStack {
                    
                    ResponderTextField(text: $search, placeholder: "Search Transactions...", shouldFocus: self.$shouldFocus, onFocus: {
                        withAnimation {
                            self.clearShow = true
                        }
                        self.isFocused = true
                    }, onFinishEditing: {
                        withAnimation {
                            self.isFocused = true
                        }
                    }) { textView in
                        textView.textContainer.maximumNumberOfLines = 1
                        textView.layer.cornerRadius=8.0
                        textView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
                        textView.frame.size.height = 50
                        textView.font = UIFont.systemFont(ofSize: 18.0)
                    }
                    .padding()
                    if !self.search.isEmpty || self.clearShow {
                        if !self.search.isEmpty {
                            Button(action: {
                                self.search = ""
                                self.isFocused = false
                                self.shouldFocus = true
                                
                            }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .padding()
                            .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            withAnimation {
                                self.closeFilter()
                            }
                        }) {
                            Text("Cancel")
                                .foregroundColor(Color("primary"))
                        }
                    }
                    
                }
                .frame(height: 70)
                .gesture(
                    DragGesture()
                        .onEnded({ gesture in
                            if gesture.translation.height > 20 {
                                UIApplication.shared.sendAction(#selector(UIView.endEditing(_:)), to:nil, from:nil, for:nil)
                                self.isFocused = false
                            }
                        })
                )
                    .padding(.trailing)
            }
           
            

                List {
                    
                    ForEach(self.transactions.filter {
                        if self.search.isEmpty {
                            return true
                        }
                        if $0.category?.category.range(of: self.search, options: .caseInsensitive) != nil {
                            return true
                        }
                        return ($0.comment?.range(of: self.search, options: .caseInsensitive) != nil)
                    }) { transaction in
                            TransactionRow(transaction: transaction, account: self.account)
                                .frame(height: 50)
                        }
                        .onDelete(perform: { offset in
                            self.transactions.remove(atOffsets: offset)
                        })
                }
                .blur(radius: self.filterToggle ? self.blurAmount : 0)
                .overlay(
                    PopupPicker(toggle: self.$filterToggle,
                                view: AnyView(FilterView(from: self.$from, to: self.$to, onDone: { (from, to) in
                        self.from = from
                        self.to = to
                        self.filterToggle.toggle()
                        self.getTransactions()
                        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                        defaults.set(from, forKey: "from")
                        defaults.set(to, forKey: "to")
                        defaults.synchronize()
                                    if self.isFocused {
                                        self.shouldFocus.toggle()
                                        self.isFocused = false
                                    }
                        
                                    
                                })), onDismiss: {
                                    if self.isFocused {
                                        self.shouldFocus.toggle()
                                        self.isFocused = false
                                    }
                                    
                    })
                )
            
        }
        .navigationBarTitle("", displayMode: .inline)
    }
    
    fileprivate func closeFilter() {
        self.showSearchFilter.toggle()
        if !self.showSearchFilter {
            self.search = ""
        } else {
            self.shouldFocus = true
        }
    }
}
struct ResponderTextField: UIViewRepresentable {
    typealias TheUIView = UITextView
    @Binding var text: String
    var placeholder: String = "Placeholder..."
    @Binding var shouldFocus: Bool
    var onFocus: (() -> Void)? = nil
    var onFinishEditing: (() -> Void)? = nil
    
    func makeCoordinator() -> ResponderTextField.Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ResponderTextField
        init(_ parent: ResponderTextField) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.textColor == .placeholderText && textView.text.contains(self.parent.placeholder) {
                textView.textColor = .label
                textView.text = textView.text.replacingOccurrences(of: self.parent.placeholder, with: "", options: [.caseInsensitive, .regularExpression])
            }
            self.parent.text = textView.text
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            textView.isUserInteractionEnabled = true
            if textView.text == "" {
                textView.text = self.parent.placeholder
                textView.textColor = .placeholderText
            }
            self.parent.shouldFocus = false
            if self.parent.onFinishEditing != nil {
                self.parent.onFinishEditing!()
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
            if self.parent.onFocus != nil {
                self.parent.onFocus!()
            }

        }
        
    }

    
    var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView {
        let uiView = TheUIView()
        uiView.text = self.placeholder
        uiView.textColor = .placeholderText
        return uiView;
    }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
        uiView.delegate = context.coordinator
//        if self.text.isEmpty && self.placeholder != nil {
//            uiView.text = self.placeholder
//        } else {
//
//        }
        if self.shouldFocus && uiView.canBecomeFirstResponder {
            uiView.becomeFirstResponder()
        }
//        uiView.enablesReturnKeyAutomatically = true
        
        if !uiView.text.isEmpty && uiView.textColor == .label {
         uiView.text = text
        }
        if self.text.isEmpty && uiView.text.isEmpty {
//            uiView.selectedTextRange = uiView.textRange(from: UITextPosition(), to: UITextPosition())
            
            uiView.text = self.placeholder
            uiView.textColor = .placeholderText
            let arbitraryValue: Int = 0
            if let newPosition = uiView.position(from: uiView.beginningOfDocument, offset: arbitraryValue) {

                uiView.selectedTextRange = uiView.textRange(from: newPosition, to: newPosition)
            }
        }
        
    }
}
