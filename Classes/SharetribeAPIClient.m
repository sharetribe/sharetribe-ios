//
//  APIClient.m
//  Kassi
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SharetribeAPIClient.h"

#import "AFNetworking.h"
#import "Listing.h"
#import "User.h"
#import <YAJLiOS/YAJL.h>

#define kAPITokenKeyForUserDefaults @"API token"

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
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSString *token = [responseObject objectForKey:@"api_token"];
            [self setDefaultHeader:@"Sharetribe-API-Token" value:token];            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:kAPITokenKeyForUserDefaults];
            [defaults synchronize];
            
            User *user = [User userFromDict:[responseObject objectForKey:@"person"]];
            [User setCurrentUser:user];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUserDidLogIn object:user];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginAuthDidFail object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginConnectionDidFail object:nil];
        }
        NSLog(@"%@", error);
    }];
}

- (void)logOut
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kAPITokenKeyForUserDefaults];
    [defaults synchronize];
    
    [self setDefaultHeader:@"Sharetribe-API-Token" value:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUserDidLogOut object:nil];
}

- (void)getListings
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [self getPath:@"listings" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSArray *listings = [Listing listingsFromArrayOfDicts:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListings object:listings];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)getListingWithId:(NSInteger)listingId
{
    [self getPath:[NSString stringWithFormat:@"%d.json", listingId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        Listing *listing = [Listing listingFromDict:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListingDetails object:listing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}


@end
