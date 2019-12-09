//
//  ContentView.swift
//  Accounting
//
//  Created by Petar Petrov on 1.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    @State private var selection: String = "Accounts"
//    @EnvironmentObject var store: Store
    var body: some View {
       TabView(selection: $selection) {
            AccountView()
                .tabItem {
                    Text("Accounts")
            }.tag("Accounts")
            
             BudgetView()
                .tabItem {
                   Text("Budgets")
            }.tag("Budgets")
            
            SettingsView()
                .tabItem{
                    Text("Settings")
            }.tag("Settings")
            
       }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue:  ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        self.present(toPresent, animated: true, completion: nil)
    }
}
