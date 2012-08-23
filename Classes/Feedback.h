//
//  Feedback.h
//  Sharetribe
//
//  Created by Janne Käki on 8/19/12.
//
//

#import <Foundation/Foundation.h>

@class User;

@interface Feedback : NSObject

@property (strong) NSString *text;
@property (strong) NSDate *createdAt;
@property (assign) CGFloat grade;
@property (strong) User *author;
@property (strong) NSString *receiverId;
@property (assign) NSInteger conversationId;

+ (Feedback *)feedbackFromDict:(NSDictionary *)dict;
+ (NSArray *)feedbacksFromArrayOfDicts:(NSArray *)dicts;

@end
