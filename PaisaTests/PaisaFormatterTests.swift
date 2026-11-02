//
//  PaisaFormatterTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 02/11/26.
//

import XCTest
@testable import Paisa

// MARK: - PaisaFormatterTests

final class PaisaFormatterTests: XCTestCase {

    func testWholeRupeesHaveNoDecimals() {
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 50000), "₹500")
    }

    func testPaiseAlwaysShowTwoDigits() {
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 12550), "₹125.50")
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 12505), "₹125.05")
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 5), "₹0.05")
    }

    func testZero() {
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 0), "₹0")
    }

    func testIndianGroupingForLakhs() {
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 12500000), "₹1,25,000")
    }

    func testIndianGroupingForCrores() {
        XCTAssertEqual(PaisaFormatter.currency(minorUnits: 1234567890), "₹1,23,45,678.90")
    }

    func testDecimalAndMinorUnitsAgree() throws {
        let decimal = try XCTUnwrap(Decimal(string: "125.5"))
        XCTAssertEqual(PaisaFormatter.currency(decimal), PaisaFormatter.currency(minorUnits: 12550))
    }

    func testIntExtension() {
        XCTAssertEqual(12550.asAmount, Decimal(string: "125.5"))
        XCTAssertEqual(12550.asFormattedCurrency, "₹125.50")
    }
}
