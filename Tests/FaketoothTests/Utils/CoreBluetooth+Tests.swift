//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/12/20.
//

import Foundation
import CoreBluetooth
import Faketooth

extension UUID {

    static var testPeripheral: UUID {
        return UUID(uuidString: "68753A44-4D6F-1226-9C60-0050E4C00067")!
    }

    static var unknownPeripheral: UUID {
        return UUID(uuidString: "00000000-4D6F-1226-9C60-0050E4C00067")!
    }

}

extension CBUUID {

    static var testService: CBUUID {
        return CBUUID(string: "0000FFF0-0000-1000-8000-00805F9B34FB")
    }

    static var testCharacteristic: CBUUID {
        return CBUUID(string: "0000FFF1-0000-1000-8000-00805F9B34FB")
    }

    static var configDescriptor: CBUUID {
        return CBUUID(string: "00002902-0000-1000-8000-00805F9B34FB")
    }

}

extension CBCentralManager {

    func findPeripheral(withIdentifier id: UUID) -> FaketoothPeripheral? {
        return retrievePeripherals(withIdentifiers: [id]).first as? FaketoothPeripheral
    }

}
