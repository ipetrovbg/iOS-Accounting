//
//  Currency.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//


import Foundation
import SwiftUI

struct Currency: Codable, Hashable, Identifiable {
    var id: Int
    var sign: String
    var currency: String
    var country: String
}
