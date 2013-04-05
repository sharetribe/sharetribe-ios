//
//  APIClient.h
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

#import "Conversation.h"
#import "Listing.h"
#import "CWLSynthesizeSingleton.h"

// Notifications for success:

#define kNotificationForUserDidLogIn                       @"user did log in"
#define kNotificationForUserDidLogOut                      @"user did log out"

#define kNotificationForDidReceiveListings                 @"did receive listings"
#define kNotificationForDidRefreshListing                  @"did refresh listing"
#define kNotificationForDidReceiveConversations            @"did receive conversations"
#define kNotificationForDidReceiveMessagesForConversation  @"did receive messages for conversation"
#define kNotificationForDidReceiveUser                     @"did receive user"
#define kNotificationForDidReceiveBadgesForUser            @"did receive badges for user"
#define kNotificationForDidReceiveFeedbackForUser          @"did receive feedback for user"
#define kNotificationForDidReceiveGradesForUser            @"did receive grades for user"
#define kNotificationForDidReceiveListingsByUser           @"did receive listings by user"

#define kNotificationForDidPostListing                     @"did post listing"
#define kNotificationForDidPostComment                     @"did post comment"
#define kNotificationForDidPostMessage                     @"did post message"
#define kNotificationForDidChangeConversationStatus        @"did change conversation status"

#define kNotificationForGettingListingsDidProgress         @"getting listings did progress"
#define kNotificationForUploadDidProgress                  @"upload did progress"

// Notifications for failure:

#define kNotificationForLoginConnectionDidFail             @"login connection did fail"
#define kNotificationForLoginAuthDidFail                   @"login auth did fail"

#define kNotificationForFailedToPostListing                @"failed to post listing"
#define kNotificationForFailedToPostComment                @"failed to post comment"
#define kNotificationForFailedToPostMessage                @"failed to post message"
#define kNotificationForFailedToChangeConversationStatus   @"failed to change conversation status"

// Response info dict keys:

#define kInfoKeyForListingType                             @"listing type"
#define kInfoKeyForUser                                    @"user"
#define kInfoKeyForPage                                    @"page"
#define kInfoKeyForNumberOfPages                           @"number of pages"
#define kInfoKeyForItemsPerPage                            @"items per page"

#define kInfoKeyForProgress                                @"progress"

@class User;

@interface SharetribeAPIClient : AFHTTPClient

CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SharetribeAPIClient, sharedClient);

@property (assign) NSInteger currentCommunityId;

- (BOOL)isLoggedIn;
- (BOOL)hasInternetConnectivity;

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;
- (void)logOut;
- (void)registerCurrentDeviceWithToken:(NSString *)token;

- (void)getListingsOfType:(NSString *)type inCategory:(NSString *)category forPage:(NSInteger)page;
- (void)getListingsOfType:(NSString *)type withSearch:(NSString *)search forPage:(NSInteger)page;
- (void)getListingsByUser:(User *)user forPage:(NSInteger)page;
- (void)getListingWithId:(NSInteger)listingId;
- (void)postNewListing:(Listing *)listing;
- (void)postUpdatedListing:(Listing *)listing;
- (void)closeListing:(Listing *)listing;
- (void)deleteListing:(Listing *)listing;
- (void)postNewComment:(NSString *)comment onListing:(Listing *)listing;

- (void)getConversations;
- (void)getMessagesForConversation:(Conversation *)conversation;
- (void)startNewConversationWith:(User *)user aboutListing:(Listing *)listing withInitialMessage:(NSString *)message title:(NSString *)title conversationStatus:(NSString *)status;
- (void)postNewMessage:(NSString *)message toConversation:(Conversation *)conversation;
- (void)changeStatusTo:(NSString *)status forConversation:(Conversation *)conversation;

- (void)getUserWithId:(NSString *)userId;
- (void)refreshCurrentUser;
- (void)getBadgesForUser:(User *)user;
- (void)getFeedbackForUser:(User *)user;

@end
