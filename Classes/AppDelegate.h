//
//  AppDelegate.h
//  Kassi
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingsTopViewController.h"
#import "CreateListingViewController.h"
#import "MessagesListViewController.h"
#import "ProfileViewController.h"
#import "ButtonTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ButtonTabBarController *tabBarController;

@property (strong, nonatomic) ListingsTopViewController *offersViewController;
@property (strong, nonatomic) ListingsTopViewController *requestsViewController;
@property (strong, nonatomic) MessagesListViewController *messagesViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

@property (strong, nonatomic) CreateListingViewController *createListingViewController;
@property (strong, nonatomic) UINavigationController *createListingNavigationController;

@end
