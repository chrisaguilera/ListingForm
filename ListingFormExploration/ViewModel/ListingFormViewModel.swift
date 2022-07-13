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
    
    private let listingBuilder: ListingBuilder
    private let onFinished: (Listing) -> Void
    
    let titleFieldViewModel: TitleFieldViewModel
    let multiItemFieldViewModel: MultiItemFieldViewModel
    let sizesFieldViewModel: SizesFieldViewModel
    let priceFieldViewModel: PriceFieldViewModel
    
    let items: [CollectionItem<String, FormFieldViewModel>]
    
    init(listing: Listing, mode: ListingMode, onFinished: @escaping (Listing) -> Void) {
        let builder = ListingBuilder(listing)
        self.listingBuilder = builder
        
        self.titleFieldViewModel = TitleFieldViewModel(builder.$title)
        self.multiItemFieldViewModel = MultiItemFieldViewModel(
            builder.$multiItem,
            sizesSubject: builder.$sizes,
            mode: mode)
        self.sizesFieldViewModel = SizesFieldViewModel(
            builder.$sizes,
            multiItemPublisher: builder.$multiItem.eraseToAnyPublisher())
        self.priceFieldViewModel = PriceFieldViewModel(builder.$price)
        
        self.items = [
            CollectionItem(section: "Title", rows: [self.titleFieldViewModel]),
            CollectionItem(section: "Details", rows: [self.multiItemFieldViewModel, self.sizesFieldViewModel]),
            CollectionItem(section: "Prices", rows: [self.priceFieldViewModel]),
        ]
        
        self.onFinished = onFinished
    }
    
    func didTapDone() {
        let listing = self.listingBuilder.build()
        self.onFinished(listing)
    }
    
    func didTapReset() {
        self.listingBuilder.reset()
    }
}
