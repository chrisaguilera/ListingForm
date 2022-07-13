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
            ForEach(self.viewModel.items, id: \.section) { item in
                Section(item.section) {
                    ForEach(item.rows, id: \.id) { viewModel in
                        switch viewModel {
                        case let viewModel as TitleFieldViewModel:
                            TitleFieldView(viewModel)
                        case let viewModel as MultiItemFieldViewModel:
                            MultiItemFieldView(viewModel)
                        case let viewModel as SizesFieldViewModel:
                            SizesFieldView(viewModel)
                        case let viewModel as PriceFieldViewModel:
                            PriceFieldView(viewModel)
                        default:
                            Text("")
                        }
                    }
                }
            }
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
            TextField(
                "Required",
                text: Binding<String>(
                    get: { return self.viewModel.display },
                    set: { self.viewModel.inputDidChange($0) }
                ))
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
        }
    }
}

struct MultiItemFieldView: View {
    @ObservedObject private var viewModel: MultiItemFieldViewModel
    
    init(_ viewModel: MultiItemFieldViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(self.viewModel.label)
            TextField("Optional", text: .constant(self.viewModel.display))
                .disabled(true)
            Toggle(
                "Toggle",
                isOn: Binding<Bool>(
                    get: { return self.viewModel.valueSubject.value },
                    set: { self.viewModel.inputDidChange($0) }
                ))
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
            TextField("Required", text: .constant(self.viewModel.display))
                .disabled(true)
        }
    }
}
