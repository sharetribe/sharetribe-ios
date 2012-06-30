//
//  User.h
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong) NSString *userId;
@property (strong) NSString *username;
@property (strong) NSString *givenName;
@property (strong) NSString *familyName;
@property (strong) NSString *phoneNumber;
@property (strong) NSString *description;

@property (strong) UIImage *avatar;
@property (strong) NSArray *communities;

@property (readonly) NSString *name;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;

+ (User *)userFromDict:(NSDictionary *)dict;
+ (NSArray *)usersFromArrayOfDicts:(NSArray *)dicts;

@end
