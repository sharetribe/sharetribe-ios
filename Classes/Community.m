//
//  Community.m
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Community.h"

@implementation Community

+ (Community *)communityFromDict:(NSDictionary *)dict
{
    Community *community = [[Community alloc] init];
    
    community.communityId = [[NSNumber cast:dict[@"id"]] intValue];
    community.name        = [NSString cast:dict[@"name"]];
    community.domain      = [NSString cast:dict[@"domain"]];
    
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
