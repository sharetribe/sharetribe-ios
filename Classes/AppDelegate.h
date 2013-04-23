//
//  AppDelegate.h
//  Sharetribe
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ButtonTabBarController.h"
#import "Community.h"
#import "ConversationListViewController.h"
#import "ListingsTopViewController.h"
#import "NewListingViewController.h"
#import "ProfileViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ButtonTabBarController *tabBarController;

@property (strong, nonatomic) ListingsTopViewController *offersViewController;
@property (strong, nonatomic) ListingsTopViewController *requestsViewController;
@property (strong, nonatomic) ConversationListViewController *messagesViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

@property (strong, nonatomic) NewListingViewController *listingComposer;
@property (strong, nonatomic) UINavigationController *createListingNavigationController;

@property (strong, nonatomic) Community *community;

- (void)doInitialCheck;
- (void)refreshInitialContent;

+ (AppDelegate *)sharedAppDelegate;

@end
