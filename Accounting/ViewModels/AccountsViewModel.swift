//
//  AccountsViewModel.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//
import Foundation
import Combine
import SwiftUI

class AccountViewModel: ObservableObject {
    let didChange = PassthroughSubject<Any, Never>()
    
    @Published var accounts = [Account]() {
        didSet {
            self.didChange.send(self)
        }
    }
    @Published var error = "" {
        didSet {
            self.didChange.send(self)
        }
    }
    
    @Published var isLogged = true {
        didSet {
            self.didChange.send(self)
        }
    }
    
    public func fetchAccounts(token: String, completion: @escaping () -> Void) {
         AccountService().getAccounts(token: token) { response, error in
                if (error == AccountService.APIServiceError.success) {
                    self.accounts = response;
                    self.error = ""
                    self.isLogged = true
                }
                if (error == AccountService.APIServiceError.unauthorize) {
                    self.error = "Access Error"
                    self.isLogged = false
                }
            
        }
        
    }
    

}
