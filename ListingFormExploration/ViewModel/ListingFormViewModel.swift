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

final class ListingFormViewModel {
    
    let titleFieldViewModel: TitleFieldViewModel
    let priceFieldViewModel: PriceFieldViewModel
    let multiItemFieldViewModel: MultiItemFieldViewModel
    let sizesFieldViewModel: SizesFieldViewModel
    
    init(listing: Listing, mode: ListingMode) {
        
        // Listing -> VMs
        self.titleFieldViewModel = TitleFieldViewModel(listing.title)
        self.priceFieldViewModel = PriceFieldViewModel(listing.price)
        self.multiItemFieldViewModel = MultiItemFieldViewModel(listing.inventory.isMultiItem, mode: mode)
        self.sizesFieldViewModel = SizesFieldViewModel(listing.inventory.sizes, isMultiItemPublisher: self.multiItemFieldViewModel.$value)
        
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

final class TitleFieldViewModel: ObservableObject {
    
    @Published var value: String
    let label: String
    
    init(_ initialValue: String) {
        self.value = initialValue
        self.label = "Title"
    }
}

final class PriceFieldViewModel: ObservableObject {
    
    private(set) var value: Decimal?
    let label: String
    @Published var display: String
    
    init(_ initialValue: Decimal?) {
        self.value = initialValue
        self.label = "Price"
        self.display = Self.getDisplay(from: self.value)
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

final class MultiItemFieldViewModel: ObservableObject {
    
    @Published private(set) var value: Bool
    let label: String
    private var isExplicitlySelected: Bool
    @Published var display: String
    
    weak var sizesProvider: SizesProvider?
    
    init(_ initialValue: Bool, mode: ListingMode) {
        self.value = initialValue
        self.label = "Quantity"
        let isExplicitlySelected = mode == .edit
        self.isExplicitlySelected = isExplicitlySelected
        self.display = Self.getDisplay(from: initialValue, isExplicitlySelected: isExplicitlySelected)
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

final class SizesFieldViewModel: ObservableObject, SizesProvider {
    
    private(set) var value: [String]
    @Published var label: String
    @Published var display: String
    
    private var cancellables: Set<AnyCancellable> = []
    
    var sizes: [String] {
        return self.value
    }
    
    init(_ initialValue: [String], isMultiItemPublisher: Published<Bool>.Publisher) {
        self.value = initialValue
        self.label = ""
        self.display = Self.getDisplay(from: self.value)
        
        isMultiItemPublisher
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
