//
//  NSObject+Observing.m
//  Sharetribe
//
//  Created by Janne Käki on 8/13/12.
//
//

#import "NSObject+Sharetribe.h"

@implementation NSObject (Sharetribe)

- (void)observeNotification:(NSString *)notification withSelector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notification object:nil];
}

- (void)stopObservingAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)cast:(id)object
{
    return [object isKindOfClass:self] ? object : nil;
}

@end
