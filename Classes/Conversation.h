//
//  Conversation.h
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kConversationStatusFree      @"free"
#define kConversationStatusPending   @"pending"
#define kConversationStatusAccepted  @"accepted"
#define kConversationStatusRejected  @"rejected"

@class Listing;
@class Message;
@class Participation;
@class User;

@interface Conversation : NSObject

@property (assign) NSInteger conversationId;
@property (strong) NSString *title;
@property (strong) NSString *status;
@property (strong) NSDate *createdAt;
@property (strong) NSDate *updatedAt;

@property (assign) NSInteger listingId;
@property (strong) Listing *listing;

@property (strong) NSArray *participations;
@property (readonly) Participation *ownParticipation;
@property (readonly) Participation *otherParticipation;
@property (readonly) User *recipient;

@property (strong) NSArray *messages;
@property (readonly) Message *lastMessage;
@property (readonly) BOOL isUnread;
@property (readonly) BOOL isReplied;

+ (Conversation *)conversationFromDict:(NSDictionary *)dict;
+ (NSArray *)conversationsFromArrayOfDicts:(NSArray *)dicts;

@end
