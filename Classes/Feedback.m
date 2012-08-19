//
//  Feedback.m
//  Sharetribe
//
//  Created by Janne Käki on 8/19/12.
//
//

#import "Feedback.h"

#import "NSDate+Sharetribe.h"

@implementation Feedback

@synthesize text;
@synthesize createdAt;
@synthesize grade;
@synthesize authorId;
@synthesize receiverId;
@synthesize conversationId;

+ (Feedback *)feedbackFromDict:(NSDictionary *)dict
{
    Feedback *feedback = [[Feedback alloc] init];
    
    feedback.text = [dict objectOrNilForKey:@"text"];
    feedback.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    feedback.grade = [[dict objectOrNilForKey:@"grade"] floatValue];
    feedback.authorId = [dict objectOrNilForKey:@"author_id"];
    feedback.receiverId = [dict objectOrNilForKey:@"receiver_id"];
    feedback.conversationId = [[dict objectOrNilForKey:@"conversation_id"] intValue];
    
    return feedback;
}

+ (NSArray *)feedbacksFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *feedbacks = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary *dict in dicts) {
        Feedback *feedback = [self feedbackFromDict:dict];
        [feedbacks addObject:feedback];
    }
    
    return feedbacks;
}

@end
