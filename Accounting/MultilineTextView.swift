//
//  MultilineTextView.swift
//  Accounting
//
//  Created by Petar Petrov on 2.12.19.
//  Copyright © 2019 Petar Petrov. All rights reserved.
//

import SwiftUI

struct MultilineTextView: UIViewRepresentable {
  typealias UIViewType = UITextView
    
    @Binding var text: String
    var placeholderText: String = "Placeholder"
    var fontSize: CGFloat = 17
    var onReady: (UIViewRepresentableContext<MultilineTextView>) -> ()
    
    
    func makeUIView(context: UIViewRepresentableContext<MultilineTextView>) -> UITextView {
        let textView = UITextView()

        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.text = placeholderText
        textView.textColor = .placeholderText
        textView.font = .systemFont(ofSize: fontSize)
        self.onReady(context)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<MultilineTextView>) {
        if uiView.text != "" || uiView.textColor == .label {
            uiView.text = text
            uiView.textColor = .label
        }
        
        uiView.delegate = context.coordinator
    }
    
    func frame(numLines: CGFloat) -> some View {
        let height = UIFont.systemFont(ofSize: fontSize).lineHeight * numLines
        return self.frame(height: height)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextView
        var textView: UITextView
        
        init(_ parent: MultilineTextView) {
            self.parent = parent
            self.textView = UITextView()
        }
        
        func dismiss() {
            self.textView.resignFirstResponder()
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            self.textView = textView
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = parent.placeholderText
                textView.textColor = .placeholderText
            }
        }
        
    }
}

struct MultilineTextView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextView(text: .constant("test"), placeholderText: "Some Placeholder", onReady: { con in
            
        })
    }
}
