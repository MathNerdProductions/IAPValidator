/*
 *
 * IAPValidator Class
 * IAPValidator.h
 *
 * Author: David Worth
 * Version: 1.0
 * Last Modified: 03/15/2016
 * Copyright: 2016 Math Nerd Productions, LLC
 * LICENSE: MIT License
 * 
 * The IAPValidator Class provides a very simple
 * and comprehensive way to check In App Purchases
 * for legitimacy via an external server.
 *
 * In order to use the IAPValidator class, you must
 * first set up the PHP scripts on an external web
 * server that is accessible by all devices that will
 * be running your app.
 *
 * That code should be provided with this bundle.
 *
 * Simply deploy it on your server and provide any
 * instance of IAPValidator with the direct link to
 * the directory on your server that contains both
 * greceipt.php and greceipt-sandbox.php, as well
 * as serverStatus.php
 *
 * This system also requires the urlencode method
 * that is found in NSString+Extension.h
 * 
 */

#import "NSString+Extension.h"

#import <Foundation/Foundation.h>

@class IAPValidator;

typedef enum IAPValidatorStatus : NSUInteger
{
    IAPValidatorStatusSuccess = 0,
    IAPValidatorStatusFailedConnection = 1,
    IAPValidatorStatusFailedBadReceipt = 2,
    IAPValidatorStatusFailedBadBundleID = 3,
    IAPValidatorStatusFailedBadProductID = 4,
    IAPValidatorStatusFailedBadBundleAndProductID = 5,
    IAPValidatorStatusFailedUnknown = 6
} IAPValidatorStatus;

typedef enum IAPServerCode : NSUInteger
{
    IAPServerCodeSuccess = 0,
    IAPServerCodeUnableToRead = 21000,
    IAPServerCodeBadReceiptData = 21002,
    IAPServerCodeCantAuthenticate = 21003,
    IAPServerCodeBadSharedSecret = 21004,
    IAPServerCodeServerUnavailable = 21005,
    IAPServerCodeSubscriptionExpired = 21006,
    IAPServerCodeWrongEnvironmentUseSandbox = 21007,
    IAPServerCodeWrongEnvironmentUseProduction = 21008
} IAPServerCode;


@protocol IAPValidatorDelegate <NSObject>

- (void)validationFinished:(IAPValidator*)validator withStatus:(IAPValidatorStatus)status;

@end

@interface IAPValidator : NSObject

/**
 * Delegate object to receive status updates and callbacks
 */
@property (nonatomic) id<IAPValidatorDelegate> delegate;

/**
 * Your App's Bundle ID
 */
@property (nonatomic, readonly) NSString* bundleID;

/**
 * The product identifier of the In App Purchase to validate
 */
@property (nonatomic, readonly) NSString* productID;

/**
 * The URL of the directory on your server where greceipt.php
 * and greceipt-sandbox.php are located. Remember, you must
 * deploy those files before running the validator, and the 
 * files must be accesible by any device that runs your 
 * application. It is best if the scripts are all publicly
 * accessible via the Internet.
 */
@property (nonatomic, readonly) NSString* scriptURL;

/**
 * Are we validating with the sandbox or with the production
 * iTunes Store?
 */
@property (nonatomic, readonly) BOOL production;

/**
 * Server response status code. This is especially useful
 * if the validator returns an IAPValidatorStatusFailedBadReceipt
 * error.
 */
@property (nonatomic, readonly) IAPServerCode response;

- (id)initWithBundleID:(NSString*)bundleID withProductID:(NSString*)productID withScriptURL:(NSString*)scriptURL usesProduction:(BOOL)production;

- (void)start;

@end
