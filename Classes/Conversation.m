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
@dynamic ownParticipation;
@dynamic otherParticipation;

@synthesize messages;
@dynamic lastMessage;
@dynamic unread;
@dynamic replied;

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

- (Participation *)ownParticipation
{
    User *currentUser = [User currentUser];
    for (Participation *participation in participations) {
        if ([participation.person isEqual:currentUser]) {
            return participation;
        }
    }
    return nil;
}

- (Participation *)otherParticipation
{
    User *currentUser = [User currentUser];
    for (Participation *participation in participations) {
        if (![participation.person isEqual:currentUser]) {
            return participation;
        }
    }
    return nil;
}

- (User *)recipient
{
    return self.otherParticipation.person;
}

- (Message *)lastMessage
{
    return [messages lastObject];
}

- (BOOL)isUnread
{
    return !self.ownParticipation.isRead;
}

- (void)setUnread:(BOOL)isUnread
{
    self.ownParticipation.isRead = !isUnread;
}

- (BOOL)isReplied
{
    return self.lastMessage.author.isCurrentUser;
}

- (NSComparisonResult)compare:(id)object
{
    if (![object isKindOfClass:Conversation.class]) {
        return NSOrderedAscending;
    }
    
    Message *otherLastMessage = [object lastMessage];
    return -[self.lastMessage.createdAt compare:otherLastMessage.createdAt];  // newer, i.e. later, message should be sorted first
}

+ (Conversation *)conversationFromDict:(NSDictionary *)dict
{
    Conversation *conversation = [[Conversation alloc] init];
    
    conversation.conversationId = [[dict objectOrNilForKey:@"id"] intValue];
    conversation.title = [dict objectOrNilForKey:@"title"];
    conversation.status = [dict objectOrNilForKey:@"status"];
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
    
    [conversations sortUsingSelector:@selector(compare:)];
    
    return conversations;
}

@end
