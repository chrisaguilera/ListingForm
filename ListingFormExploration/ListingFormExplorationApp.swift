//
//  ListingFormExplorationApp.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import SwiftUI

@main
struct ListingFormExplorationApp: App {
    
    private let viewModel = ListingFormViewModel(listing: .mock, mode: .new)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListingFormView(self.viewModel)
                    .navigationTitle("Edit Listing")
                    .toolbar {
                        Button("Done") { [weak viewModel] in
                            viewModel?.didTapDone()
                        }
                    }
            }
        }
    }
}

extension Inventory {
    static let empty: Inventory = {
        Inventory(isMultiItem: false, sizes: [])
    }()
}

extension Listing {
    
    static let empty: Listing = {
        Listing(title: "", price: nil, inventory: .empty)
    }()
    
    static let mock: Listing = {
        let inventory = Inventory(isMultiItem: true, sizes: ["S", "M"])
        return Listing(title: "Jeans", price: 20, inventory: inventory)
    }()
}
