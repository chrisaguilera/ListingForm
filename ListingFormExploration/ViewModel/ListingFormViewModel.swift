//
//  ListingFormViewModel.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import Foundation
import Combine

enum ListingMode {
    case new
    case edit
}

class FormFieldViewModel: Identifiable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

struct CollectionItem {
    let section: String
    let rows: [FormFieldViewModel]
}

protocol SizesProvider: AnyObject {
    var sizes: [String] { get }
}

// Field view models observe changes on builder instead of Listing object so that model can remain struct and
// definition does not become "muddy" with propety wrapper, etc.
final class ListingBuilder: SizesProvider {
    var title: String
    @CurrentValue var multiItem: Bool
    var sizes: [String]
    var price: Decimal?
    
    init(_ listing: Listing) {
        self.title = listing.title
        self.multiItem = listing.inventory.isMultiItem
        self.sizes = listing.inventory.sizes
        self.price = listing.price
    }
    
    func build() -> Listing {
        Listing(
            title: self.title,
            price: self.price,
            inventory: Inventory(isMultiItem: self.multiItem, sizes: self.sizes))
    }
}

final class ListingFormViewModel {
    
    let titleFieldViewModel: TitleFieldViewModel
    let multiItemFieldViewModel: MultiItemFieldViewModel
    let sizesFieldViewModel: SizesFieldViewModel
    let priceFieldViewModel: PriceFieldViewModel
    
    let listingBuilder: ListingBuilder
    
    let items: [CollectionItem]
    
    init(listing: Listing, mode: ListingMode) {
        
        let builder = ListingBuilder(listing)
        self.titleFieldViewModel = TitleFieldViewModel(listing.title) { newValue in
            builder.title = newValue
        }
        self.multiItemFieldViewModel = MultiItemFieldViewModel(listing.inventory.isMultiItem, mode: mode) { newValue in
            builder.multiItem = newValue
        }
        self.multiItemFieldViewModel.sizesProvider = builder
        self.sizesFieldViewModel = SizesFieldViewModel(listing.inventory.sizes, isMultiItemSubject: builder.$multiItem) { newValue in
            builder.sizes = newValue
        }
        self.priceFieldViewModel = PriceFieldViewModel(listing.price) { newValue in
            builder.price = newValue
        }
        self.listingBuilder = builder
        
        self.items = [
            CollectionItem(section: "Title", rows: [self.titleFieldViewModel]),
            CollectionItem(section: "Details", rows: [self.multiItemFieldViewModel, self.sizesFieldViewModel]),
            CollectionItem(section: "Prices", rows: [self.priceFieldViewModel]),
        ]
    }
    
    func didTapDone() {
        let listing = self.listingBuilder.build()
        print(listing)
    }
}

final class TitleFieldViewModel: FormFieldViewModel, ObservableObject {
    typealias Value = String
    
    @Published var value: String {
        didSet {
            self.onValueUpdate(self.value)
        }
    }
    let label: String
    
    private let onValueUpdate: (Value) -> Void
    
    init(_ initialValue: Value, onValueUpdate: @escaping (Value) -> Void) {
        self.value = initialValue
        self.label = "Title"
        self.onValueUpdate = onValueUpdate
        super.init(id: UUID().uuidString)
    }
}

final class PriceFieldViewModel: FormFieldViewModel, ObservableObject {
    typealias Value = Decimal?
    
    private(set) var value: Value {
        didSet {
            self.onValueUpdate(self.value)
        }
    }
    let label: String
    @Published private(set) var display: String
    
    private let onValueUpdate: (Value) -> Void
    
    init(_ initialValue: Value, onValueUpdate: @escaping (Value) -> Void) {
        self.value = initialValue
        self.label = "Price"
        self.display = Self.getDisplay(from: self.value)
        self.onValueUpdate = onValueUpdate
        super.init(id: UUID().uuidString)
    }
    
    func inputDidChange(_ input: String) {
        self.value = CurrencyFormatter.decimal(from: input)
        self.display = Self.getDisplay(from: self.value)
    }
    
    private static func getDisplay(from value: Decimal?) -> String {
        if let decimalValue = value, let formattedString = CurrencyFormatter.string(from: decimalValue) {
            return formattedString
        }
        return ""
    }
}

final class MultiItemFieldViewModel: FormFieldViewModel, ObservableObject {
    typealias Value = Bool
    
    @CurrentValue private(set) var value: Value {
        didSet {
            self.onValueUpdate(self.value)
        }
    }
    let label: String
    private var isExplicitlySelected: Bool
    @Published private(set) var display: String
    
    weak var sizesProvider: SizesProvider?
    private let onValueUpdate: (Value) -> Void
    
    init(_ initialValue: Value, mode: ListingMode, onValueUpdate: @escaping (Value) -> Void) {
        self.value = initialValue
        self.label = "Quantity"
        let isExplicitlySelected = mode == .edit
        self.isExplicitlySelected = isExplicitlySelected
        self.display = Self.getDisplay(from: initialValue, isExplicitlySelected: isExplicitlySelected)
        self.onValueUpdate = onValueUpdate
        super.init(id: UUID().uuidString)
    }
    
    func inputDidChange(_ input: Bool) {
        if self.value, let sizes = self.sizesProvider?.sizes, sizes.isEmpty == false {
            print("Warning: Sizes will be reset.")
        }
        
        self.isExplicitlySelected = true
        self.value = input
        self.display = Self.getDisplay(from: self.value, isExplicitlySelected: self.isExplicitlySelected)
    }
    
    private static func getDisplay(from value: Bool, isExplicitlySelected: Bool) -> String {
        if value {
            return "Multiple"
        } else {
            return isExplicitlySelected ? "One" : ""
        }
    }
}

final class SizesFieldViewModel: FormFieldViewModel, ObservableObject, SizesProvider {
    typealias Value = [String]
    
    private(set) var value: Value {
        didSet {
            self.onValueUpdate(self.value)
        }
    }
    @Published var label: String
    @Published private(set) var display: String
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let onValueUpdate: (Value) -> Void
    
    var sizes: [String] {
        return self.value
    }
    
    init(_ initialValue: Value, isMultiItemSubject: CurrentValueSubject<Bool, Never>, onValueUpdate: @escaping (Value) -> Void) {
        self.value = initialValue
        self.label = ""
        self.display = Self.getDisplay(from: self.value)
        self.onValueUpdate = onValueUpdate
        super.init(id: UUID().uuidString)
        
        isMultiItemSubject
            .withPrevious()
            .sink { [weak self] previous, current in
                guard let self = self else { return }
                
                // Update label
                self.label = current ? "Sizes" : "Size"
                
                // Reset value if necessary
                if previous == true && current == false {
                    self.value = []
                    self.display = Self.getDisplay(from: self.value)
                }
            }
            .store(in: &self.cancellables)
    }
    
    private static func getDisplay(from value: [String]) -> String {
        guard value.isEmpty == false else {
            return ""
        }
        return value.joined(separator: ", ")
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

@propertyWrapper
public class CurrentValue<Value> {
    
    public var wrappedValue: Value {
        get { self.projectedValue.value }
        set { self.projectedValue.value = newValue }
    }
    
    public var projectedValue: CurrentValueSubject<Value, Never>
    
    public init(wrappedValue: Value) {
        self.projectedValue = CurrentValueSubject(wrappedValue)
    }
}
