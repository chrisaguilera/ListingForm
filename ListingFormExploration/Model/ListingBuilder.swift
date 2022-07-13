//
//  ListingBuilder.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/12/22.
//

import Foundation
import Combine

final class ListingBuilder {
    
    @CurrentValue var title: String
    @CurrentValue var multiItem: Bool
    @CurrentValue var sizes: [String]
    @CurrentValue var price: Decimal?
    
    init(_ listing: Listing) {
        self.title = listing.title
        self.multiItem = listing.inventory.isMultiItem
        self.sizes = listing.inventory.sizes
        self.price = listing.price
    }
    
    func reset() {
        self.title = ""
        self.multiItem = false
        self.sizes = []
        self.price = nil
    }
    
    func build() -> Listing {
        Listing(
            title: self.title,
            price: self.price,
            inventory: ListingInventory(isMultiItem: self.multiItem, sizes: self.sizes))
    }
}

@propertyWrapper
struct CurrentValue<Value> {
    public var projectedValue: CurrentValueSubject<Value, Never>
    
    public var wrappedValue: Value {
        get { self.projectedValue.value }
        set { self.projectedValue.value = newValue }
    }
    
    public init(wrappedValue: Value) {
        self.projectedValue = CurrentValueSubject(wrappedValue)
    }
}

