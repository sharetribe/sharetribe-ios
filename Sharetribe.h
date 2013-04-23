//
//  Sharetribe.h
//  Sharetribe
//
//  Created by Janne Käki on 7/28/12.
//
//

#import "AppDelegate.h"
#import "Community.h"
#import "NSArray+Sharetribe.h"
#import "NSDate+Sharetribe.h"
#import "NSDictionary+Sharetribe.h"
#import "NSObject+Sharetribe.h"
#import "UIColor+Sharetribe.h"
#import "UIImage+Sharetribe.h"
#import "UIView+Sharetribe.h"
#import "GTMNSString+HTML.h"

#import <QuartzCore/QuartzCore.h>

// Colors

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kSharetribeBackgroundColor     [UIColor whiteColor]
#define kSharetribeThemeColor          ([AppDelegate sharedAppDelegate].community.color1 ?: [UIColor colorWithRed:212/255.0 green:82/255.0 blue:7/255.0 alpha:1])
#define kSharetribeSecondaryThemeColor ([AppDelegate sharedAppDelegate].community.color2 ?: kSharetribeThemeColor)
#define kSharetribeLightThemeColor     [kSharetribeThemeColor colorWithAlphaComponent:0.3]

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