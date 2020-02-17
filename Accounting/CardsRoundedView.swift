//
//  CardsRoundedView.swift
//  Accounting
//
//  Created by Petar Petrov on 27.11.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct ScrollRow: View {
    var index: Int
    var body: some View {
        HStack {
            Text("Some text \(index)")
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 80)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.all, 5)
        
    }
}

struct Header: View {
    var text: Text
    var minHeight: CGFloat = 200
    var fixedPosition: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                text
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: minHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.all, 5)
            .animation(.spring(response: 0.5, dampingFraction: 1, blendDuration: 1000))
        }
        
    }
}

struct MyText: View {
    var minY: GeometryProxy
    @Binding var scroll: Double
    @Binding var fixed: Bool
    
    var body: some View {
        self.scroll = Double(self.minY.frame(in: .global).minY)
        self.fixed = Double(self.minY.frame(in: .global).minY) <= 170
        return Text("")
        
    }
}

struct CardsRoundedView: View {
    @State var fixed: Bool = false
    @State var scroll: Double = 0
    var body: some View {
        VStack {
            ZStack {
                Header(
                    text: Text("Header")
                        .font(.largeTitle),
                    minHeight: fixed ? 150 : 250,
                    fixedPosition: fixed
                ).shadow(radius: 5)
            }.zIndex(2)
            ScrollView {
                GeometryReader { geo in
                    MyText(minY: geo, scroll: self.$scroll, fixed: self.$fixed)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0.1)
                .zIndex(1)
                
                
                
                Group {
                    ScrollRow(index: 1)
                    ScrollRow(index: 2)
                    ScrollRow(index: 3)
                    ScrollRow(index: 4)
                    ScrollRow(index: 5)
                    ScrollRow(index: 6)
                    ScrollRow(index: 7)
                    ScrollRow(index: 8)
                    ScrollRow(index: 9)
                    ScrollRow(index: 10)
                }.zIndex(0)
                Group {
                    ScrollRow(index: 11)
                    ScrollRow(index: 12)
                    ScrollRow(index: 13)
                    ScrollRow(index: 14)
                }.zIndex(0)
            }
        }.onAppear {
            self.fixed = false
        }
    }
}

struct CardsRoundedView_Previews: PreviewProvider {
    static var previews: some View {
        CardsRoundedView()
    }
}
