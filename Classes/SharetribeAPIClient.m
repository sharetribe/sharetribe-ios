//
//  APIClient.m
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SharetribeAPIClient.h"

#import "AFNetworking.h"
#import "Badge.h"
#import "Community.h"
#import "Conversation.h"
#import "Feedback.h"
#import "Grade.h"
#import "Listing.h"
#import "Message.h"
#import "Reachability.h"
#import "User.h"
#import "NSDictionary+Sharetribe.h"
#import "UIDevice+Sharetribe.h"
#import <YAJLiOS/YAJL.h>

#define kAPITokenKeyForUserDefaults            @"API token"
#define kCurrentUserIdKeyForUserDefaults       @"current user id"
#define kCurrentCommunityIdKeyForUserDefaults  @"current communty id"

@interface SharetribeAPIClient () {
    NSInteger currentCommunityId;
}

@property (readonly) NSMutableDictionary *baseParams;

@end

@implementation SharetribeAPIClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SharetribeAPIClient, sharedClient);

@dynamic baseParams;

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:@"https://api.sharetribe.com"]];
    if (self != nil) {
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/vnd.sharetribe+json; version=alpha"];
        [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *token = [defaults objectForKey:kAPITokenKeyForUserDefaults];        
        if (token != nil) {
            [self setDefaultHeader:@"Sharetribe-API-Token" value:token];
        }
        
        if ([defaults objectForKey:kCurrentCommunityIdKeyForUserDefaults]) {
            currentCommunityId = [[defaults objectForKey:kCurrentCommunityIdKeyForUserDefaults] integerValue];
        } else {
            currentCommunityId = NSNotFound;
        }
    }
    return self;
}

- (NSInteger)currentCommunityId
{
    return currentCommunityId;
}

- (void)setCurrentCommunityId:(NSInteger)newCurrentCommunityId
{
    currentCommunityId = newCurrentCommunityId;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:currentCommunityId forKey:kCurrentCommunityIdKeyForUserDefaults];
    [defaults synchronize];
}

- (BOOL)isLoggedIn
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:kAPITokenKeyForUserDefaults];  
    return (token != nil);
}

- (BOOL)hasInternetConnectivity
{
    return ([Reachability reachabilityForInternetConnection].currentReachabilityStatus != NotReachable);
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
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        if ([responseObject isKindOfClass:NSDictionary.class]) {
            NSString *token = [responseObject objectForKey:@"api_token"];
            
            if (token == nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginAuthDidFail object:nil];
                return;
            }
            
            [self setDefaultHeader:@"Sharetribe-API-Token" value:token];            
            
            NSDictionary *currentUserDict = [responseObject objectForKey:@"person"];
            [User setCurrentUserWithDict:currentUserDict];
            User *user = [User currentUser];
            
            if (user.communities.count == 1) {
                Community *community = [user.communities lastObject];
                [self setCurrentCommunityId:community.communityId];
            }
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:kAPITokenKeyForUserDefaults];
            [defaults setObject:user.userId forKey:kCurrentUserIdKeyForUserDefaults];
            [defaults synchronize];
            
            NSString *deviceToken = [defaults objectForKey:kDefaultsKeyForDeviceToken];
            if (deviceToken != nil) {
                [self registerCurrentDeviceWithToken:deviceToken];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUserDidLogIn object:user];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginAuthDidFail object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForLoginConnectionDidFail object:nil];
        }
        
        [self handleFailureWithOperation:operation error:error];
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

- (void)registerCurrentDeviceWithToken:(NSString *)token
{
    NSMutableDictionary *params = [self baseParams];
    [params setObject:token forKey:@"device_token"];
    [params setObject:[UIDevice deviceModelName] forKey:@"device_type"];
    
    User *currentUser = [User currentUser];
    [self postPath:[NSString stringWithFormat:@"people/%@/devices", currentUser.userId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getListingsOfType:(NSString *)type forPage:(NSInteger)page
{
    NSMutableDictionary *params = [self baseParams];
    if (type != nil) {
        [params setObject:type forKey:@"listing_type"];
    }
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:50] forKey:@"per_page"];
    
    [self getPath:@"listings" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        NSArray *listingDicts = [responseObject objectOrNilForKey:@"listings"];
        NSArray *listings = [Listing listingsFromArrayOfDicts:listingDicts];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[responseObject objectForKey:@"page"] forKey:kInfoKeyForPage];
        [info setObject:[responseObject objectOrNilForKey:@"total_pages"] forKey:kInfoKeyForNumberOfPages];
        [info setObject:[responseObject objectOrNilForKey:@"per_page"] forKey:kInfoKeyForItemsPerPage];
        [info setObject:type forKey:kInfoKeyForListingType];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListings object:listings userInfo:info];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getListingsByUser:(User *)user forPage:(NSInteger)page
{
    NSMutableDictionary *params = [self baseParams];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    
    [self getPath:[NSString stringWithFormat:@"people/%@/listings", user.userId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        NSArray *listingDicts = [responseObject objectOrNilForKey:@"listings"];
        NSArray *listings = [Listing listingsFromArrayOfDicts:listingDicts];
        
        user.listings = listings;
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:[responseObject objectForKey:@"page"] forKey:kInfoKeyForPage];
        [info setObject:[responseObject objectOrNilForKey:@"total_pages"] forKey:kInfoKeyForNumberOfPages];
        [info setObject:[responseObject objectOrNilForKey:@"per_page"] forKey:kInfoKeyForItemsPerPage];
        [info setObject:user forKey:kInfoKeyForUser];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveListingsByUser object:listings userInfo:info];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getListingWithId:(NSInteger)listingId
{
    NSMutableDictionary *params = [self baseParams];
    
    [self getPath:[NSString stringWithFormat:@"listings/%d.json", listingId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        Listing *listing = [Listing listingFromDict:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidRefreshListing object:listing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getConversations
{
    User *currentUser = [User currentUser];
    [self getPath:[NSString stringWithFormat:@"people/%@/conversations", currentUser.userId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
//        NSInteger page = [[responseObject objectOrNilForKey:@"page"] intValue];
//        NSInteger perPage = [[responseObject objectOrNilForKey:@"per_page"] intValue];
//        NSInteger totalPages = [[responseObject objectOrNilForKey:@"total_pages"] intValue];
        
        NSArray *conversationDicts = [responseObject objectForKey:@"conversations"];
        NSArray *conversations = [Conversation conversationsFromArrayOfDicts:conversationDicts];
                
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveConversations object:conversations];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getMessagesForConversation:(Conversation *)conversation
{
    User *currentUser = [User currentUser];
    [self getPath:[NSString stringWithFormat:@"people/%@/conversations/%d", currentUser.userId, conversation.conversationId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        Conversation *updatedConversation = [Conversation conversationFromDict:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveMessagesForConversation object:updatedConversation];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)postNewListing:(Listing *)listing
{
    NSMutableDictionary *params = [self baseParams];
    [params addEntriesFromDictionary:[listing asJSON]];
        
    NSURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:@"listings" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (listing.imageData != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyyy-MM-dd-HH.mm.ss.'jpg'";
            NSString *filename = [dateFormatter stringFromDate:[NSDate date]];
            [formData appendPartWithFileData:listing.imageData name:@"image" fileName:filename mimeType:@"image/jpeg"];
        }
    }];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"request: %@ done with response: %@ json: %@", request, response, JSON);
        
        Listing *listingAsSaved = [Listing listingFromDict:JSON];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidPostListing object:listingAsSaved];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
        NSLog(@"request: %@ failed with response: %@ error: %@ json: %@", request, response, error, JSON);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForFailedToPostListing object:JSON];
    }];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double progress = ((double) totalBytesWritten) / ((double) totalBytesExpectedToWrite);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForUploadDidProgress object:[NSNumber numberWithDouble:progress]];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)postNewComment:(NSString *)comment onListing:(Listing *)listing
{
    NSMutableDictionary *params = [self baseParams];
    [params setObject:comment forKey:@"content"];
    
    [self postPath:[NSString stringWithFormat:@"listings/%d/comments", listing.listingId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidPostComment object:comment];
        
        [self getListingWithId:listing.listingId];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)startNewConversationWith:(User *)user aboutListing:(Listing *)listing withInitialMessage:(NSString *)message title:(NSString *)title conversationStatus:(ConversationStatus)status
{
    NSMutableDictionary *params = [self baseParams];
    [params setObject:user.userId forKey:@"target_person_id"];
    if (listing != nil) {
        [params setObject:[NSNumber numberWithInteger:listing.listingId] forKey:@"listing_id"];
    }
    [params setObject:message forKey:@"content"];
    if (title != nil) {
        [params setObject:title forKey:@"title"];
    }
    [params setObject:[Conversation stringFromConversationStatus:status] forKey:@"status"];
    
    User *currentUser = [User currentUser];
    [self postPath:[NSString stringWithFormat:@"people/%@/conversations", currentUser.userId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidPostMessage object:message];
        
        [self getConversations];  // refresh the list
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)postNewMessage:(NSString *)message toConversation:(Conversation *)conversation;
{
    NSMutableDictionary *params = [self baseParams];
    [params setObject:message forKey:@"content"];
    
    User *currentUser = [User currentUser];
    [self postPath:[NSString stringWithFormat:@"people/%@/conversations/%d", currentUser.userId, conversation.conversationId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidPostMessage object:message];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];    
}

- (void)getUserWithId:(NSString *)userId
{
    [self getPath:[NSString stringWithFormat:@"people/%@", userId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        User *user = [User userFromDict:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveUser object:user];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)refreshCurrentUser
{
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserIdKeyForUserDefaults];
    if (currentUserId != nil) {
        [self getUserWithId:currentUserId];
    }
}

- (void)getBadgesForUser:(User *)user
{
    [self getPath:[NSString stringWithFormat:@"people/%@/badges", user.userId] parameters:self.baseParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];
        
        NSArray *badgeDicts = [responseObject objectOrNilForKey:@"badges"];
        NSArray *badges = [Badge badgesFromArrayOfDicts:badgeDicts];
        
        user.badges = badges;
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:user forKey:kInfoKeyForUser];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveBadgesForUser object:badges userInfo:info];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (void)getFeedbackForUser:(User *)user
{
    [self getPath:[NSString stringWithFormat:@"people/%@/feedbacks", user.userId] parameters:self.baseParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logSuccessWithOperation:operation responseObject:responseObject];

        NSArray *feedbackDicts = [responseObject objectOrNilForKey:@"feedbacks"];
        NSArray *feedbacks = [Feedback feedbacksFromArrayOfDicts:feedbackDicts];
        
        user.feedbacks = feedbacks;
        
        NSArray *gradeArrays = [responseObject objectOrNilForKey:@"grade_amounts"];
        NSArray *grades = [Grade gradesFromArrayOfArrays:gradeArrays];
        
        user.grades = grades;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveFeedbackForUser object:feedbacks userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidReceiveGradesForUser object:grades userInfo:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailureWithOperation:operation error:error];
    }];
}

- (NSMutableDictionary *)baseParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (currentCommunityId != NSNotFound) {
        [params setObject:[NSNumber numberWithInt:currentCommunityId] forKey:@"community_id"];
    }
    
    return params;
}

- (void)logSuccessWithOperation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject
{
    NSLog(@"requested: %@\ngot response: %@", operation.request.URL, responseObject);
}

- (void)handleFailureWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    NSLog(@"error: %@\nwith requesting: %@", error, operation.request.URL);
}

@end
