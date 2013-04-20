//
//  Community.h
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;

@interface Community : NSObject

@property (assign, nonatomic) NSInteger communityId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *domain;

@property (copy, nonatomic) NSString *slogan;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *serviceName;
@property (copy, nonatomic) NSString *serviceLogoStyle;
@property (assign, nonatomic) NSInteger membersCount;

@property (strong, nonatomic) NSURL *logoURL;
@property (strong, nonatomic) NSURL *coverPhotoURL;
@property (strong, nonatomic) UIColor *color1;
@property (strong, nonatomic) UIColor *color2;

@property (strong, nonatomic) Location *location;

@property (strong, nonatomic) NSDictionary *categoriesTree;

+ (Community *)communityFromDict:(NSDictionary *)dict;
+ (NSArray *)communitiesFromArrayOfDicts:(NSArray *)dicts;

@end
