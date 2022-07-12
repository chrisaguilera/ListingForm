//
//  ListingFormView.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import SwiftUI

struct ListingFormView: View {
    private let viewModel: ListingFormViewModel
    
    init(_ viewModel: ListingFormViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Form {
            TitleFieldView(self.viewModel.titleFieldViewModel)
            PriceFieldView(self.viewModel.priceFieldViewModel)
            MultiItemFieldView(self.viewModel.multiItemFieldViewModel)
            SizesFieldView(self.viewModel.sizesFieldViewModel)
        }
    }
}

struct TitleFieldView: View {
    @ObservedObject private var viewModel: TitleFieldViewModel
    
    init(_ viewModel: TitleFieldViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(self.viewModel.label)
            TextField("Required", text: self.$viewModel.value)
        }
    }
}

struct PriceFieldView: View {
    @ObservedObject private var viewModel: PriceFieldViewModel
    
    init(_ viewModel: PriceFieldViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(self.viewModel.label)
            TextFieldView(
                placeholder: "Required",
                configuration: UITextFieldConfiguration(keyboardType: .numberPad),
                reads: self.viewModel.display,
                onInputChange: { [weak viewModel] input in
                    viewModel?.inputDidChange(input)
                })
                .keyboardType(UIKeyboardType.numberPad)
        }
    }
}

struct MultiItemFieldView: View {
    @ObservedObject private var viewModel: MultiItemFieldViewModel
    @State var isEnabled: Bool
    
    init(_ viewModel: MultiItemFieldViewModel) {
        self.viewModel = viewModel
        self.isEnabled =  viewModel.value
    }
    
    var body: some View {
        HStack {
            Text(self.viewModel.label)
            TextField("Optional", text: self.$viewModel.display)
                .disabled(true)
            Toggle(
                "Toggle",
                isOn: .init(get: {
                    return self.isEnabled
                }, set: { [weak viewModel] newValue in
                    self.isEnabled = newValue
                    viewModel?.inputDidChange(self.isEnabled)
                }))
                .labelsHidden()
        }
    }
}

struct SizesFieldView: View {
    @ObservedObject private var viewModel: SizesFieldViewModel
    
    init(_ viewModel: SizesFieldViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(self.viewModel.label)
            TextField("Required", text: self.$viewModel.display)
                .disabled(true)
        }
    }
}