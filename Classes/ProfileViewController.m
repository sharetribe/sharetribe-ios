//
//  ProfileViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

#import "ConversationViewController.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "UIImageView+Sharetribe.h"
#import "UILabel+SizeToHeight.h"

#define kAlertTagForConfirmingLogOut     1
#define kAlertTagForConfirmingPhoneCall  2

@interface ProfileViewController () <UIAlertViewDelegate, UIActionSheetDelegate> {
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
@synthesize descriptionLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    [[SharetribeAPIClient sharedClient] getBadgesForUser:user];
    [[SharetribeAPIClient sharedClient] getFeedbackForUser:user];
    [[SharetribeAPIClient sharedClient] getListingsByUser:user forPage:kFirstPage];
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
        if (self.navigationController.viewControllers.count == 1) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.log_out", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonPressed)];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-envelope-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(messageButtonPressed)];
    }
    
    descriptionLabel.text = user.description;
    [descriptionLabel sizeToHeight];
    
    
    
    self.scrollView.contentSize = CGSizeMake(320, 460-2*44);
}

- (IBAction)logoutButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.confirm_log_out", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancel", @"") otherButtonTitles:NSLocalizedString(@"button.yes", @""), nil];
    alert.tag = kAlertTagForConfirmingLogOut;
    [alert show];
}

- (IBAction)messageButtonPressed
{
    ConversationViewController *composer = [[ConversationViewController alloc] init];
    composer.recipient = user;
    composer.inModalComposerMode = YES;
    
    UINavigationController *composerNavigationController = [[UINavigationController alloc] initWithRootViewController:composer];
    [self presentViewController:composerNavigationController animated:YES completion:nil];
}

- (IBAction)phoneButtonPressed
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", user.phoneNumber]]]) {
        return;
    }
    
    NSString *alertFormat = NSLocalizedString(@"alert.confirm_phone_call.format", @"");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:alertFormat, user.phoneNumber] message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancel", @"") otherButtonTitles:NSLocalizedString(@"button.call", @""), nil];
    alert.tag = kAlertTagForConfirmingPhoneCall;
    [alert show];
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
        if (alertView.tag == kAlertTagForConfirmingLogOut) {
            [[SharetribeAPIClient sharedClient] logOut];
        } else if (alertView.tag == kAlertTagForConfirmingPhoneCall) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", user.phoneNumber]]];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
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
