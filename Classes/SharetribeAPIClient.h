//
//  APIClient.h
//  Kassi
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"

#import "CWLSynthesizeSingleton.h"

// Notifications for success:

#define kNotificationForUserDidLogIn               @"user did log in"
#define kNotificationForUserDidLogOut              @"user did log out"

#define kNotificationForDidReceiveListings         @"did receive listings"
#define kNotificationForDidReceiveListingDetails   @"did receive listing details"

#define kNotificationForDidPostListing             @"did post listing"

// Notifications for failure:

#define kNotificationForLoginConnectionDidFail     @"login connection did fail"
#define kNotificationForLoginAuthDidFail           @"login auth did fail"

@class Listing;

@interface SharetribeAPIClient : AFHTTPClient

CWL_DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SharetribeAPIClient, sharedClient);

- (BOOL)isLoggedIn;

- (void)logInWithUsername:(NSString *)username password:(NSString *)password;
- (void)logOut;

- (void)getListings;
- (void)getListingWithId:(NSInteger)listingId;

- (void)postNewListing:(Listing *)listing;

- (void)getUserWithId:(NSString *)userId;
- (void)refreshCurrentUser;

@end
