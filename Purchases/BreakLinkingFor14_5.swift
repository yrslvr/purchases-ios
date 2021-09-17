//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  BreakLinkingFor14_5.swift
//
//  Created by Andrés Boedo on 9/17/21.

import Foundation
import StoreKit

@available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
@objc(RCSK2ProductDetails) public class SK2ProductDetails: NSObject {

    init(sk2Product: StoreKit.Product) {
        self.underlyingSK2Product = sk2Product
    }

    public let underlyingSK2Product: StoreKit.Product
}
