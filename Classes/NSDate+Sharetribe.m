//
//  NSDate+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Sharetribe.h"

@implementation NSDate (Sharetribe)

- (NSString *)agestamp
{
    NSTimeInterval interval = -[self timeIntervalSinceNow];
    if (interval < kOneHour) {
        int minutes = (int)(interval/kOneMinute);
        if (minutes == 0) {
            return NSLocalizedString(@"agestamp.just_now", @"");
        } else if (minutes == 1) {
            return NSLocalizedString(@"agestamp.one_minute_ago", @"");
        }
        NSString *minutesFormat = NSLocalizedString(@"agestamp.format.minutes_ago", @"");
        return [NSString stringWithFormat:minutesFormat, minutes];
    } else if (interval < kOneDay) {
        int hours = (int)(interval/kOneHour);
        if (hours == 1) {
            return NSLocalizedString(@"agestamp.one_hour_ago", @"");
        }
        NSString *hoursFormat = NSLocalizedString(@"agestamp.format.hours_ago", @"");
        return [NSString stringWithFormat:hoursFormat, hours];
    } else {
        int days = (int)(interval/kOneDay);
        if (days == 1) {
            return NSLocalizedString(@"agestamp.one_day_ago", @"");
        }
        NSString *daysFormat = NSLocalizedString(@"agestamp.format.days_ago", @"");
        return [NSString stringWithFormat:daysFormat, days];
    }
}

- (NSString *)timestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromTimestamp:(NSString *)timestamp
{
    timestamp = [timestamp stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kTimestampFormatInAPI;
    return [formatter dateFromString:timestamp];
}

@end
