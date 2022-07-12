//
//  CurrencyFormatter.swift
//  ListingFormExploration
//
//  Created by Christopher Aguilera on 7/8/22.
//

import Foundation

struct CurrencyFormatter {
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.allowsFloats = false
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    static func decimal(from string: String) -> Decimal? {
        
        if let decimal = Decimal(string: string) {
            return decimal
        }
        
        let processedString = string.replacingOccurrences(of: CurrencyFormatter.formatter.currencyGroupingSeparator, with: "")
        let currencySymbolRange = string.nsRange(of: CurrencyFormatter.formatter.currencySymbol)
        if currencySymbolRange.location != NSNotFound,
           currencySymbolRange.length > 0,
           let number = Self.formatter.number(from: processedString),
           number.decimalValue.isNaN == false {
            
            return number.decimalValue
        }
        
        return nil
    }
    
    static func string(from decimal: Decimal) -> String? {
        return CurrencyFormatter.formatter.string(from: NSDecimalNumber(decimal: decimal))
    }
}

extension String {
    func nsRange(of string: String?) -> NSRange {
        let nsRange = NSMakeRange(NSNotFound, 0)
        
        guard case self = self else {
            return nsRange
        }
        
        guard let string = string else {
            return nsRange
        }
        
        if let range = self.range(of: string){
            if let lower = UTF16View.Index(range.lowerBound, within: utf16), let upper = UTF16View.Index(range.upperBound, within: utf16) {
                let start = self.distance(from: self.startIndex, to: lower)
                let length = self.distance(from: lower, to: upper)
                return NSMakeRange(start, length)
            }
        }
        return nsRange
    }
}
