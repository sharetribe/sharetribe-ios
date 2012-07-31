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
#define kNotificationForDidReceiveListingDetails           @"did receive listing details"
#define kNotificationForDidReceiveConversations            @"did receive conversations"
#define kNotificationForDidReceiveMessagesForConversation  @"did receive messages for conversation"
#define kNotificationForDidReceiveUser                     @"did receive user"
#define kNotificationForDidReceiveBadgesForUser            @"did receive badges for user"
#define kNotificationForDidReceiveFeedbackForUser          @"did receive feedback for user"

#define kNotificationForDidPostListing                     @"did post listing"
#define kNotificationForDidPostComment                     @"did post comment"
#define kNotificationForDidPostMessage                     @"did post message"

#define kNotificationForUploadDidProgress                  @"upload did progress"

// Notifications for failure:

#define kNotificationForLoginConnectionDidFail             @"login connection did fail"
#define kNotificationForLoginAuthDidFail                   @"login auth did fail"

// Response info dict keys:

#define kInfoKeyForListingType                             @"listing type"
#define kInfoKeyForPage                                    @"page"
#define kInfoKeyForNumberOfPages                           @"number of pages"
#define kInfoKeyForItemsPerPage                            @"items per page"

@class User;

@interface SharetribeAPIClient : AFHTTPClient

CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SharetribeAPIClient, sharedClient);

@property (assign) NSInteger currentCommunityId;

- (BOOL)isLoggedIn;

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;
- (void)logOut;
- (void)registerCurrentDeviceWithToken:(NSString *)token;

- (void)getListingsOfType:(ListingType)type forPage:(NSInteger)page;
- (void)getListingWithId:(NSInteger)listingId;
- (void)postNewListing:(Listing *)listing;
- (void)postNewComment:(NSString *)comment onListing:(Listing *)listing;

- (void)getConversations;
- (void)getMessagesForConversation:(Conversation *)conversation;
- (void)startNewConversationWith:(User *)user aboutListing:(Listing *)listing withInitialMessage:(NSString *)message title:(NSString *)title conversationStatus:(ConversationStatus)status;
- (void)postNewMessage:(NSString *)message toConversation:(Conversation *)conversation;

- (void)getUserWithId:(NSString *)userId;
- (void)refreshCurrentUser;
- (void)getBadgesForUser:(User *)user;
- (void)getFeedbackForUser:(User *)user;

@end
