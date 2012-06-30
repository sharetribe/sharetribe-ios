//
//  Message.m
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize text;
@synthesize sender;
@synthesize date;

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Message.class]) {
        return NO;
    }
    
    return [text isEqual:[object text]] && [sender isEqual:[object sender]] && [date isEqual:[object date]];
}

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:dicts.count];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy HH:mm";
    
    for (NSDictionary *dict in dicts) {
        
        Message *message = [[Message alloc] init];
        message.text = [dict valueForKey:@"text"];
        
        message.sender = [User userFromDict:[dict valueForKey:@"sender"]];
        
        message.date = [formatter dateFromString:[dict valueForKey:@"date"]];
        [messages addObject:message];
    }
    
    return messages;
}

@end
