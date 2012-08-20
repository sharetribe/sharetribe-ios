//
//  User.h
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Location;

@interface User : NSObject

@property (strong) NSString *userId;
@property (strong) NSString *username;
@property (strong) NSString *givenName;
@property (strong) NSString *familyName;
@property (strong) NSString *phoneNumber;
@property (strong) NSString *description;
@property (strong) Location *location;

@property (strong) NSURL *pictureURL;
@property (strong) NSURL *thumbnailURL;

@property (strong) NSArray *communities;
@property (strong) NSArray *badges;
@property (strong) NSArray *feedbacks;
@property (strong) NSArray *grades;
@property (strong) NSArray *listings;

@property (readonly) NSString *name;
@property (readonly) NSString *shortName;

@property (readonly) BOOL isCurrentUser;

+ (User *)currentUser;
+ (void)setCurrentUserWithDict:(NSDictionary *)dict;

+ (User *)userFromDict:(NSDictionary *)dict;
+ (NSArray *)usersFromArrayOfDicts:(NSArray *)dicts;

@end
