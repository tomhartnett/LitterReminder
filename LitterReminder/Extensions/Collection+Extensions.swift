//
//  Collection+Extensions.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 11/26/24.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
