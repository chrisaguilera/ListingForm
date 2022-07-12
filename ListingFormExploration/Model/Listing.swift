//
//  Listing.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import Foundation

struct Inventory {
    var isMultiItem: Bool
    var sizes: [String]
}

struct Listing {
    var title: String
    var price: Decimal?
    var inventory: Inventory
}
