//
//  Store.swift
//  Accounting
//
//  Created by Petar Petrov on 16.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
//import SocketIO

class Store: ObservableObject {
    
    @Published var loading: Bool = true
    @Published var payDay: Int = 5
    @Published var mainScreen: Int? = nil
    @Published var accounts: [Account] = [
//        Account(id: 0, name: "VISA", amount: 85.45, currencyId: 2, currency: Currency(id: 2, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")),
//        Account(id: 1, name: "Main", amount: 5.45, currencyId: 2, currency: Currency(id: 2, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria")),
//        Account(id: 2, name: "Revolut", amount: 5.45, currencyId: 2, currency: Currency(id: 2, sign: "BGN", currency: "Bulgarian Lev", country: "Bulgaria"))
    ]
    @Published var categories: [Category] = []
    @Published var name: String = "Petar Petrov"
    @Published var id: Int = 0
    @Published var token: String = "fff"
    
    var accountService: AccountService = AccountService()
    var categoryService: CategoryService = CategoryService()
    public var transactionService: TransactionService = TransactionService()
    
    func createTransaction(transaction: Transaction) {
        self.transactionService
            .createTransaction(transaction: transaction) { created, _ in
                if created {
                    self.getAccounts()
                }
        }
    }
    
    func getCategories() {
        self.categoryService.getCategories(withToken: self.token) { (result: Result<CategoryResponse, APIError>) in
            switch result {
            case .success(let categories):
                self.categories = categories.results!
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getAccounts() {
        self.loading = true
        self.accountService.getAccounts(token: self.token) { accounts, error in
            if (error == .success) {
                self.accounts = accounts
            }
            self.loading = false
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")
        defaults?.set("", forKey: "name")
        defaults?.set("", forKey: "token")
        self.token = ""
        self.name = ""
        self.id = 0
        self.accounts = []
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        print("Ok")
    }
}
