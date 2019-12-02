//
//  AccountService.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public class AccountService {
    
    public enum APIServiceError: Error {
        case unauthorize
        case apiError
        case invalidEndpoint
        case invalidResponse
        case noData
        case decodeError
        case success
    }
    
    func getAccounts(token: String, completion: @escaping([Account], APIServiceError) -> ()) {
       let url = URL(string: "https://ancient-fjord-87958.herokuapp.com/api/v1/account")
              let parameters = ["token": token]
              let session = URLSession.shared
              var request = URLRequest(url: url!)
              
              request.httpMethod = "POST" //set http method as POST
              do {
                  request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
              } catch _ {
                  print("No Data")
              }
              
              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
              request.addValue("application/json", forHTTPHeaderField: "Accept")
        
            session.dataTask(with: request) { data, response, error in
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<399 ~= statusCode else {
                print("Unauthorized")
                DispatchQueue.main.async {
                    completion([], APIServiceError.unauthorize)
                }
                return
            }
            
            if (error != nil) {
                DispatchQueue.main.async {
                    completion([], APIServiceError.apiError)
                }
                return
            }
            
            do {
                if let data = data {
                    
                    let response = try JSONDecoder().decode(AccountResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(response.response, APIServiceError.success)
                    }
                    
                }
            } catch _ {
                DispatchQueue.main.async {
                    completion([], APIServiceError.noData)
                }
            }

            
        }.resume()
    }
}
