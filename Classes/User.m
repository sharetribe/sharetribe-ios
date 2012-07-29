//
//  User.m
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

#import "Community.h"
#import "NSDictionary+Sharetribe.h"

@interface User ()
@end

@implementation User

@synthesize userId;
@synthesize username;
@synthesize givenName;
@synthesize familyName;
@synthesize phoneNumber;
@synthesize description;

@synthesize pictureURL;
@synthesize thumbnailURL;

@synthesize communities;

@dynamic name;
@dynamic shortName;

@dynamic isCurrentUser;

static User *currentUser = nil;

- (NSString *)name
{
    return [NSString stringWithFormat:@"%@ %@", givenName, familyName];
}

- (NSString *)shortName
{
    if (familyName.length >= 1) {
        return [NSString stringWithFormat:@"%@ %@.", givenName, [familyName substringToIndex:1]];
    } else {
        return givenName;
    }
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:User.class]) {
        return NO;
    }
    return [userId isEqual:[object userId]];
}

- (BOOL)isCurrentUser
{
    return [self isEqual:[User currentUser]];
}

+ (User *)currentUser
{
    if (currentUser == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *currentUserDict = [defaults objectForKey:@"current user dict"];
        currentUser = [User userFromDict:currentUserDict];
    }
    return currentUser;
}

+ (void)setCurrentUserWithDict:(NSDictionary *)dict
{
    currentUser = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dict forKey:@"current user dict"];
    [defaults synchronize];
}

+ (User *)userFromDict:(NSDictionary *)dict
{
    User *user = [[User alloc] init];
    
    user.userId = [dict objectOrNilForKey:@"id"];
    user.givenName = [dict objectOrNilForKey:@"given_name"];
    user.familyName = [dict objectOrNilForKey:@"family_name"];
    user.phoneNumber = [dict objectOrNilForKey:@"phone_number"];
    user.description = [dict objectOrNilForKey:@"description"];
    
    if ([dict objectOrNilForKey:@"picture_url"] != nil) {
        user.pictureURL = [NSURL URLWithString:[dict objectOrNilForKey:@"picture_url"]];
    }
    if ([dict objectOrNilForKey:@"thumbnail_url"] != nil) {
        user.thumbnailURL = [NSURL URLWithString:[dict objectOrNilForKey:@"thumbnail_url"]];
    }
    
    NSArray *communityDicts = [dict objectOrNilForKey:@"communities"];
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
