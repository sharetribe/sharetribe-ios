//
//  Participation.m
//  Sharetribe
//
//  Created by Janne Käki on 7/26/12.
//
//

#import "Participation.h"

#import "User.h"
#import "NSDate+Sharetribe.h"

@implementation Participation

@synthesize person;
@synthesize lastSentAt;
@synthesize lastReceivedAt;
@synthesize isRead;
@synthesize feedbackSkipped;

+ (Participation *)participationFromDict:(NSDictionary *)dict
{
    Participation *participation = [[Participation alloc] init];
    
    participation.person = [User userFromDict:[dict objectOrNilForKey:@"person"]];
    participation.lastSentAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"last_sent_at"]];
    participation.lastReceivedAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"last_received_at"]];
    participation.isRead = [[dict objectOrNilForKey:@"is_read"] boolValue];
    participation.feedbackSkipped = [[dict objectOrNilForKey:@"feedback_skipped"] boolValue];
    
    return participation;
}

+ (NSArray *)participationsFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *participations = [NSMutableArray arrayWithCapacity:dicts.count];
    
    for (NSDictionary *dict in dicts) {
        Participation *participation = [self participationFromDict:dict];
        [participations addObject:participation];
    }
    
    return participations;
}

@end
