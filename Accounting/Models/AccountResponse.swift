//
//  AccountResponse.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation
import SwiftUI

struct AccountResponse: Codable {
    public var response: [Account]
    public var success: Bool
}
