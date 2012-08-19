//
//  AppDelegate.m
//  Sharetribe
//
//  Created by Janne Käki on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CommunitySelectionViewController.h"
#import "Listing.h"
#import "LoginViewController.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "UINavigationController+Sharetribe.h"

#import "TestFlight.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController;

@synthesize offersViewController;
@synthesize requestsViewController;
@synthesize messagesViewController;
@synthesize profileViewController;

@synthesize createListingViewController;
@synthesize createListingNavigationController;

void uncaughtExceptionHandler(NSException *exception);

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [TestFlight takeOff:@"a0c477498dc30ddc9c5fc29292aa7134_NjYwNTYyMDEyLTA3LTMxIDIwOjExOjQzLjYxNDkzMw"];
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.offersViewController = [[ListingsTopViewController alloc] initWithListingType:kListingTypeOffer];
    self.requestsViewController = [[ListingsTopViewController alloc] initWithListingType:kListingTypeRequest];
    self.messagesViewController = [[ConversationListViewController alloc] init];
    self.profileViewController = [[ProfileViewController alloc] init];
    
    [offersViewController view];
    [requestsViewController view];
    [messagesViewController view];
    
    UINavigationController *offersNavigationController = [[UINavigationController alloc] initWithRootViewController:offersViewController];
    UINavigationController *requestsNavigationController = [[UINavigationController alloc] initWithRootViewController:requestsViewController];
    UINavigationController *messagesNavigationController = [[UINavigationController alloc] initWithRootViewController:messagesViewController];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
    offersNavigationController.delegate = self;
    requestsNavigationController.delegate = self;
    messagesNavigationController.delegate = self;
    profileNavigationController.delegate = self;
    
    self.createListingViewController = [[CreateListingViewController alloc] init];
    self.createListingNavigationController = [[UINavigationController alloc] initWithRootViewController:createListingViewController];
    
    offersNavigationController.title = NSLocalizedString(@"tabs.offers", @"");
    requestsNavigationController.title = NSLocalizedString(@"tabs.requests", @"");
    messagesNavigationController.title = NSLocalizedString(@"tabs.messages", @"");
    profileNavigationController.title = NSLocalizedString(@"tabs.profile", @"");
    
    User *currentUser = [User currentUser];
    profileViewController.user = currentUser;
    
    offersNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-gift"];
    requestsNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-bullhorn"];
    messagesNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-envelope"];
    profileNavigationController.tabBarItem.image = [UIImage imageNamed:@"icon-kaapo"];
    
    UIColor *tintColor = kSharetribeDarkBrownColor;
    offersNavigationController.navigationBar.tintColor = tintColor;
    requestsNavigationController.navigationBar.tintColor = tintColor;
    messagesNavigationController.navigationBar.tintColor = tintColor;
    profileNavigationController.navigationBar.tintColor = tintColor;
    createListingNavigationController.navigationBar.tintColor = tintColor;
            
    NSMutableArray *tabViewControllers = [NSMutableArray arrayWithCapacity:5];
    [tabViewControllers addObject:offersNavigationController];
    [tabViewControllers addObject:requestsNavigationController];
    [tabViewControllers addObject:messagesNavigationController];
    [tabViewControllers addObject:profileNavigationController];
    
    self.tabBarController = [[ButtonTabBarController alloc] initWithMiddleViewController:createListingNavigationController otherViewControllers:tabViewControllers];

    tabBarController.middleButtonTitle = NSLocalizedString(@"tabs.new_listing", @"");
    tabBarController.middleButtonNormalImage = [UIImage imageNamed:@"icon-bubble"];
    tabBarController.middleButtonHighlightedImage = [UIImage imageNamed:@"icon-bubble-white"];
        
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(userDidLogIn:) name:kNotificationForUserDidLogIn object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidLogOut:) name:kNotificationForUserDidLogOut object:nil];
    [notificationCenter addObserver:self selector:@selector(userDidSelectCommunity:) name:kNotificationForDidSelectCommunity object:nil];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    
    if  (![[SharetribeAPIClient sharedClient] isLoggedIn]) {
        [self showLogin];
    } else {
        if ([[SharetribeAPIClient sharedClient] currentCommunityId] == NSNotFound) {
            [self showCommunitySelection];
        } else {
            [self loadInitialContent];
        }
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:kDefaultsKeyForDeviceToken];
    [defaults synchronize];
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

- (void)showCommunitySelection
{
    CommunitySelectionViewController *communitySelectionViewer = [[CommunitySelectionViewController alloc] init];
    [self.tabBarController presentModalViewController:communitySelectionViewer animated:YES];
}

- (void)loadInitialContent
{
    [offersViewController refreshListings];
    [requestsViewController refreshListings];
    [messagesViewController refreshConversations];
    
    [tabBarController setSelectedIndex:0];
}

- (void)userDidLogIn:(NSNotification *)notification
{
    User *currentUser = [User currentUser];
    profileViewController.user = currentUser;
    
    if (currentUser.communities.count < 2) {
        [self loadInitialContent];
    } else {
        [self performSelector:@selector(showCommunitySelection) withObject:nil afterDelay:0.5];
    }
}

- (void)userDidSelectCommunity:(NSNotification *)notification
{
    [self loadInitialContent];
}

- (void)userDidLogOut:(NSNotification *)notification
{
    [offersViewController clearAllListings];
    [requestsViewController clearAllListings];
    [self showLogin];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count > 1) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:navigationController action:@selector(pop)];
    }
}

@end
