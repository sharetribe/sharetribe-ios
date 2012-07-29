//
//  AppDelegate.h
//  Sharetribe
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingsTopViewController.h"
#import "CreateListingViewController.h"
#import "ConversationListViewController.h"
#import "ProfileViewController.h"
#import "ButtonTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ButtonTabBarController *tabBarController;

@property (strong, nonatomic) ListingsTopViewController *offersViewController;
@property (strong, nonatomic) ListingsTopViewController *requestsViewController;
@property (strong, nonatomic) ConversationListViewController *messagesViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

@property (strong, nonatomic) CreateListingViewController *createListingViewController;
@property (strong, nonatomic) UINavigationController *createListingNavigationController;

@end
