//
//  Store.swift
//  Accounting
//
//  Created by Petar Petrov on 16.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

class Store: ObservableObject {
    @Published var loading: Bool = false
    @Published var payDay: Int = 5
}
