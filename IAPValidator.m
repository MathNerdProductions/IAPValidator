/*
 *
 * IAPValidator Class
 * IAPValidator.m
 *
 * Author: David Worth
 * Version: 1.0
 * Last Modified: 03/15/2016
 * Copyright: 2016 Math Nerd Productions, LLC
 * LICENSE: MIT License
 *
 */

#import "IAPValidator.h"


@implementation IAPValidator : NSObject

- (id)initWithBundleID:(NSString *)bundleID withProductID:(NSString *)productID withScriptURL:(NSString *)scriptURL usesProduction:(BOOL)production
{
    self = [super init];
    if(self)
    {
        _bundleID = bundleID;
        _productID = productID;
        _scriptURL = scriptURL;
        _production = production;
    }
    return self;
}

- (void)start
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSString* connectionStatus = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/serverStatus.php", _scriptURL]] encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if([connectionStatus isEqualToString:@"200"])
            {
                [self next];
            }
            else
            {
                [_delegate validationFinished:self withStatus:IAPValidatorStatusFailedConnection];
            }
            
        });
        
    });
}

- (void)next
{
    NSURL* receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData* receipt = [NSData dataWithContentsOfURL:receiptURL];
    
    NSString* vUString = [NSString stringWithFormat:@"%@/greceipt%@.php?receipt=%@", _scriptURL, (_production ? @"" : @"-sandbox"), [[receipt base64EncodedStringWithOptions:0] urlencode]];
    NSURL* vURL = [NSURL URLWithString:vUString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* response = [NSString stringWithContentsOfURL:vURL encoding:NSUTF8StringEncoding error:nil];
        NSDictionary* dr = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        int status = [dr[@"status"] intValue];
        NSLog(@"IAP Status: %d", status);
        
        _response = status;
        
        if(status == 0)
        {
            //Check bundle id and in_app:product_id
            NSString* bundleID = @"";
            NSString* productID = @"";
            
            if([dr objectForKey:@"receipt"] != nil)
            {
                if([dr[@"receipt"] objectForKey:@"bundle_id"] != nil)
                    bundleID = dr[@"receipt"][@"bundle_id"];
                
                if([dr[@"receipt"] objectForKey:@"in_app"] != nil)
                {
                    if([dr[@"receipt"][@"in_app"] isKindOfClass:[NSArray class]] && ((NSArray*)dr[@"receipt"][@"in_app"]).count > 0)
                    {
                        if([dr[@"receipt"][@"in_app"][0] objectForKey:@"product_id"] != nil)
                            productID = dr[@"receipt"][@"in_app"][0][@"product_id"];
                    }
                }
            }
            
            NSLog(@"\nBundle ID: %@\nProduct ID: %@", bundleID, productID);
            
            if([bundleID isEqualToString:_bundleID] && [productID isEqualToString:_productID])
            {
                //Success
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate validationFinished:self withStatus:IAPValidatorStatusSuccess];
                });
            }
            else if([bundleID isEqualToString:_bundleID])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate validationFinished:self withStatus:IAPValidatorStatusFailedBadProductID];
                });
            }
            else if([productID isEqualToString:_productID])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate validationFinished:self withStatus:IAPValidatorStatusFailedBadBundleID];
                });
            }
            else
            {
                //Error
                //False receipt
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate validationFinished:self withStatus:IAPValidatorStatusFailedBadBundleAndProductID];
                });
            }
        }
        else
        {
            //Receipt status failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate validationFinished:self withStatus:IAPValidatorStatusFailedBadReceipt];
            });
        }
    });
}

@end
