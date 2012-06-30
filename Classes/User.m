//
//  User.m
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

#import "Community.h"

@interface User ()
@end

@implementation User

@synthesize userId;
@synthesize username;
@synthesize givenName;
@synthesize familyName;
@synthesize phoneNumber;
@synthesize description;

@synthesize avatar;
@synthesize communities;

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", givenName, familyName];
}

static User *currentUser;

+ (User *)currentUser
{
    return currentUser;
}

+ (void)setCurrentUser:(User *)user
{
    currentUser = user;
}

+ (User *)userFromDict:(NSDictionary *)dict
{
    User *user = [[User alloc] init];
    
    user.userId = [dict objectForKey:@"id"];
    user.givenName = [dict objectForKey:@"given_name"];
    user.familyName = [dict objectForKey:@"family_name"];
    user.phoneNumber = [dict objectForKey:@"phone_number"];
    user.description = [dict objectForKey:@"description"];
    
    NSArray *communityDicts = [dict objectForKey:@"communities"];
    if (communityDicts.count > 0) {
        user.communities = [Community communitiesFromArrayOfDicts:communityDicts];
    }
    
    return user;
}

+ (NSArray *)usersFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *users = [NSMutableArray array];
    
    for (NSDictionary *dict in dicts) {
        User *user = [self userFromDict:dict];
        [users addObject:user];
    }
    
    return users;
}

@end
