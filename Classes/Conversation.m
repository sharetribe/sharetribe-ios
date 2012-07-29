//
//  Conversation.m
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Conversation.h"

#import "Message.h"
#import "Participation.h"
#import "User.h"
#import "NSDate+Sharetribe.h"

@implementation Conversation

@synthesize conversationId;
@synthesize title;
@synthesize status;
@synthesize listingId;
@synthesize createdAt;
@synthesize updatedAt;

@synthesize participations;
@dynamic participationsByOthers;

@synthesize messages;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.messages = [NSMutableArray array];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Conversation.class]) {
        return NO;
    }
    
    return (conversationId == [object conversationId]);
}

- (NSArray *)participationsByOthers
{
    NSMutableArray *participationsByOthers = [NSMutableArray array];
    User *currentUser = [User currentUser];
    for (Participation *participation in participations) {
        if (![participation.person isEqual:currentUser]) {
            [participationsByOthers addObject:participation];
        }
    }
    return participationsByOthers;
}

- (User *)recipient
{
    Participation *participation = [self.participationsByOthers lastObject];
    return participation.person;
}

+ (Conversation *)conversationFromDict:(NSDictionary *)dict
{
    Conversation *conversation = [[Conversation alloc] init];
    
    conversation.conversationId = [[dict objectForKey:@"id"] intValue];
    conversation.title = [dict objectForKey:@"title"];
    conversation.status = [self conversationStatusFromString:[dict objectForKey:@"status"]];
    conversation.listingId = [[dict objectForKey:@"listing_id"] intValue];
    
    conversation.createdAt = [NSDate dateFromTimestamp:[dict objectForKey:@"created_at"]];
    conversation.updatedAt = [NSDate dateFromTimestamp:[dict objectForKey:@"updated_at"]];
    
    NSArray *participationDicts = [dict objectForKey:@"participations"];
    conversation.participations = [Participation participationsFromArrayOfDicts:participationDicts];
    
    NSArray *messageDicts = [dict objectForKey:@"messages"];
    conversation.messages = [Message messagesFromArrayOfDicts:messageDicts withConversation:conversation];
    
    return conversation;
}

+ (NSArray *)conversationsFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *conversations = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary *dict in dicts) {
        Conversation *conversation = [self conversationFromDict:dict];
        [conversations addObject:conversation];
    }
    
    return conversations;
}

+ (ConversationStatus)conversationStatusFromString:(NSString *)statusString
{
    if ([statusString isEqualToString:@"free"]) {
        return ConversationStatusFree;
    } else if ([statusString isEqualToString:@"pending"]) {
        return ConversationStatusPending;
    }
    return -1;
}

+ (NSString *)stringFromConversationStatus:(ConversationStatus)status
{
    if (status == ConversationStatusFree) {
        return @"free";
    } else if (status == ConversationStatusPending) {
        return @"pending";
    }
    return nil;
}

@end
