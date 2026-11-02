//
//  AmountParserTests.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 02/11/26.
//

import XCTest
@testable import Paisa

// MARK: - AmountParserTests

final class AmountParserTests: XCTestCase {

    // MARK: - Valid input

    func testWholeRupees() {
        XCTAssertEqual(AmountParser.minorUnits(from: "500"), 50000)
    }

    func testRupeesAndPaise() {
        XCTAssertEqual(AmountParser.minorUnits(from: "125.50"), 12550)
        XCTAssertEqual(AmountParser.minorUnits(from: "125.5"), 12550)
        XCTAssertEqual(AmountParser.minorUnits(from: "0.07"), 7)
    }

    func testTrailingPointWhileTyping() {
        XCTAssertEqual(AmountParser.minorUnits(from: "125."), 12500)
    }

    func testLeadingPoint() {
        XCTAssertEqual(AmountParser.minorUnits(from: ".5"), 50)
    }

    func testIndianGroupingRupeeSignAndSpacesAreIgnored() {
        XCTAssertEqual(AmountParser.minorUnits(from: " ₹1,25,000.50 "), 12500050)
    }

    func testLargestAmount() {
        XCTAssertEqual(AmountParser.minorUnits(from: "999999999999.99"), 99_999_999_999_999)
    }

    // MARK: - Rejected input

    func testEmptyAndBlank() {
        XCTAssertNil(AmountParser.minorUnits(from: ""))
        XCTAssertNil(AmountParser.minorUnits(from: "   "))
        XCTAssertNil(AmountParser.minorUnits(from: "."))
    }

    func testZero() {
        XCTAssertNil(AmountParser.minorUnits(from: "0"))
        XCTAssertNil(AmountParser.minorUnits(from: "0.00"))
    }

    func testNegative() {
        XCTAssertNil(AmountParser.minorUnits(from: "-50"))
    }

    func testTrailingLettersAreNotIgnored() {
        // Decimal(string:) alone reads "12abc" as 12.
        XCTAssertNil(AmountParser.minorUnits(from: "12abc"))
    }

    func testSecondDecimalPointIsNotIgnored() {
        // Decimal(string:) alone reads "12.34.56" as 12.34.
        XCTAssertNil(AmountParser.minorUnits(from: "12.34.56"))
    }

    func testFractionsOfAPaisaAreRejectedNotTruncated() {
        XCTAssertNil(AmountParser.minorUnits(from: "125.505"))
    }

    func testExponentNotation() {
        XCTAssertNil(AmountParser.minorUnits(from: "1e3"))
    }

    func testAmountTooLargeToStoreSafely() {
        XCTAssertNil(AmountParser.minorUnits(from: "1000000000000"))
        XCTAssertNil(AmountParser.minorUnits(from: "99999999999999999999"))
    }

    // MARK: - Editable text

    func testEditableTextForWholeRupees() {
        XCTAssertEqual(AmountParser.editableText(minorUnits: 50000), "500")
    }

    func testEditableTextKeepsBothPaiseDigits() {
        XCTAssertEqual(AmountParser.editableText(minorUnits: 12550), "125.50")
        XCTAssertEqual(AmountParser.editableText(minorUnits: 7), "0.07")
    }

    func testEditableTextHasNoGroupingSeparators() {
        XCTAssertEqual(AmountParser.editableText(minorUnits: 12500050), "125000.50")
    }

    func testEditableTextRoundTrips() {
        for units in [1, 7, 99, 100, 12550, 50000, 12500050, 99_999_999_999_999] {
            XCTAssertEqual(AmountParser.minorUnits(from: AmountParser.editableText(minorUnits: units)), units)
        }
    }
}
