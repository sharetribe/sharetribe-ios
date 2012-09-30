//
//  User.m
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"

#import "Community.h"
#import "Location.h"
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
@synthesize badges;
@synthesize feedbacks;
@synthesize grades;
@synthesize listings;

@dynamic name;
@dynamic shortName;
@dynamic trimmedPhoneNumber;

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

- (NSString *)trimmedPhoneNumber
{
    return [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
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
    
    NSMutableDictionary *dictWithoutNullValues = [NSMutableDictionary dictionary];
    for (NSString *key in dict.allKeys) {
        id value = [dict objectOrNilForKey:key];
        if (value != nil) {
            [dictWithoutNullValues setObject:value forKey:key];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dictWithoutNullValues forKey:@"current user dict"];
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

    if ([dict objectOrNilForKey:@"location"] != nil) {
        user.location = [Location locationFromDict:[dict objectOrNilForKey:@"location"]];
    }
    
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
        
        if (user.isCurrentUser) {
            [self setCurrentUserWithDict:dict];  // refresh the persistent data, since now the dict may have more or better information
        }
    }
    
    return users;
}

@end
