//
//  Badge.m
//  Sharetribe
//
//  Created by Janne Käki on 8/19/12.
//
//

#import "Badge.h"

#import "NSDate+Sharetribe.h"

@implementation Badge

@synthesize badgeId;
@synthesize name;
@synthesize description;
@synthesize createdAt;
@synthesize pictureURL;

+ (Badge *)badgeFromDict:(NSDictionary *)dict
{
    Badge *badge = [[Badge alloc] init];
    
    badge.badgeId = [[dict objectOrNilForKey:@"id"] intValue];
    badge.name = [dict objectOrNilForKey:@"name"];
    badge.description = [dict objectOrNilForKey:@"description"];
    badge.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    badge.pictureURL = ([dict objectOrNilForKey:@"picture_url"] != nil) ? [NSURL URLWithString:[dict objectOrNilForKey:@"picture_url"]] : nil;
    
    return badge;
}

+ (NSArray *)badgesFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *badges = [NSMutableArray array];
    
    for (NSDictionary *dict in dicts) {
        Badge *badge = [self badgeFromDict:dict];
        [badges addObject:badge];
    }
    
    return badges;
}

@end
