//
//  Community.m
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Community.h"

#import "Location.h"

@implementation Community

+ (Community *)communityFromDict:(NSDictionary *)dict
{
    Community *community = [[Community alloc] init];
    
    community.communityId = [[NSNumber cast:dict[@"id"]] intValue];
    community.name        = [NSString cast:dict[@"name"]];
    community.domain      = [NSString cast:dict[@"domain"]];
    
    community.color1 = [UIColor colorWithHexString:[NSString cast:dict[@"custom_color1"]]];
    community.color2 = [UIColor colorWithHexString:[NSString cast:dict[@"custom_color2"]]];
        
    community.location = [Location locationFromDict:[NSDictionary cast:dict[@"location"]]];
    
    community.categoriesTree = [NSDictionary cast:dict[@"categories_tree"]];
    community.availableCurrencies = [NSArray cast:dict[@"available_currencies"]];
    
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
