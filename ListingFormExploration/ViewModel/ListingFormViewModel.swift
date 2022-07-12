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

final class ListingFormViewModel {
    
    let titleFieldViewModel: TitleFieldViewModel
    let multiItemFieldViewModel: MultiItemFieldViewModel
    let sizesFieldViewModel: SizesFieldViewModel
    let priceFieldViewModel: PriceFieldViewModel
    
    let items: [CollectionItem]
    
    init(listing: Listing, mode: ListingMode) {
        
        // Listing -> VMs
        self.titleFieldViewModel = TitleFieldViewModel(listing.title)
        self.multiItemFieldViewModel = MultiItemFieldViewModel(listing.inventory.isMultiItem, mode: mode)
        self.sizesFieldViewModel = SizesFieldViewModel(listing.inventory.sizes, isMultiItemSubject: self.multiItemFieldViewModel.$value)
        self.priceFieldViewModel = PriceFieldViewModel(listing.price)
        
        self.items = [
            CollectionItem(section: "Title", rows: [self.titleFieldViewModel]),
            CollectionItem(section: "Details", rows: [self.multiItemFieldViewModel, self.sizesFieldViewModel]),
            CollectionItem(section: "Prices", rows: [self.priceFieldViewModel]),
        ]
        
        // ! Circular dependency between multi-item field VM and sizes field VM
        self.multiItemFieldViewModel.sizesProvider = self.sizesFieldViewModel
    }
    
    func didTapDone() {
        
        // VMs -> Listing
        let title = self.titleFieldViewModel.value
        let price = self.priceFieldViewModel.value
        let inventory = Inventory(isMultiItem: self.multiItemFieldViewModel.value, sizes: self.sizesFieldViewModel.value)
        let listing = Listing(title: title, price: price, inventory: inventory)
        
        print(listing)
    }
}

final class TitleFieldViewModel: FormFieldViewModel, ObservableObject {
    
    @Published var value: String
    let label: String
    
    init(_ initialValue: String) {
        self.value = initialValue
        self.label = "Title"
        super.init(id: UUID().uuidString)
    }
}

final class PriceFieldViewModel: FormFieldViewModel, ObservableObject {
    
    private(set) var value: Decimal?
    let label: String
    @Published private(set) var display: String
    
    init(_ initialValue: Decimal?) {
        self.value = initialValue
        self.label = "Price"
        self.display = Self.getDisplay(from: self.value)
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

protocol SizesProvider: AnyObject {
    var sizes: [String] { get }
}

final class MultiItemFieldViewModel: FormFieldViewModel, ObservableObject {
    
    @CurrentValue private(set) var value: Bool
    let label: String
    private var isExplicitlySelected: Bool
    @Published private(set) var display: String
    
    weak var sizesProvider: SizesProvider?
    
    init(_ initialValue: Bool, mode: ListingMode) {
        self.value = initialValue
        self.label = "Quantity"
        let isExplicitlySelected = mode == .edit
        self.isExplicitlySelected = isExplicitlySelected
        self.display = Self.getDisplay(from: initialValue, isExplicitlySelected: isExplicitlySelected)
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
    
    private(set) var value: [String]
    @Published var label: String
    @Published private(set) var display: String
    
    private var cancellables: Set<AnyCancellable> = []
    
    var sizes: [String] {
        return self.value
    }
    
    init(_ initialValue: [String], isMultiItemSubject: CurrentValueSubject<Bool, Never>) {
        self.value = initialValue
        self.label = ""
        self.display = Self.getDisplay(from: self.value)
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
