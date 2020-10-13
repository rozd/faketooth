//
//  File.swift
//  
//
//  Created by Max Rozdobudko on 10/10/20.
//

import XCTest
@testable import Faketooth

final class FaketoothPeripheralTest: XCTestCase {

    // MARK: Setup


    var peripheralDelegate: FaketoothPeripheralDelegate!

    override func setUp() {
        peripheralDelegate = FaketoothPeripheralDelegate()
    }

    override func tearDown() {
        faketoothTearDown()
        peripheralDelegate = nil
    }

    // MARK: Tests

    func testReadValueForCharacteristic() {
        let characteristic = FaketoothCharacteristic(
            uuid: .testCharacteristic,
            properties: [.read],
            descriptors: nil,
            valueProducer: { () -> Data? in
                return "this is only a test".data(using: .utf8)
            },
            valueHandler: nil
        )

        let peripheral = FaketoothPeripheral(
            identifier: .testPeripheral,
            name: "testValueProducer",
            services: [
                FaketoothService(
                    uuid: .testService,
                    isPrimary: true,
                    characteristics: [characteristic]
                )
            ],
            advertisementData: nil
        )
        peripheral.delegate = peripheralDelegate

        CBCentralManager.simulatedPeripherals = [peripheral]

        let expectation = XCTestExpectation(description: "Read value for characteristic")

        peripheral.readValue(for: characteristic)

        peripheralDelegate.onDidUpdateValueForCharacteristic = { characteristic, error in
            expectation.fulfill()
            guard let value = characteristic.value else {
                XCTFail("Test characteristic should contain a value")
                return
            }
            XCTAssertEqual("this is only a test", String(data: value, encoding: .utf8))
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testWriteValueForCharacteristic() {
        let expectValue = XCTestExpectation(description: "Receive characteristic value in its value handler")
        let characteristic = FaketoothCharacteristic(
            uuid: .testCharacteristic,
            properties: [.read, .write],
            descriptors: nil,
            valueProducer: nil,
            valueHandler: { data in
                expectValue.fulfill()
                guard let data = data, let string = String(data: data, encoding: .utf8) else {
                    XCTFail("Characteristic received an invalid value")
                    return
                }
                XCTAssertEqual(string, "this is only a test")
            }
        )

        let peripheral = faketoothSetupPeripheral()
        peripheral.delegate = peripheralDelegate

        faketoothSetup(peripherals: [peripheral], characteristics: [characteristic])

        let expectWrite = XCTestExpectation(description: "Write value for characteristic")
        peripheralDelegate.onDidWriteValueForCharacteristic = { characteristic, error in
            expectWrite.fulfill()
            guard let data = characteristic.value, let string =  String(data: data, encoding: .utf8) else {
                XCTFail("Characteristic received an invalid value")
                return
            }
            XCTAssertEqual(string, "this is only a test")
        }
    }

    func testReadValueForDescriptor() {
        let descriptor = FaketoothDescriptor(
            uuid: .configDescriptor,
            valueProducer: { () -> Any? in
                return "this is only a test".data(using: .utf8)
            },
            valueHandler: nil
        )

        let peripheral = faketoothSetupPeripheral()
        peripheral.delegate = peripheralDelegate

        faketoothSetup(peripherals: [peripheral], descriptors: [descriptor])

        let expectation = XCTestExpectation(description: "Read value for descriptor")
        peripheralDelegate.onDidUpdateValueForDescriptor = { descriptor, error in
            expectation.fulfill()
            guard let value = descriptor.value as? Data else {
                XCTFail("Test descriptor should contain a value")
                return
            }
            XCTAssertEqual("this is only a test", String(data: value, encoding: .utf8))
        }

        peripheral.readValue(for: descriptor)

        wait(for: [expectation], timeout: 1.0)
    }

    func testWriteValueForDescriptor() {
        let expectValue = XCTestExpectation(description: "Descriptor's value handler is not called")

        let descriptor = FaketoothDescriptor(
            uuid: .configDescriptor,
            valueProducer: nil,
            valueHandler: { value in
                expectValue.fulfill()
                guard let data = value as? Data, let string =  String(data: data, encoding: .utf8) else {
                    XCTFail("Test descriptor received invalid value")
                    return
                }
                XCTAssertEqual(string, "this is only a test")
            }
        )

        let peripheral = faketoothSetupPeripheral()
        peripheral.delegate = peripheralDelegate

        faketoothSetup(peripherals: [peripheral], descriptors: [descriptor])

        let expectWrite = XCTestExpectation(description: "Write value for descriptor")
        peripheralDelegate.onDidWriteValueForDescriptor = { descriptor, error in
            expectWrite.fulfill()
            guard let data = descriptor.value as? Data, let string =  String(data: data, encoding: .utf8) else {
                XCTFail("Test descriptor received invalid value")
                return
            }
            XCTAssertEqual(string, "this is only a test")
        }

        peripheral.writeValue("this is only a test".data(using: .utf8)!, for: descriptor)

        wait(for: [expectValue, expectWrite], timeout: 1.0)
    }

}

// MARK: - <CBPeripheralDelegate>

class FaketoothPeripheralDelegate: NSObject, CBPeripheralDelegate {

    // MARK: peripheral(_:didUpdateValueFor:error:)

    var onDidUpdateValueForCharacteristic: ((_ characteristic: CBCharacteristic, _ error: Error?) -> Void)?

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        onDidUpdateValueForCharacteristic?(characteristic, error)
    }

    // MARK: peripheral(_:didWriteValueFor:error)

    var onDidWriteValueForCharacteristic: ((_ characteristic: CBCharacteristic, _ error: Error?) -> Void)?

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        onDidWriteValueForCharacteristic?(characteristic, error)
    }

    // MARK: peripheral(_:didUpdateValueFor:error:)

    var onDidUpdateValueForDescriptor: ((_ descriptor: CBDescriptor, _ error: Error?) -> Void)?

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        onDidUpdateValueForDescriptor?(descriptor, error)
    }

    // MARK: peripheral(_:didWriteValueFor:error)

    var onDidWriteValueForDescriptor: ((_ descriptor: CBDescriptor, _ error: Error?) -> Void)?

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        onDidWriteValueForDescriptor?(descriptor, error)
    }
}
