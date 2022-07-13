//
//  FormFieldViewModel.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/12/22.
//

import Foundation
import Combine

class FormFieldViewModel: Identifiable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

final class TitleFieldViewModel: FormFieldViewModel, ObservableObject {
    private let valueSubject: CurrentValueSubject<String, Never>
    let label: String
    @Published private(set) var display: String
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(_ valueSubject: CurrentValueSubject<String, Never>) {
        self.valueSubject = valueSubject
        self.label = "Title"
        self.display = ""
        super.init(id: UUID().uuidString)
        
        self.valueSubject
            .sink { [weak self] value in
                self?.display = value
            }
            .store(in: &self.subscriptions)
    }
    
    func inputDidChange(_ input: String) {
        self.valueSubject.send(input)
    }
}

final class PriceFieldViewModel: FormFieldViewModel, ObservableObject {
    private let valueSubject: CurrentValueSubject<Decimal?, Never>
    let label: String
    @Published private(set) var display: String
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(_ valueSubject: CurrentValueSubject<Decimal?, Never>) {
        self.valueSubject = valueSubject
        self.label = "Price"
        self.display = ""
        super.init(id: UUID().uuidString)
        
        self.valueSubject
            .sink { [weak self] value in
                self?.display = Self.getDisplay(from: value)
            }
            .store(in: &self.subscriptions)
    }
    
    func inputDidChange(_ input: String) {
        let decimal = CurrencyFormatter.decimal(from: input)
        self.valueSubject.send(decimal)
    }
    
    private static func getDisplay(from decimal: Decimal?) -> String {
        if let decimal = decimal, let formattedString = CurrencyFormatter.string(from: decimal) {
            return formattedString
        }
        return ""
    }
}

final class MultiItemFieldViewModel: FormFieldViewModel, ObservableObject {
    let valueSubject: CurrentValueSubject<Bool, Never>
    private var isExplicitlySelected: Bool
    let label: String
    @Published private(set) var display: String
    
    private let sizesSubject: CurrentValueSubject<[String], Never>
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        _ valueSubject: CurrentValueSubject<Bool, Never>,
        sizesSubject: CurrentValueSubject<[String], Never>,
        mode: ListingMode
    ) {
        self.valueSubject = valueSubject
        self.label = "Quantity"
        self.display = ""
        self.isExplicitlySelected = mode == .edit
        self.sizesSubject = sizesSubject
        super.init(id: UUID().uuidString)
        
        self.valueSubject
            .sink { [weak self] value in
                guard let self = self else { return }
                self.display = Self.getDisplay(from: value, isExplicitlySelected: self.isExplicitlySelected)
            }
            .store(in: &self.subscriptions)
    }
    
    func inputDidChange(_ input: Bool) {
        if self.valueSubject.value, self.sizesSubject.value.isEmpty == false {
            print("Sizes will be reset.")
        }
        
        self.isExplicitlySelected = true
        self.valueSubject.send(input)
    }
    
    private static func getDisplay(from isMultiItem: Bool, isExplicitlySelected: Bool) -> String {
        if isMultiItem {
            return "Multiple"
        } else {
            return isExplicitlySelected ? "One" : ""
        }
    }
}

final class SizesFieldViewModel: FormFieldViewModel, ObservableObject {
    private let valueSubject: CurrentValueSubject<[String], Never>
    @Published private(set) var label: String
    @Published private(set) var display: String
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(
        _ valueSubject: CurrentValueSubject<[String], Never>,
        multiItemPublisher: AnyPublisher<Bool, Never>
    ) {
        self.valueSubject = valueSubject
        self.label = ""
        self.display = ""
        super.init(id: UUID().uuidString)
        
        self.valueSubject
            .sink { [weak self] value in
                self?.display = Self.getDisplay(from: value)
            }
            .store(in: &self.subscriptions)
        
        multiItemPublisher
            .withPrevious()
            .sink { [weak self] previous, current in
                guard let self = self else { return }
                
                if previous == true && current == false {
                    self.valueSubject.send([])
                }
                
                self.label = current ? "Sizes" : "Size"
            }
            .store(in: &self.subscriptions)
    }
    
    private static func getDisplay(from sizes: [String]) -> String {
        guard sizes.isEmpty == false else {
            return ""
        }
        return sizes.joined(separator: ", ")
    }
}

extension Publisher {
    func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan(Optional<(Output?, Output)>.none) { previous, current in
            return (previous?.1, current)
        }
        .compactMap {
            return $0
        }
        .eraseToAnyPublisher()
    }
}
