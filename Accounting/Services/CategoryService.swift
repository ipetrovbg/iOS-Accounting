//
//  CategoryService.swift
//  Accounting
//
//  Created by Petar Petrov on 9.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

public class CategoryService {
    var url: String = "https://ancient-fjord-87958.herokuapp.com/api/v1/transaction-category"
    
    func getCategories<CategoryResponse: Codable>(withToken token: String, completion: @escaping(Result<CategoryResponse, APIError>) -> ()) {
        let url = URL(string: self.url)
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
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(APIError.apiError))
                }
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<399 ~= statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.unauthorize))
                }
                return
            }
            
            guard let _ = response, let _ = data else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.apiError))
                }
                return
            }
            
            do {
                let values = try JSONDecoder().decode(CategoryResponse.self, from: data!)
                DispatchQueue.main.async {
                    completion(Result.success(values))
                }
            } catch _ {
                DispatchQueue.main.async {
                    completion(.failure(.decodeError))
                }
            }
            
        }.resume()
    }
}
