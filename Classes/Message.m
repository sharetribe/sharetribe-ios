//
//  Message.m
//  Sharetribe
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "Conversation.h"
#import "Participation.h"
#import "User.h"
#import "NSDate+Sharetribe.h"
#import "NSDictionary+Sharetribe.h"

@implementation Message

@synthesize author;
@synthesize content;
@synthesize createdAt;

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Message.class]) {
        return NO;
    }
    
    return [content isEqual:[object content]] && [author isEqual:[object author]] && [createdAt isEqual:[object createdAt]];
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    [JSON setObject:content forKey:@"content"];
    
    return JSON;
}

+ (Message *)messageWithAuthor:(User *)theAuthor content:(NSString *)theContent createdAt:(NSDate *)theCreatedAt
{
    Message *message = [[Message alloc] init];
    
    message.author = theAuthor;
    message.content = theContent;
    message.createdAt = theCreatedAt;
    
    return message;
}

+ (Message *)messageFromDict:(NSDictionary *)dict
{
    Message *message = [[Message alloc] init];
    
    message.author = [User userFromDict:[dict objectOrNilForKey:@"author"]];
    message.content = [dict objectOrNilForKey:@"content"];
    message.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    
    return message;
}

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts
{
    return [self messagesFromArrayOfDicts:dicts withConversation:nil];
}

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts withConversation:(Conversation *)conversation
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:dicts.count];
    
    NSMutableDictionary *participantsById = nil;
    if (conversation != nil) {
        participantsById = [NSMutableDictionary dictionary];
        for (Participation *participation in conversation.participations) {
            if (participation.person.userId != nil) {
                [participantsById setObject:participation.person forKey:participation.person.userId];
            }
        }
    }
    
    for (NSDictionary *dict in dicts) {
        Message *message = [Message messageFromDict:dict];
        if (conversation != nil) {
            NSString *senderId = [dict objectOrNilForKey:@"sender_id"];
            message.author = [participantsById objectOrNilForKey:senderId];
        }
        [messages addObject:message];
    }
    
    return messages;
}

@end
