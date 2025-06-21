//
//  String+Extensions.swift
//  LitterReminder
//
//  Created by Tom Hartnett on 6/21/25.
//

import Foundation

extension String {
    func appendingError(_ error: Error?) -> String {
        if let error {
            return "\(self): \(error.localizedDescription)"
        } else {
            return "\(self)."
        }
    }
}
