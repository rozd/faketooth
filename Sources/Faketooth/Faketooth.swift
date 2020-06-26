@_exported import Faketooth_ObjC

struct Faketooth {
    var text = "Hello, World!"
    func test() {
        CBCentralManager.simulatedPeripherals = []
    }
}
