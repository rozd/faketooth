//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/12/20.
//

import Foundation
@testable import Faketooth

class MockPeripheral : CBPeripheral {

    init(onlyForTests: Bool) {

    }

    func setup() {
        // adds observer as removing it is one of phases of clean up CBPeripheral instance
        addObserver(self, forKeyPath: "delegate", options: [], context: nil)
    }

}
