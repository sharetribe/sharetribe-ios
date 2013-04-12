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

@property (strong) NSURL *logoURL;
@property (strong) NSURL *coverPhotoURL;
@property (strong) UIColor *color1;
@property (strong) UIColor *color2;

+ (Community *)communityFromDict:(NSDictionary *)dict;
+ (NSArray *)communitiesFromArrayOfDicts:(NSArray *)dicts;

@end
