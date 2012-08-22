//
//  ProfileViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"

#import "Badge.h"
#import "BadgeCell.h"
#import "ConversationViewController.h"
#import "Grade.h"
#import "GradeCell.h"
#import "FeedbackListViewController.h"
#import "FeedbackTotalCell.h"
#import "ListingsListViewController.h"
#import "Location.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "UIImageView+Sharetribe.h"
#import "UILabel+SizeToHeight.h"

#define kAlertTagForConfirmingLogOut     1
#define kAlertTagForConfirmingPhoneCall  2

#define kSectionIndexForListings  0
#define kSectionIndexForGrades    1
#define kSectionIndexForBadges    2

@interface ProfileViewController () <UIAlertViewDelegate, UIActionSheetDelegate> {
    User *user;
    NSArray *listings;
    NSArray *grades;
    NSArray *feedbacks;
    NSArray *badges;
    int numberOfPositiveRatings;
    int numberOfAllRatings;
}

@end

@implementation ProfileViewController

@dynamic user;

@synthesize tableView = _tableView;
@synthesize headerView;
@synthesize mapView = _mapView;
@synthesize avatarView;
@synthesize infoContainer;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize phoneButton;
@synthesize locationIconView;
@synthesize phoneIconView;
@synthesize descriptionLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [headerView removeFromSuperview];
    self.tableView.tableHeaderView = headerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kSharetribeLightBrownColor;
    
    [self observeNotification:kNotificationForDidReceiveUser withSelector:@selector(gotUser:)];
    [self observeNotification:kNotificationForDidReceiveBadgesForUser withSelector:@selector(gotBadges:)];
    [self observeNotification:kNotificationForDidReceiveGradesForUser withSelector:@selector(gotGrades:)];
    [self observeNotification:kNotificationForDidReceiveFeedbackForUser withSelector:@selector(gotFeedback:)];
    [self observeNotification:kNotificationForDidReceiveListingsByUser withSelector:@selector(gotListingsByUser:)];
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
    
    if (user.location != nil) {
        [self.mapView addAnnotation:user.location];
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(user.location.coordinate, 1500, 3000) animated:NO];
        locationLabel.text = user.location.address;
        locationLabel.height = [locationLabel.text sizeWithFont:locationLabel.font constrainedToSize:CGSizeMake(locationLabel.width, 200) lineBreakMode:UILineBreakModeWordWrap].height;
        phoneButton.y = locationLabel.y+locationLabel.height;
        locationLabel.hidden = NO;
        locationIconView.hidden = NO;
    } else {
        phoneButton.y = locationLabel.y;
        locationLabel.hidden = YES;
        locationIconView.hidden = YES;
    }
    
    if (user.phoneNumber.length > 0) {
        [phoneButton setTitle:user.phoneNumber forState:UIControlStateNormal];
        phoneButton.width = [user.phoneNumber sizeWithFont:phoneButton.titleLabel.font].width;
        phoneIconView.y = phoneButton.y+7;
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
    
    infoContainer.height = descriptionLabel.y+descriptionLabel.height+20;
    headerView.height = infoContainer.y+infoContainer.height;
    
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView reloadData];
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

- (IBAction)showListingsByUser
{
    ListingsListViewController *listViewer = [[ListingsListViewController alloc] init];
    listViewer.disallowsRefreshing = YES;
    [listViewer addListings:listings];
    [self.navigationController pushViewController:listViewer animated:YES];
}

- (IBAction)showAllFeedback
{
    FeedbackListViewController *feedbackViewer = [[FeedbackListViewController alloc] init];
    feedbackViewer.feedbacks = feedbacks;
    [self.navigationController pushViewController:feedbackViewer animated:YES];
}

- (void)gotUser:(NSNotification *)notification
{
    if ([user.userId isEqual:[notification.object userId]]) {
        self.user = notification.object;
    }
}

- (void)gotBadges:(NSNotification *)notification
{
    badges = notification.object;
    [self.tableView reloadData];
}

- (void)gotGrades:(NSNotification *)notification
{
    grades = notification.object;
    numberOfAllRatings = 0;
    numberOfPositiveRatings = 0;
    for (Grade *grade in grades) {
        numberOfAllRatings += grade.amount;
        if (grade.grade >= 3) {
            numberOfPositiveRatings += grade.amount;
        }
    }
    [self.tableView reloadData];
}

- (void)gotFeedback:(NSNotification *)notification
{
    feedbacks = notification.object;
    [self.tableView reloadData];
}

- (void)gotListingsByUser:(NSNotification *)notification
{
    listings = notification.object;
    [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSectionIndexForListings) {
        return 1;
    } else if (section == kSectionIndexForGrades) {
        return (feedbacks.count > 0) ? grades.count+2 : 2;
    } else if (section == kSectionIndexForBadges) {
        return badges.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionIndexForListings || (indexPath.section == kSectionIndexForGrades && indexPath.row == [self tableView:tableView numberOfRowsInSection:kSectionIndexForGrades]-1)) {
        
        NSArray *items = (indexPath.section == kSectionIndexForListings) ? listings : feedbacks;
        
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(14, 0, 292, 44);
        button.enabled = (items.count > 0);
        [cell addSubview:button];
        if (items != nil) {
            UILabel *label = [[UILabel alloc] init];
            NSString *listingsTitleFormat = (indexPath.section == kSectionIndexForListings) ? NSLocalizedString(@"profile.listings_title_format", @"") : NSLocalizedString(@"profile.all_feedback_title_format", @"");
            label.text = [NSString stringWithFormat:listingsTitleFormat, items.count];
            label.font = [UIFont boldSystemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.x = 28;
            label.y = button.y;
            label.width = button.width;
            label.height = button.height;
            [cell addSubview:label];
            if (items.count > 0) {
                UIImageView *disclosureArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-arrow"]];
                disclosureArrow.x = 280;
                disclosureArrow.y = button.y+(button.height-disclosureArrow.height)/2;
                [cell addSubview:disclosureArrow];
            } else {
                label.textColor = [UIColor lightGrayColor];
            }
        } else {
            button.alpha = 0.5;
        }
        
        if (indexPath.section == kSectionIndexForListings) {
            [button addTarget:self action:@selector(showListingsByUser) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(showAllFeedback) forControlEvents:UIControlEventTouchUpInside];
        }
            
        return cell;
        
    } else if (indexPath.section == kSectionIndexForGrades) {
        
        if (indexPath.row == 0) {
            
            if (numberOfAllRatings > 0) {
                FeedbackTotalCell *cell = [FeedbackTotalCell newInstance];

                float percentage = (numberOfPositiveRatings + 0.0)/numberOfAllRatings;
                cell.percentageLabel.text = [NSString stringWithFormat:@"%.0f%%", percentage*100];
                cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"profile.percentage_detail_format", @""), numberOfPositiveRatings, numberOfAllRatings];
                
                [cell.whatIsThisButton setTitle:NSLocalizedString(@"listing.explanation", @"") forState:UIControlStateNormal];
                [cell.percentageLabel sizeToFit];
                cell.detailLabel.x = cell.percentageLabel.x + cell.percentageLabel.width + 5;
                
                return cell;
            } else {
                return [[UITableViewCell alloc] init];
            }
        }
        
        GradeCell *cell = [tableView dequeueReusableCellWithIdentifier:GradeCell.reuseIdentifier];
        if (cell == nil) {
            cell = [GradeCell newInstance];
        }
        cell.grade = [grades objectAtIndex:indexPath.row-1];
        return cell;
        
    } else if (indexPath.section == kSectionIndexForBadges) {
        
        BadgeCell *cell = [tableView dequeueReusableCellWithIdentifier:BadgeCell.reuseIdentifier];
        if (cell == nil) {
            cell = [BadgeCell newInstance];
        }
        cell.badge = [badges objectAtIndex:indexPath.row];
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kSectionIndexForListings) {
        return nil;
    } else if (section == kSectionIndexForGrades) {
        return NSLocalizedString(@"profile.received_feedback", @"");
    } else if (section == kSectionIndexForBadges) {
        return (badges.count > 0) ? NSLocalizedString(@"profile.badges", @"") : nil;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionIndexForListings) {
        return 65;
    } else if (indexPath.section == kSectionIndexForGrades) {
        int rowCount = [self tableView:tableView numberOfRowsInSection:kSectionIndexForGrades];
        if (indexPath.row == 0) {
            return (numberOfAllRatings > 0) ? 100 : 22;
        }
        if (indexPath.row == rowCount-2) {
            return 45;
        }
        if (indexPath.row == rowCount-1) {
            return 65;
        }
        return 35;
    } else if (indexPath.section == kSectionIndexForBadges) {
        BadgeCell *cell = [tableView dequeueReusableCellWithIdentifier:BadgeCell.reuseIdentifier];
        if (cell == nil) {
            cell = [BadgeCell newInstance];
        }
        Badge *badge = [badges objectAtIndex:indexPath.row];
        int rowHeight = [cell heightWithBadge:badge];
        if (indexPath.row == badges.count-1) {
            rowHeight += 10;
        }
        return rowHeight;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self tableView:tableView titleForHeaderInSection:section] != nil) ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = kSharetribeDarkBrownColor;
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor darkTextColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.x = 14;
    headerLabel.height = 20;
    headerLabel.width = 292;
    [header addSubview:headerLabel];
    return header;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        CGFloat mapViewBaselineY = -(self.mapView.height-150)/2+500;
        CGFloat y = mapViewBaselineY + scrollView.contentOffset.y/2;
        self.mapView.frame = CGRectMake(0, y, self.mapView.width, self.mapView.height);
    }
}

@end
