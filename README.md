# IAPValidator
In-App-Purchase Validator for iOS

# Get Started
This build comes in 2 parts:

1. PHP scripts
2. Obj-C files

The first thing you'll want to do is to place the 3 .php files in the same directory on your server.

- greceipt-sandbox.php
- greceipt.php
- serverStatus.php

It doesn't matter where they go, but they all need to be in the same directory and at the same level within the directory.

Once you've done that, import the following files into your XCode project:

- IAPValidator.h
- IAPValidator.m
- NSString+Extension.h
- NSString+Extension.m

# Using IAPValidator

The next step will be importing IAPValidator.h into your view controller:

    #import "IAPValidator.h"

You will need to assign a delegate to implement the necessary callback function on the IAPValidator. Typically, this is your view controller, but you are free to use whatever class you like.

    @interface ViewController : UIViewController <IAPValidatorDelegate>

Next, you'll want to implement the following method on your delegate:

    - (void)validationFinished:(IAPValidator*)validator withStatus:(IAPValidatorStatus)status;

This method provides all of the updates for the validation itself. It provides the validator itself as well as the status code as an IAPValidatorStatus enum. Here are the values of IAPValidatorStatus:

    IAPValidatorStatusSuccess (the purchase was validated)
    IAPValidatorStatusFailedConnection (unable to connect to the server)
    IAPValidatorStatusFailedBadReceipt (iTunes was unable to validate the receipt)
    IAPValidatorStatusFailedBadBundleID (the bundle ID does not match the bundle ID provided)
    IAPValidatorStatusFailedBadProductID (the productID does not match the product ID provided)
    IAPValidatorStatusFailedBadBundleAndProductID (both the bundle ID and the product ID don't match those provided)
    IAPValidatorStatusFailedUnknown (an unknown error occurred; this is not implemented at this time)

Switch on the value of `@param status` with the above list and perform the appropriate actions within your app. You can retrieve the specific IAP product id with `validator.productID`.

##Bad Receipt Status Codes

iTunes does provide some additional details when a validation fails. If you receive an `IAPValidatorStatusFailedBadReceipt` status from the validator, you can check the validator's `validator.response` value to get more details as to why the validation failed.

Here are the status codes available:

    IAPServerCodeSuccess (the receipt was validated)
    IAPServerCodeUnableToRead (iTunes was unable to read the JSON object)
    IAPServerCodeBadReceiptData (the receipt data was invalid)
    IAPServerCodeCantAuthenticate (the receipt was successfully checked and found to be invalid)
    IAPServerCodeBadSharedSecret (an incorrect shared secret was provided)
    IAPServerCodeServerUnavailable (the iTunes server was not available)
    IAPServerCodeSubscriptionExpired (the receipt was valid, but the subscription was expired)
    IAPServerCodeWrongEnvironmentUseSandbox (the receipt was sent to the production server, but should have gone to the sandbox)
    IAPServerCodeWrongEnvironmentUseProduction (the receipt was sent to the sandbox server, but should have gone to production)

##Additional notes on Shared Secrets

At this time, the validator does not allow you to set shared secrets. If you wish to pass a shared secret for subscription IAPs, you'll have to override the PHP files to transmit your shared secret alongside the receipt data.

#Starting an IAPValidation

The final thing to do is to actually start an IAPValidation.

In the StoreKit method, `(void)paymentQueue:updatedTransactions`, add the following:

    for(SKPaymentTransaction* transaction in transactions)
    {
        switch(transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
              IAPValidator* iapv = [[IAPValidator alloc] initWithBundleID:@"your-bundle-id"
                                                            withProductID:@"your-product-id"
                                                            withScriptURL:@url-to-your-server-script-directory
                                                           usesProduction:[bool yes or no]];
              iapv.delegate = self;
              [iapv start];
            }
          }
    }

#And that's it!
