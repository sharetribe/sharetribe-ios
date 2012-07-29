//
//  ProfileViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

#import "SharetribeAPIClient.h"
#import "User.h"
#import "UIImageView+Sharetribe.h"

@interface ProfileViewController () <UIAlertViewDelegate> {
    User *user;
}

@end

@implementation ProfileViewController

@dynamic user;

@synthesize scrollView = _scrollView;
@synthesize mapView = _mapView;
@synthesize avatarView;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize phoneButton;
@synthesize locationIconView;
@synthesize phoneIconView;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogIn:) name:kNotificationForUserDidLogIn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotUser:) name:kNotificationForDidReceiveUser object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUser:self.user];  // a refresh!
    
    [[SharetribeAPIClient sharedClient] getUserWithId:user.userId];  // load detailed info
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (User *)user
{
    return user;
}

- (void)setUser:(User *)newUser
{
    user = newUser;
    
    nameLabel.text = user.name;
    
    [avatarView setImageWithUser:user];
    
    if (user.phoneNumber != nil) {
        [phoneButton setTitle:user.phoneNumber forState:UIControlStateNormal];
        phoneButton.width = [user.phoneNumber sizeWithFont:phoneButton.titleLabel.font].width;
        phoneButton.hidden = NO;
        phoneIconView.hidden = NO;
    } else {
        phoneButton.hidden = YES;
        phoneIconView.hidden = YES;
    }
    
    if (user.isCurrentUser) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed)];
    }
    
    self.scrollView.contentSize = CGSizeMake(320, 460-2*44);
}

- (IBAction)logoutButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)actionButtonPressed
{
}

- (void)userDidLogIn:(NSNotification *)notification
{
    self.title = [[User currentUser] givenName];
}

- (void)gotUser:(NSNotification *)notification
{
    if ([user.userId isEqual:[notification.object userId]]) {
        self.user = notification.object;
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[SharetribeAPIClient sharedClient] logOut];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        CGFloat mapViewBaselineY = -(self.mapView.height-150)/2;
        CGFloat y = mapViewBaselineY - scrollView.contentOffset.y/2;
        self.mapView.frame = CGRectMake(0, y, self.mapView.width, self.mapView.height);
    }
}

@end
