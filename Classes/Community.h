//
//  Community.h
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Community : NSObject

@property (assign) NSInteger communityId;
@property (strong) NSString *name;
@property (strong) NSString *domain;

+ (Community *)communityFromDict:(NSDictionary *)dict;
+ (NSArray *)communitiesFromArrayOfDicts:(NSArray *)dicts;

@end
