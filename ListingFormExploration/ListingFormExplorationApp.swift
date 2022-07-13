//
//  ListingFormExplorationApp.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import SwiftUI

@main
struct ListingFormExplorationApp: App {
    
    let viewModel = ListingFormViewModel(listing: .mock, mode: .edit) { print($0) }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListingFormView(self.viewModel)
                    .navigationTitle("Edit Listing")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Reset") {
                                self.viewModel.didTapReset()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                self.viewModel.didTapDone()
                            }
                        }
                    }
            }
        }
    }
}

extension ListingInventory {
    fileprivate static let empty: ListingInventory = {
        ListingInventory(isMultiItem: false, sizes: [])
    }()
}

extension Listing {
    fileprivate static let empty: Listing = {
        Listing(title: "", price: nil, inventory: .empty)
    }()
    
    fileprivate static let mock: Listing = {
        let inventory = ListingInventory(isMultiItem: true, sizes: ["S", "M"])
        return Listing(title: "Jeans", price: 20, inventory: inventory)
    }()
}
