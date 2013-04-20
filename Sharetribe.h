//
//  Sharetribe.h
//  Sharetribe
//
//  Created by Janne Käki on 7/28/12.
//
//

#import "NSArray+Sharetribe.h"
#import "NSDate+Sharetribe.h"
#import "NSDictionary+Sharetribe.h"
#import "NSObject+Sharetribe.h"
#import "UIColor+Sharetribe.h"
#import "UIImage+Sharetribe.h"
#import "UIView+Sharetribe.h"

// Colors

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kSharetribeLightBrownColor     [UIColor whiteColor]
#define kSharetribeLightishBrownColor  [UIColor colorWithRed:247/255.0 green:245/255.0 blue:230/255.0 alpha:1]
#define kSharetribeBrownColor          [UIColor colorWithRed:209/255.0 green:201/255.0 blue:180/255.0 alpha:1]
#define kSharetribeDarkBrownColor      [UIColor colorWithRed:118/255.0 green: 93/255.0 blue: 58/255.0 alpha:1]
#define kSharetribeDarkGreenColor      [UIColor colorWithRed: 50/255.0 green: 85/255.0 blue: 14/255.0 alpha:1]
#define kSharetribeLightOrangeColor    [UIColor colorWithRed:231/255.0 green:183/255.0 blue:141/255.0 alpha:1]
#define kSharetribeDarkOrangeColor     [UIColor colorWithRed:212/255.0 green: 82/255.0 blue:  7/255.0 alpha:1]

// Timestamps

#define kTimestampFormatInAPI     @"yyyy-MM-dd'T'HHmmssZ"
#define kDateFormat               @"dd.MM.yyyy"
#define kDateAndTimeFormat        @"dd.MM.yyyy  HH:mm"

// Notifications

#define kNotificationForDidFlipView         @"did flip view"
#define kNotificationForDidChangeRegion     @"did change region"
#define kNotificationForDidSelectCommunity  @"did select community"

// User defaults keys

#define kDefaultsKeyForViewChoice           @"view choice"
#define kDefaultsKeyForDeviceToken          @"device token"

// Miscellaneous

#define kFirstPage 1

#define kValidForTheTimeBeing               @"for_the_time_being"