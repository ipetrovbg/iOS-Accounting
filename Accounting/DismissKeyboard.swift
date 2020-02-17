//
//  DismissKeyboard.swift
//  Accounting
//
//  Created by Petar Petrov on 4.01.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//
import Foundation
import SwiftUI
import Combine
import UIKit
  
struct DismissKeyboard: ViewModifier {
      
    @State var currentHeight: CGFloat = 0
  
  
    func body(content: Content) -> some View {
        content
            .padding(.bottom, currentHeight).animation(.easeOut(duration: 0.25))
            .edgesIgnoringSafeArea(currentHeight == 0 ? Edge.Set() : .bottom)
            .onAppear(perform: subscribeToKeyboardChanges)
    }
  
    //MARK: - Keyboard Height
    private let keyboardHeightOnOpening = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
        .map { $0.height }
  
      
    private let keyboardHeightOnHiding = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map {_ in return CGFloat(0) }
      
    //MARK: - Subscriber to Keyboard's changes
      
    private func subscribeToKeyboardChanges() {
          
        _ = Publishers.Merge(keyboardHeightOnOpening, keyboardHeightOnHiding)
            .subscribe(on: RunLoop.main)
            .sink { height in
                if self.currentHeight == 0 || height == 0 {
                    self.currentHeight = height
                }
        }
    }
}
