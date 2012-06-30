//
//  Community.m
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Community.h"

@implementation Community

@synthesize communityId;
@synthesize name;
@synthesize domain;

+ (Community *)communityFromDict:(NSDictionary *)dict
{
    Community *community = [[Community alloc] init];
    
    community.communityId = [[dict objectForKey:@"id"] intValue];
    community.name = [dict objectForKey:@"name"];
    community.domain = [dict objectForKey:@"domain"];
    
    return community;
}

+ (NSArray *)communitiesFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *communities = [NSMutableArray array];
    for (NSDictionary *dict in dicts) {
        Community *community = [self communityFromDict:dict];
        [communities addObject:community];
    }
    return communities;
}

@end
