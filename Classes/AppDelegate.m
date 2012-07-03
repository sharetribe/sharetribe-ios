//
//  AppDelegate.m
//  Kassi
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "SharetribeAPIClient.h"
#import "Listing.h"
#import "LoginViewController.h"
#import "User.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;

@synthesize offersViewController;
@synthesize requestsViewController;
@synthesize messagesViewController;
@synthesize profileViewController;

@synthesize createListingViewController;
@synthesize createListingNavigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.offersViewController = [[ListingsTopViewController alloc] initWithListingType:ListingTypeOffer];
    self.requestsViewController = [[ListingsTopViewController alloc] initWithListingType:ListingTypeRequest];
    self.messagesViewController = [[MessagesListViewController alloc] init];
    self.profileViewController = [[ProfileViewController alloc] init];
    
    [offersViewController view];
    [requestsViewController view];
    [messagesViewController view];
    
    UINavigationController *offersNavigationController = [[UINavigationController alloc] initWithRootViewController:offersViewController];
    UINavigationController *requestsNavigationController = [[UINavigationController alloc] initWithRootViewController:requestsViewController];
    UINavigationController *messagesNavigationController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
    self.createListingViewController = [[CreateListingViewController alloc] init];
    self.createListingNavigationController = [[UINavigationController alloc] initWithRootViewController:createListingViewController];
    
    offersNavigationController.title = NSLocalizedString(@"Tabs.Offers", @"");
    requestsNavigationController.title = NSLocalizedString(@"Tabs.Requests", @"");
    messagesNavigationController.title = NSLocalizedString(@"Tabs.Messages", @"");
    
    User *currentUser = [User currentUser];
    profileViewController.title = (currentUser != nil) ? currentUser.givenName : NSLocalizedString(@"Tabs.Profile", @"");
    
    offersNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-gift"];
    requestsNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-bullhorn"];
    messagesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-envelope"];
    profileNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-kaapo"];
    
    UIColor *tintColor = kKassiDarkGreenColor;
    offersNavigationController.navigationBar.tintColor = tintColor;
    requestsNavigationController.navigationBar.tintColor = tintColor;
    messagesNavigationController.navigationBar.tintColor = tintColor;
    profileNavigationController.navigationBar.tintColor = tintColor;
    createListingNavigationController.navigationBar.tintColor = tintColor;
    
    messagesNavigationController.tabBarItem.badgeValue = @"2";
        
    NSMutableArray *tabViewControllers = [NSMutableArray arrayWithCapacity:5];
    [tabViewControllers addObject:offersNavigationController];
    [tabViewControllers addObject:requestsNavigationController];
    [tabViewControllers addObject:messagesNavigationController];
    [tabViewControllers addObject:profileNavigationController];
    
    self.tabBarController = [[ButtonTabBarController alloc] initWithMiddleViewController:createListingNavigationController otherViewControllers:tabViewControllers];

    [tabBarController setMiddleButtonTitle:NSLocalizedString(@"Tabs.NewListing", @"")];
    
    [tabBarController setMiddleButtonImage:[UIImage imageNamed:@"icon-bubble"] forState:UIControlStateNormal];
    [tabBarController setMiddleButtonImage:[UIImage imageNamed:@"icon-bubble-white"] forState:UIControlStateHighlighted];
        
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(newListingPosted:) name:kNotificationForDidPostListing object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidLogIn:) name:kNotificationForUserDidLogIn object:nil];
    [notificationCenter addObserver:self selector:@selector(showLogin) name:kNotificationForUserDidLogOut object:nil];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    if  (![[SharetribeAPIClient sharedClient] isLoggedIn]) {
        [self showLogin];
    } else {
        [[SharetribeAPIClient sharedClient] getListings];
        // [[SharetribeAPIClient sharedClient] refreshCurrentUser];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData
{
    NSString *deviceToken = [[deviceTokenData description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"Registered for push notifications with token: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"Failed to register for push notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = nil;
    id alert = [userInfo objectForKey:@"alert"];
    if ([alert isKindOfClass:NSString.class]) {
        message = alert;
    } else if ([alert isKindOfClass:NSDictionary.class]) {
        message = [alert objectForKey:@"body"];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New notification!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)showLogin
{
    LoginViewController *loginViewer = [[LoginViewController alloc] init];
    [self.tabBarController presentModalViewController:loginViewer animated:NO];
    [tabBarController setSelectedIndex:0];
}

- (void)newListingPosted:(NSNotification *)notification
{
    [[SharetribeAPIClient sharedClient] getListings];  // just to refresh & get the listing back from server
}

- (void)userDidLogIn:(NSNotification *)notification
{
    [[SharetribeAPIClient sharedClient] getListings];
}

@end
