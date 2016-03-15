/*
 *
 * IAPValidator Class
 * NSString+Extension.m
 *
 * Author: David Worth
 * Version: 1.0
 * Last Modified: 03/15/2016
 * Copyright: 2016 Math Nerd Productions, LLC
 * LICENSE: MIT License
 *
 * Special thanks to @chown on Stack Overflow
 * for the urlencode method included in this
 * file:
 *
 * http://stackoverflow.com/users/836407/chown
 *
 */

#import "NSString+Extension.h"

@implementation NSString (Extension)

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end
