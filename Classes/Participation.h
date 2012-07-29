//
//  Participation.h
//  Sharetribe
//
//  Created by Janne Käki on 7/26/12.
//
//

#import <Foundation/Foundation.h>

@class User;

@interface Participation : NSObject

@property (strong) User *person;
@property (strong) NSDate *lastSentAt;
@property (strong) NSDate *lastReceivedAt;
@property (assign) BOOL isRead;
@property (assign) BOOL feedbackSkipped;

+ (Participation *)participationFromDict:(NSDictionary *)dict;
+ (NSArray *)participationsFromArrayOfDicts:(NSArray *)dicts;

@end
