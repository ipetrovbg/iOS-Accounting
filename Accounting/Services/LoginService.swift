//
//  LoginService.swift
//  Accounting
//
//  Created by Petar Petrov on 2.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import Foundation

class LoginService {
    func doLogin(user: UserModel, completion: @escaping (_ error: Bool, _ user: UserModel) -> Void) {
        let url = URL(string: "https://ancient-fjord-87958.herokuapp.com/api/v1/authenticate")! //change the url
        let parameters = ["email": user.email, "password": user.password]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(true, UserModel(email: "", password: ""))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(true, UserModel(email: "", password: ""))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["success"] as! Int != 0) {
                        if let userJSON = json["user"] as? [String: Any], let email = userJSON["email"] as? String {
                            let defaults = UserDefaults.standard
                            defaults.set(userJSON["id"], forKey: "id")
                            DispatchQueue.main.async {
                                completion(false, UserModel(email: email, password: user.password))
                            }
                        }
                        if let token = json["token"] as? String {
                            let defaults = UserDefaults.standard
                            defaults.set(token, forKey: "token")
                            
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            completion(true, UserModel(email: "", password: ""))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(true, UserModel(email: "", password: ""))
                    }
                }
            }  catch let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(true, UserModel(email: "", password: ""))
                }
            }
        })
        task.resume()
    }
}
