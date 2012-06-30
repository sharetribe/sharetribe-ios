//
//  Message.m
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "NSDictionary+Sharetribe.h"

@implementation Message

@synthesize content;
@synthesize createdAt;
@synthesize authorId;

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Message.class]) {
        return NO;
    }
    
    return [content isEqual:[object content]] && [authorId isEqual:[object authorId]] && [createdAt isEqual:[object createdAt]];
}

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:dicts.count];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kTimestampFormatInAPI;
    
    for (NSDictionary *dict in dicts) {
        
        Message *message = [[Message alloc] init];
        
        message.content = [dict objectOrNilForKey:@"content"];        
        message.createdAt = [formatter dateFromString:[dict objectOrNilForKey:@"created_at"]];
        message.authorId = [dict objectOrNilForKey:@"author_id"];
        
        [messages addObject:message];
    }
    
    return messages;
}

@end
