//
//  PopupPicker.swift
//  Accounting
//
//  Created by Petar Petrov on 1.02.20.
//  Copyright © 2020 Petar Petrov. All rights reserved.
//

import SwiftUI

struct PopupPicker: View {
    @Binding var toggle: Bool
    @State var position: CGFloat = 0
    @State var singleTap: Bool = false
    let view: AnyView
    let height: CGFloat = 450
    
    var body: some View {
        ZStack {
             if self.toggle {
                 Rectangle()
                     .foregroundColor(Color.black.opacity(0.8))
                     .frame(height: UIScreen.main.bounds.height)
                     .offset(y: (-270) - self.position)
                     .onTapGesture {
                         self.toggle.toggle()
                         self.position = 0
                }
                 .gesture(DragGesture()
                 .onChanged({ value in
                    self.onGestureChange(value: value)
                 })
                 .onEnded {value in
                    self.onGestureEnd(value);
                 })
             }
             Rectangle()
                .foregroundColor(Color("black-white"))
                .frame(height: self.height)
                .cornerRadius(10)
                .shadow(radius: 10)
                .gesture(DragGesture()
                .onChanged({ value in
                    self.onGestureChange(value: value)
                })
                .onEnded {value in
                    self.onGestureEnd(value);
                })

                view
                .frame(height: self.height)
        }
          .offset(y: self.toggle ? self.position : 650)
          .animation(.spring())
    }
    
    private func onGestureEnd(_ value: DragGesture.Value) {
        if (value.translation.height > 150) {
           self.toggle.toggle()
            self.position = 0
       } else {
           self.position = 0
       }
    }
    
    private func onGestureChange(value: DragGesture.Value) {
        if (value.translation.height > 0) {
               self.position = value.translation.height
           }
        if value.translation.height > 150{
            if (self.singleTap == false ) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            }
            
            self.singleTap = true;
        } else {
            self.singleTap = false
        }
    }
}

struct PopupPicker_Previews: PreviewProvider {
    static var previews: some View {
        PopupPicker(toggle: .constant(true), view: AnyView(FilterView(from: .constant(Date()), to: .constant(Date()), onDone: {from, to in
            
        })))
    }
}
