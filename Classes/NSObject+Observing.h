//
//  NSObject+Observing.h
//  Sharetribe
//
//  Created by Janne Käki on 8/13/12.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Observing)

- (void)observeNotification:(NSString *)notification withSelector:(SEL)selector;
- (void)stopObservingAllNotifications;

@end
