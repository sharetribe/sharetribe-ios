//
//  NSObject+Observing.m
//  Sharetribe
//
//  Created by Janne Käki on 8/13/12.
//
//

#import "NSObject+Observing.h"

@implementation NSObject (Observing)

- (void)observeNotification:(NSString *)notification withSelector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:notification object:nil];
}

- (void)stopObservingAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
