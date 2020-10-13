//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/12/20.
//

import Foundation
import XCTest

extension XCTestCase {
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
