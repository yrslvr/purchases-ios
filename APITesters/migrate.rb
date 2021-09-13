#!/usr/bin/ruby
swift_old_to_new = { "import Purchases" => "import RevenueCat", 
   "Purchases.Offering" => "Offering",
   "Purchases.Package" => "Package",
   "Purchases.EntitlementInfo" => "EntitlementInfo",
   "Purchases.ErrorUtils" => "ErrorUtils",
   "Purchases.RevenueCatBackendErrorCode" => "BackendErrorCode",
   "Purchases.ErrorCode.Code" => "ErrorCode",
   "Purchases.PurchaseCompletedBlock" => "PurchaseCompletedBlock",
   "Purchases.LogLevel" => "LogLevel",
   "Purchases.Transaction" => "Transaction",
   "operationAlreadyInProgressError" => "operationAlreadyInProgressForProductError",
   "Purchases.Store" => "Store",
   "Purchases.PeriodType" => "PeriodType",
   "RCPurchaseOwnershipType" => "PurchaseOwnershipType",
   "RCAttributionNetwork" => "AttributionNetwork",
   "Purchases.PurchaserInfo" => "PurchaserInfo",
   "Purchases.ReceivePurchaserInfoBlock" => "ReceivePurchaserInfoBlock",
   "Purchases.ReceiveOfferingsBlock" => "ReceiveOfferingsBlock",
   "Purchases.ReceiveProductsBlock" => "ReceiveProductsBlock",
   "RCIntroEligibility" => "IntroEligibility",
   "ReadableErrorCodeKey" => "ErrorDetails.readableErrorCodeKey",
   "Purchases.ReadableErrorCodeKey" => "ErrorDetails.readableErrorCodeKey",
   "RCFinishableKey" => "ErrorDetails.finishableKey",
   "Purchases.FinishableKey" => "ErrorDetails.finishableKey",
   "Purchases.PaymentDiscountBlock" => "PaymentDiscountBlock",
   "RCDeferredPromotionalPurchaseBlock" => "DeferredPromotionalPurchaseBlock",
   ".purchaserInfo(completionBlock: " => ".purchaserInfo(",
   ".offerings(completionBlock: " => ".offerings(",
   ".products(identifiers: " => ".products(",
   ".purchaseProduct(" => ".purchase(product: ",
   ".purchasePackage(" => ".purchase(package: ",
   ".paymentDiscount(for:" => ".paymentDiscount(forProductDisount:" }


objc_old_to_new = { "RCPurchasesErrorDomain" => "test", 
   "PurchaserInfo" => "maddie" }

Dir.glob('**/*.swift') do |file_name|
   print("in dir.glob for #{file_name}")
   text = File.read(file_name)

   swift_old_to_new.each do |old, new|
      print("replacing #{old} with #{new}\n")
      replace = text.gsub!(old, new)
      if (replace != nil && replace.length != 0)
         print("replace is #{replace}\n")
         File.open(file_name, "w") { |file| file.puts replace }
      end
   end
end

Dir.glob('../**/*.m') do |file_name|
   print("in dir.glob for #{file_name}")
   text = File.read(file_name)

   swift_old_to_new.each do |old, new|
      print("replacing #{old} with #{new}\n")
      replace = text.gsub!(old, new)
      if (replace != nil && replace.length != 0)
         print("replace is #{replace}\n")
         File.open(file_name, "w") { |file| file.puts replace }
      end
   end
end



# keys of assoc array ${!array[@]}
# values of assoc array ${array[@]} 