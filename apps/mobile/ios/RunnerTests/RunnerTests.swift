import Flutter
import UIKit
import XCTest

final class RunnerTests: XCTestCase {
  func testApplicationDisplayName() {
    let displayName = Bundle.main.object(
      forInfoDictionaryKey: "CFBundleDisplayName"
    ) as? String

    XCTAssertEqual(displayName, "Rick and Morty")
  }
}
