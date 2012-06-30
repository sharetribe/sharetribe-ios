//
//  MessageThread.m
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageThread.h"

@implementation MessageThread

@synthesize subject;
@synthesize messages;
@synthesize recipient;
@dynamic date;
@synthesize hasUnreadMessages;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (NSDate *)date
{
    return [[messages lastObject] date];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:MessageThread.class]) {
        return NO;
    }
    
    return [messages.lastObject isEqual:[object messages].lastObject];
}

@end
