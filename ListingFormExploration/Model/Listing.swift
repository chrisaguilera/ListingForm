//
//  Listing.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import Foundation

struct ListingInventory {
    let isMultiItem: Bool
    let sizes: [String]
}

struct Listing {
    let title: String
    let price: Decimal?
    let inventory: ListingInventory
}
