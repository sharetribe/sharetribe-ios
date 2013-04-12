//
//  NSObject+Sharetribe.h
//  Sharetribe
//
//  Created by Janne Käki on 8/13/12.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Sharetribe)

- (void)observeNotification:(NSString *)notification withSelector:(SEL)selector;
- (void)stopObservingAllNotifications;

+ (instancetype)cast:(id)object;

@end
