//
//  Account.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation
import SwiftUI

struct Account: Codable, Hashable, Identifiable {
    var id: Int
    var name: String
    var amount: Double
    var currencyId: Int
    var currency: Currency
}
