//
//  APIClient.m
//  Kassi
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SharetribeAPIClient.h"

#import "AFNetworking.h"
#import "Community.h"
#import "Listing.h"
#import "User.h"
#import <YAJLiOS/YAJL.h>

#define kAPITokenKeyForUserDefaults        @"API token"
#define kCurrentUserIdKeyForUserDefaults   @"current user id"

@implementation SharetribeAPIClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SharetribeAPIClient, sharedClient);

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"http://api.sharetribe.fi"]];
    if (self != nil) {
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/vnd.sharetribe+json; version=alpha"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults objectForKey:kAPITokenKeyForUserDefaults];        
        if (token != nil) {
            [self setDefaultHeader:@"Sharetribe-API-Token" value:token];
        }
    }
    return self;
}

- (BOOL)isLoggedIn
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAPITokenKeyForUserDefaults];  
    return (token != nil);
}

- (void)logInWithUsername:(NSString *)username password:(NSString *)password
{
    NSLog(@"logging in: %@/%@", username, password);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (username != nil && password != nil) {
        [params setValue:username forKey:@"username"];
        [params setValue:password forKey:@"password"];
    }
        
    [self postPath:@"tokens" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"logged in: %@", responseObject);
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSString *token = [responseObject objectForKey:@"api_token"];
            [self setDefaultHeader:@"Sharetribe-API-Token" value:token];            
            
            NSDictionary *currentUserDict = [responseObject objectForKey:@"person"];
            [User setCurrentUserWithDict:currentUserDict];
            User *user = [User currentUser];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:kAPITokenKeyForUserDefaults];
            [defaults setObject:user.userId forKey:kCurrentUserIdKeyForUserDefaults];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUserDidLogIn object:user];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginAuthDidFail object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginConnectionDidFail object:nil];
        }
        NSLog(@"failed to log in: %@", error);
    }];
}

- (void)logOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAPITokenKeyForUserDefaults];
    [defaults removeObjectForKey:kCurrentUserIdKeyForUserDefaults];
    [defaults synchronize];
    
    [self setDefaultHeader:@"Sharetribe-API-Token" value:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUserDidLogOut object:nil];
}

- (void)getListings
{
    NSMutableDictionary *params = [self basicParams];
    
    [self getPath:@"listings" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"got listings for params: %@\nwith result: %@", params, responseObject);
        NSArray *listings = [Listing listingsFromArrayOfDicts:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListings object:listings];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get listings for params: %@\nerror: %@", params, error);
    }];
}

- (void)getListingWithId:(NSInteger)listingId
{
    NSMutableDictionary *params = [self basicParams];
    
    [self getPath:[NSString stringWithFormat:@"listings/%d.json", listingId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"got listing for id %d with result: %@", listingId, responseObject);
        Listing *listing = [Listing listingFromDict:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListingDetails object:listing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get listing with id %d: %@", listingId, error);
    }];
}

- (void)postNewListing:(Listing *)listing
{
    NSMutableDictionary *params = [self basicParams];
    [params addEntriesFromDictionary:[listing asJSON]];
    
    [self postPath:@"listings" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"posted new listing: %@\nwith result: %@", params, responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidPostListing object:listing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to post new listing: %@\nerror: %@\nresponse: %@", params, error, operation.responseString);
        // NSLog(@"%@", operation.request.allHTTPHeaderFields);
        // NSLog(@"%@", [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSASCIIStringEncoding]);
    }];
}

- (void)getUserWithId:(NSString *)userId
{
    [self getPath:[NSString stringWithFormat:@"users/%@.json", userId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"got user with id %@: %@", userId, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get user with id %@: %@", userId, error);
    }];
}

- (void)refreshCurrentUser
{
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserIdKeyForUserDefaults];
    if (currentUserId != nil) {
        [self getUserWithId:currentUserId];
    }
}

- (NSMutableDictionary *)basicParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    User *user = [User currentUser];
    if (user.currentCommunity != nil) {
        [params setObject:[NSNumber numberWithInt:user.currentCommunity.communityId] forKey:@"community_id"];
    }
    
    return params;
}

@end
