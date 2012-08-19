//
//  Conversation.h
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Listing;
@class Message;
@class User;

typedef enum {
    ConversationStatusFree = 0,
    ConversationStatusPending
} ConversationStatus;

@interface Conversation : NSObject

@property (assign) NSInteger conversationId;
@property (strong) NSString *title;
@property (assign) ConversationStatus status;
@property (strong) NSDate *createdAt;
@property (strong) NSDate *updatedAt;

@property (assign) NSInteger listingId;
@property (strong) Listing *listing;

@property (strong) NSArray *participations;
@property (readonly) NSArray *participationsByOthers;
@property (readonly) User *recipient;

@property (strong) NSArray *messages;
@property (readonly) Message *lastMessage;

+ (Conversation *)conversationFromDict:(NSDictionary *)dict;
+ (NSArray *)conversationsFromArrayOfDicts:(NSArray *)dicts;

+ (ConversationStatus)conversationStatusFromString:(NSString *)statusString;
+ (NSString *)stringFromConversationStatus:(ConversationStatus)status;

@end
