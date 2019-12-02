//
//  Category.swift
//  Accounting
//
//  Created by Petar Petrov on 9.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation
import Combine

struct Category: Codable, Identifiable {
    var id: Int
    var category: String
}
struct CategoryResponse: Codable {
    var results: [Category]?
}
