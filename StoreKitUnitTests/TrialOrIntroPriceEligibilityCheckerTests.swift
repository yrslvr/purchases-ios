//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TrialOrIntroPriceEligibilityCheckerTests.swift
//
//  Created by César de la Vega on 9/1/21.

import Nimble
@testable import RevenueCat
import StoreKitTest
import XCTest

class TrialOrIntroPriceEligibilityCheckerTests: XCTestCase {

    var receiptFetcher: MockReceiptFetcher!
    var trialOrIntroPriceEligibilityChecker: TrialOrIntroPriceEligibilityChecker!
    var mockIntroEligibilityCalculator: MockIntroEligibilityCalculator!
    var mockBackend: MockBackend!
    var mockProductsManager: MockProductsManager!
    var testSession: SKTestSession!
    var userDefaults: UserDefaults!

    func setupSK1() {
        receiptFetcher = MockReceiptFetcher(requestFetcher: MockRequestFetcher())
        mockIntroEligibilityCalculator = MockIntroEligibilityCalculator()
        mockBackend = MockBackend()
        let mockOperationDispatcher = MockOperationDispatcher()
        let identityManager = MockIdentityManager(mockAppUserID: "app_user")
        let mockProductsManager = MockProductsManager()
        trialOrIntroPriceEligibilityChecker =
        TrialOrIntroPriceEligibilityChecker(receiptFetcher: receiptFetcher,
                                            introEligibilityCalculator: mockIntroEligibilityCalculator,
                                            backend: mockBackend,
                                            identityManager: identityManager,
                                            operationDispatcher: mockOperationDispatcher,
                                            productsManager: mockProductsManager)
    }

    func setUpSK2WithError() throws {
        testSession = try SKTestSession(configurationFileNamed: "UnitTestsConfiguration")
        testSession.disableDialogs = true
        testSession.clearTransactions()

        receiptFetcher = MockReceiptFetcher(requestFetcher: MockRequestFetcher())
        mockIntroEligibilityCalculator = MockIntroEligibilityCalculator()
        mockBackend = MockBackend()
        let mockOperationDispatcher = MockOperationDispatcher()
        let identityManager = MockIdentityManager(mockAppUserID: "app_user")
        let mockProductsManager = PartialMockProductsManager()
        trialOrIntroPriceEligibilityChecker =
        TrialOrIntroPriceEligibilityChecker(receiptFetcher: receiptFetcher,
                                            introEligibilityCalculator: mockIntroEligibilityCalculator,
                                            backend: mockBackend,
                                            identityManager: identityManager,
                                            operationDispatcher: mockOperationDispatcher,
                                            productsManager: mockProductsManager)
    }

    func testSK1CheckTrialOrIntroPriceEligibility() {
        setupSK1()
        trialOrIntroPriceEligibilityChecker!.sk1CheckEligibility([]) { _ in
        }
    }

    func testSK1CheckTrialOrIntroPriceEligibilityFetchesAReceipt() {
        setupSK1()
        trialOrIntroPriceEligibilityChecker!.sk1CheckEligibility([]) { _ in
        }

        expect(self.receiptFetcher.receiptDataCalled).to(beTrue())
    }

    func testSK1EligibilityIsCalculatedFromReceiptData() throws {
        setupSK1()
        let stubbedEligibility = ["product_id": IntroEligibilityStatus.eligible]
        mockIntroEligibilityCalculator.stubbedCheckTrialOrIntroductoryPriceEligibilityResult = (stubbedEligibility, nil)

        var completionCalled = false
        var maybeEligibilities: [String: IntroEligibility]?
        trialOrIntroPriceEligibilityChecker!.sk1CheckEligibility([]) { (eligibilities) in
            completionCalled = true
            maybeEligibilities = eligibilities
        }

        expect(completionCalled).toEventually(beTrue())
        let receivedEligibilities = try XCTUnwrap(maybeEligibilities)
        expect(receivedEligibilities.count) == 1
    }

    func testSK1EligibilityIsFetchedFromBackendIfErrorCalculatingEligibility() throws {
        setupSK1()
        let stubbedError = NSError(domain: RCPurchasesErrorCodeDomain,
                                   code: ErrorCode.invalidAppUserIdError.rawValue,
                                   userInfo: [:])
        mockIntroEligibilityCalculator.stubbedCheckTrialOrIntroductoryPriceEligibilityResult = ([:], stubbedError)

        let stubbedEligibility = ["product_id": IntroEligibility(eligibilityStatus: IntroEligibilityStatus.eligible)]
        mockBackend.stubbedGetIntroEligibilityCompletionResult = (stubbedEligibility, nil)
        var completionCalled = false
        var maybeEligibilities: [String: IntroEligibility]?
        trialOrIntroPriceEligibilityChecker!.sk1CheckEligibility([]) { (eligibilities) in
            completionCalled = true
            maybeEligibilities = eligibilities
        }

        expect(completionCalled).toEventually(beTrue())
        let receivedEligibilities = try XCTUnwrap(maybeEligibilities)
        expect(receivedEligibilities.count) == 1
    }

    func testSK1ErrorFetchingFromBackendAfterErrorCalculatingEligibility() throws {
        setupSK1()
        let stubbedError = NSError(domain: RCPurchasesErrorCodeDomain,
                                   code: ErrorCode.invalidAppUserIdError.rawValue,
                                   userInfo: [:])
        mockIntroEligibilityCalculator.stubbedCheckTrialOrIntroductoryPriceEligibilityResult = ([:], stubbedError)

        mockBackend.stubbedGetIntroEligibilityCompletionResult = ([:], stubbedError)
        var completionCalled = false
        var maybeEligibilities: [String: IntroEligibility]?
        trialOrIntroPriceEligibilityChecker!.sk1CheckEligibility([]) { (eligibilities) in
            completionCalled = true
            maybeEligibilities = eligibilities
        }

        expect(completionCalled).toEventually(beTrue())
        let receivedEligibilities = try XCTUnwrap(maybeEligibilities)
        expect(receivedEligibilities.count) == 0
    }

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func testSK2CheckEligibilityAsync() async throws {
        try setUpSK2WithError()

        let products = ["product_id",
                        "com.revenuecat.monthly_4.99.1_week_intro",
                        "com.revenuecat.annual_39.99.2_week_intro",
                        "lifetime"]
        let expected = ["product_id": IntroEligibilityStatus.unknown,
                        "com.revenuecat.monthly_4.99.1_week_intro": IntroEligibilityStatus.eligible,
                        "com.revenuecat.annual_39.99.2_week_intro": IntroEligibilityStatus.eligible,
                        "lifetime": IntroEligibilityStatus.unknown]

        let maybeEligibilities = await trialOrIntroPriceEligibilityChecker!.sk2CheckEligibility(products)
        let receivedEligibilities = try XCTUnwrap(maybeEligibilities)
        expect(receivedEligibilities.count) == expected.count

        for (product, receivedEligibility) in receivedEligibilities {
            expect(receivedEligibility.status) == expected[product]
        }
    }

    @available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
    func testCheckEligibilityNoAsync() throws {
        try setUpSK2WithError()

        let products = ["product_id",
                        "com.revenuecat.monthly_4.99.1_week_intro",
                        "com.revenuecat.annual_39.99.2_week_intro",
                        "lifetime"]
        let expected = ["product_id": IntroEligibilityStatus.unknown,
                        "com.revenuecat.monthly_4.99.1_week_intro": IntroEligibilityStatus.eligible,
                        "com.revenuecat.annual_39.99.2_week_intro": IntroEligibilityStatus.eligible,
                        "lifetime": IntroEligibilityStatus.unknown]

        var completionCalled = false
        var maybeEligibilities: [String: IntroEligibility]?
        trialOrIntroPriceEligibilityChecker!.checkEligibility(productIdentifiers: products) { eligibilities in
            completionCalled = true
            maybeEligibilities = eligibilities
        }

        expect(completionCalled).toEventually(beTrue())

        let receivedEligibilities = try XCTUnwrap(maybeEligibilities)
        expect(receivedEligibilities.count) == expected.count

        for (product, receivedEligibility) in receivedEligibilities {
            expect(receivedEligibility.status) == expected[product]
        }
    }

}
