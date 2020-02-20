//
//  Transaction.swift
//  Accounting
//
//  Created by Petar Petrov on 10.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

class Token: Codable {
    var token: String
    var refreshToken: String
    var email: String
    var userId: Int
}

class TransactionResponse: Codable {
    var response: [Transaction]
    var success: Bool
    var token: Token
}

class Transaction: Codable, Identifiable {
    var categoryId: Int?
    var transactionId: Int?
    var updatedAt: String?
    var createdAt: String
    var deletedAt: String?
    var comment: String? = ""
    var id: Int?
    var amount: Double
    var originalAmount: Double?
    var currencyId: Int?
    var date: String?
    var simulation: Bool?
    var userId: Int?
    var type: String?
    var accountId: Int?
    var DeviceToken: String?
    var category: Category?
    
    init(comment: String, simulation: Bool?, date: String?, id: Int?, amount: Double?, originalAmount: Double?, currencyId: Int?, userId: Int?, type: String?, accountId: Int?, category: Category?, createdAt: String, DeviceToken: String?) {
        self.comment = comment
        self.simulation = simulation ?? true
        self.date = date
        self.id = (id ?? 0)!
        self.amount = amount ?? 0
        self.originalAmount = originalAmount ?? 0
        self.currencyId = currencyId
        self.userId = userId
        self.type = type ?? "withdrawal"
        self.accountId = accountId ?? nil
        self.category = category
        self.createdAt = createdAt
        self.DeviceToken = DeviceToken
        if DeviceToken == nil {
            self.DeviceToken = ""
        }
        guard category != nil else {
            self.categoryId = 0
            return
        }
        self.categoryId = self.category?.id
        
    }
}
