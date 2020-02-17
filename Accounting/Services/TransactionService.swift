//
//  TransactionService.swift
//  Accounting
//
//  Created by Petar Petrov on 10.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

struct TransactionObj: Encodable, Decodable {
    let transaction: Transaction
    let token: String
}

class TransactionService {
    private var token: String = ""
    private var id: Int = 0
    private var createUrl: String = "https://ancient-fjord-87958.herokuapp.com/api/v1/transaction/create"
    
    init() {
        let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
        if let token = defaults.string(forKey: "token") {
            self.token = token
        }
        if let id = defaults.string(forKey: "id") {
            self.id = Int(id)!
        }
    }
    
    func createTransaction(transaction: Transaction, completion: @escaping (Bool, String) -> Void) {
        let url = URL(string: self.createUrl)!
        let parameters = TransactionObj(transaction: transaction, token: self.token)
        do {
            let params = try JSONEncoder().encode(parameters)
            
            let session = URLSession.shared
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.httpBody = params
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            session.dataTask(with: request) { data, response, error  in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(false, "Unauthorized")
                    return
                }
                
                if error != nil {
                    completion(false, "Error")
                    return
                }
                completion(true, "")
            }.resume()
            
        } catch _ {}
    }
    
    func getByAccountAndDates(account: Int, from: Date, to: Date, completion: @escaping (Result<TransactionResponse, APIError>) -> Void) {
        let url = URL(string: "https://ancient-fjord-87958.herokuapp.com/api/v1/transaction")!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromStr: String = formatter.string(from: from)
        let toStr: String = formatter.string(from: to)
        let parameters = ["from": fromStr, "to": toStr, "account": account, "token": self.token] as [String : Any]
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch _ {
            print("No Data")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { data, response, error in
           guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let values = try JSONDecoder().decode(TransactionResponse.self, from: data)
                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                defaults.set(values.token.token, forKey: "token")
                defaults.set(values.token.userId, forKey: "id")
                defaults.synchronize()
                completion(.success(values))
            } catch let e {
                print(e.localizedDescription)
                completion(.failure(.decodeError))
            }
        }.resume()
    }
    
    static func calculateDayToNextSalary(_ dayToNextSalary: Int = 5) -> Int {
//        let payDay = dayToNextSalary
//        let calendar = Calendar.current
//        let currentDay = calendar.component(.day, from: Date())
//        let currentYear = calendar.component(.year, from: Date())
//        let currentMonth = calendar.component(.month, from: Date())
//        let inThisMonth = Calendar.current.dateInterval(of: .month, for: Date())
//        let endDayOfMonth = Calendar.current.component(.day, from: inThisMonth!.end - 1)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        let payDayDate = formatter.date(from: "\(currentYear)/\(currentMonth)/\(payDay)")
//        let dayDiff = Calendar.current.dateComponents([.day], from: payDayDate!, to: Date())
        let current = Date()
        
        let payDay = dayToNextSalary
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: current)
        let currentYear = calendar.component(.year, from: current)
        let currentMonth = calendar.component(.month, from: current)
        let inThisMonth = Calendar.current.dateInterval(of: .month, for: current)
        let endDayOfMonth = Calendar.current.component(.day, from: inThisMonth!.end - 1)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let payDayDate = formatter.date(from: "\(currentYear)/\(currentMonth)/\(payDay)")

        let dayDiff = Calendar.current.dateComponents([.day], from: current, to: payDayDate!)
//        if payDay > currentDay {
//            return dayDiff.day!
//        } else {
//            return (endDayOfMonth - currentDay) + payDay
//        }

        return abs(payDay > currentDay ? dayDiff.day! : (endDayOfMonth - currentDay) + payDay)
    }
}
