import XCTest
@testable import Faketooth

final class FaketoothTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Faketooth().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
