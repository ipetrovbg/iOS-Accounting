//
//  LoginView.swift
//  Accounting
//
//  Created by Petar Petrov on 2.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @State var user: UserModel = UserModel(email: "", password: "")
    @EnvironmentObject var store: Store
    
    @ObservedObject var accountModel = AccountViewModel()
    @Binding var isPresented: Bool
    @State var error: Bool = false
    @State var biometrics: Bool = false
    @State var showBimetricsConfirmAlert: Bool = false
    @State var loginWithBiometrics: Bool = false;
    var didLogin: (Bool) -> ()
    
    var body: some View {
        LoadingView(isShowing: .constant(self.store.loading)) {
            NavigationView {
                KeyboardHost{
                    VStack() {
                        Form() {
                            Section {
                                if self.error {
                                    
                                    Text("Incorrect Email or Password. Try again")
                                    
                                }
                            }
                            
                            Section {
                                TextField("Email", text: self.$user.email)
                                    .keyboardType(.emailAddress)
                                SecureField("Password", text: self.$user.password)
                            }
                        }
    //                    .onAppear(perform: self.authentication)
                        
                        VStack {
                            if self.biometrics {
                                Button(action: {
                                    self.authentication()
                                }) {
                                    Image(systemName: "faceid")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(self.biometrics ? Color.blue : Color.gray)
                                }
                            }
                           
                            
                            HStack {
                                Button(action: {
                                    self.doLogin()
                                    
                                }) {
                                    Spacer()
                                    Text("Log in")
                                        .fontWeight(.bold)
                                    Spacer()
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                                .actionSheet(isPresented: self.$showBimetricsConfirmAlert) {
                                    ActionSheet(
                                        title: Text("Confirmation"),
                                        message: Text("Do you want to use FaceID/TouchID to LogIn?"),
                                        buttons: [
                                            .default(Text("OK")) {
                                                let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                                                defaults.set(self.user.email, forKey: "email")
                                                defaults.set(self.user.password, forKey: "password")

                                                self.error = false
                                                self.accountModel.isLogged = true
                                                self.isPresented = false
                                                self.didLogin(true)
                                            },
                                            .cancel {
                                                self.error = false
                                                self.accountModel.isLogged = true
                                                self.isPresented = false
                                                self.didLogin(true)
                                            }
                                        ]
                                    )
                                }
                            }
                            .padding()
                        }.onAppear(perform: self.haveBiometrics)
                    }.navigationBarTitle("Log in")
                }
                
            }
        }
    }
    
    func doLogin() {
        self.store.loading.toggle()
        LoginService().doLogin(user: self.user) { (err, user) in
            if (err) {
                withAnimation {
                    self.error = err
                    self.store.loading.toggle()
                }
                return
            }
            
            if self.biometrics && self.loginWithBiometrics == false {
                self.error = false
                 self.user = user
                self.showBimetricsConfirmAlert.toggle()
            } else {
                self.error = false
                self.user = user
                self.accountModel.isLogged = true
                self.isPresented = false
                
                self.didLogin(true)
            }
            self.store.loading.toggle()
            
        }
    }
    
    func haveBiometrics() {
        let context = LAContext()
        var error: NSError?
        
         if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.biometrics = true
         } else {
            self.biometrics = false
        }
    }
    
    func authentication() {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "We need to unlock your data"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                if success {
                    
                    let defaults = UserDefaults(suiteName: "group.com.Accounting.Watch.app.defaults")!
                    
                    if let email = defaults.string(forKey: "email") {
                        self.loginWithBiometrics = true
                        
                        if let password = defaults.string(forKey: "password") {
                            self.user = UserModel(email: email, password: password)
                            self.doLogin()
                        }
                        
                    }
                    
                    
                } else {
                    print("not authenticated")
                }
            }
        } else {
            self.loginWithBiometrics = false
            print("no biometrics")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(user: UserModel(email: "", password: ""), isPresented: .constant(true), didLogin: { login in
            
        })
    }
}
