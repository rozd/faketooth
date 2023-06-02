# Faketooth

Faketooth is a library that allows you to simulate a Bluetooth Low Energy (BLE) interface on iOS/macOS/watchOS/tvOS platforms. It leverages swizzling techniques to emulate a BLE device, enabling you to create virtual peripherals with custom services, characteristics, descriptors, and advertisement data.

## Installation

You can integrate Faketooth into your project using Swift Package Manager. Simply add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/rozd/faketooth.git", from: "0.5.0")
]
```

## Usage

To start using Faketooth, follow the steps below:

1. Import the `Faketooth` module in your code:

```swift
import Faketooth
```

2. Set up the simulated peripherals by assigning an array of `FaketoothPeripheral` instances to `CBCentralManager.simulatedPeripherals`. Each `FaketoothPeripheral` represents a virtual BLE device with its own unique identifier, name, services, advertisement data, and more.

Here's an example that demonstrates the basic usage:

```swift
CBCentralManager.simulatedPeripherals = [
    FaketoothPeripheral(
        identifier: UUID(),
        name: "Test",
        services: [
            FaketoothService(
                uuid: CBUUID(),
                isPrimary: true,
                characteristics: [
                    FaketoothCharacteristic(
                        uuid: CBUUID(),
                        properties: [.read, .notify, .write],
                        descriptors: [
                            FaketoothDescriptor(
                                uuid: CBUUID(string: "2902"),
                                valueProducer: { () -> Any? in
                                    return Data(capacity: 2)
                                }
                            )
                        ],
                        valueProducer: { "Hello".data(using: .utf8) },
                        valueHandler: { data in
                            print("\(String(data: data!, encoding: .utf8)!)")
                        }
                    )
                ]
            )
        ],
        advertisementData: [
            CBAdvertisementDataLocalNameKey: "Name for Advertisement"
        ]
    )
]
```

In this example, we create a single virtual peripheral named "Test" with a primary service. The service contains one characteristic with read, notify, and write properties. Additionally, the characteristic has a descriptor with a UUID of "2902". We also specify an advertisement name for the peripheral.

3. Build and run your project. Faketooth will now simulate the BLE interface, allowing you to interact with your virtual peripherals as if they were real devices.

## Examples

To help you get started, the Faketooth repository provides examples that demonstrate different use cases and configurations. You can find these examples in the [Demo](https://github.com/rozd/faketooth/tree/master/Demo) directory.

## Contributions and Support

Contributions to Faketooth are welcome! If you encounter any issues, have questions, or would like to suggest improvements, please open an issue on the [GitHub repository](https://github.com/rozd/faketooth).

## License

Faketooth is available under the MIT license. See the [LICENSE](https://github.com/rozd/faketooth/blob/main/LICENSE) file for more information.

---

Thank you for using Faketooth! I hope this library simplifies your BLE testing and development workflows. If you find it helpful, please consider giving it a star on [GitHub](https://github.com/rozd/faketooth).
