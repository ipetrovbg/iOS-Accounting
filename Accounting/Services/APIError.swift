//
//  APIError.swift
//  Accounting
//
//  Created by Petar Petrov on 9.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case decodeError
    case unauthorize
}

public enum WatchCommunicationActionTypes {
    case authenticationAction
    case accounts
}
