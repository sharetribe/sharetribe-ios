//
//  Message.h
//  Sharetribe
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Conversation;
@class User;

@interface Message : NSObject

@property (strong) User *author;
@property (strong) NSString *content;
@property (strong) NSDate *createdAt;

- (NSDictionary *)asJSON;

+ (Message *)messageWithAuthor:(User *)author content:(NSString *)content createdAt:(NSDate *)createdAt;
+ (Message *)messageFromDict:(NSDictionary *)dict;
+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts;
+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts withConversation:(Conversation *)conversation;

@end
