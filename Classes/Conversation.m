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
@synthesize createdAt;
@synthesize updatedAt;

@synthesize listingId;
@synthesize listing;

@synthesize participations;
@dynamic participationsByOthers;

@synthesize messages;
@dynamic lastMessage;

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

- (Message *)lastMessage
{
    return [messages lastObject];
}

+ (Conversation *)conversationFromDict:(NSDictionary *)dict
{
    Conversation *conversation = [[Conversation alloc] init];
    
    conversation.conversationId = [[dict objectOrNilForKey:@"id"] intValue];
    conversation.title = [dict objectOrNilForKey:@"title"];
    conversation.status = [self conversationStatusFromString:[dict objectOrNilForKey:@"status"]];
    conversation.listingId = [[dict objectOrNilForKey:@"listing_id"] intValue];
    
    conversation.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    conversation.updatedAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"updated_at"]];
    
    NSArray *participationDicts = [dict objectOrNilForKey:@"participations"];
    conversation.participations = [Participation participationsFromArrayOfDicts:participationDicts];
    
    NSArray *messageDicts = [dict objectOrNilForKey:@"messages"];
    if (messageDicts == nil) {
        NSDictionary *lastMessageDict = [dict objectOrNilForKey:@"last_message"];
        if (lastMessageDict != nil) {
            messageDicts = [NSArray arrayWithObject:lastMessageDict];
        }
    }
    if (messageDicts != nil) {
        conversation.messages = [Message messagesFromArrayOfDicts:messageDicts withConversation:conversation];
    }
    
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
