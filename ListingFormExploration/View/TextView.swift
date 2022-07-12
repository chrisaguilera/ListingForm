//
//  TextView.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import UIKit
import SwiftUI

struct UITextFieldConfiguration {
    let keyboardType: UIKeyboardType
}

struct TextFieldView: UIViewRepresentable {
    
    private let placeholder: String
    private let configuration: UITextFieldConfiguration
    private let readOnlyText: String
    private let onInputChange: (String) -> Void
    
    init(
        placeholder: String,
        configuration: UITextFieldConfiguration,
        reads readOnlyText: String,
        onInputChange: @escaping (String) -> Void) {
        
        self.placeholder = placeholder
        self.configuration = configuration
        self.readOnlyText = readOnlyText
        self.onInputChange = onInputChange
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = self.placeholder
        textField.keyboardType = self.configuration.keyboardType
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = self.readOnlyText
        if let font = context.environment.font {
            uiView.font = UIFont.preferredFont(from: font)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator { text in
            self.onInputChange(text)
        }
    }
}

class Coordinator: NSObject, UITextFieldDelegate {
    var onInputChange: (String) -> Void
    
    init(onInputChange: @escaping (String) -> Void) {
        self.onInputChange = onInputChange
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inputString: String
        if let text = textField.text, let rangeInText = Range(range, in: text) {
            inputString = text.replacingCharacters(in: rangeInText, with: string)
        } else {
            inputString = ""
        }
        self.onInputChange(inputString)
        return false
    }
}

extension UIFont {
    class func preferredFont(from font: Font) -> UIFont {
        let uiFont: UIFont
        switch font {
        case .largeTitle:
            uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title:
            uiFont = UIFont.preferredFont(forTextStyle: .title1)
        case .title2:
            uiFont = UIFont.preferredFont(forTextStyle: .title2)
        case .title3:
            uiFont = UIFont.preferredFont(forTextStyle: .title3)
        case .headline:
            uiFont = UIFont.preferredFont(forTextStyle: .headline)
        case .subheadline:
            uiFont = UIFont.preferredFont(forTextStyle: .subheadline)
        case .callout:
            uiFont = UIFont.preferredFont(forTextStyle: .callout)
        case .caption:
            uiFont = UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2:
            uiFont = UIFont.preferredFont(forTextStyle: .caption2)
        case .footnote:
            uiFont = UIFont.preferredFont(forTextStyle: .footnote)
        case .body:
            fallthrough
        default:
            uiFont = UIFont.preferredFont(forTextStyle: .body)
        }
        return uiFont
    }
}
