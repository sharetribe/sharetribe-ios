//
//  ListingsListViewController.m
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsListViewController.h"

#import "Listing.h"
#import "ListingCell.h"
#import "ListingViewController.h"
#import "ListingsTopViewController.h"

@implementation ListingsListViewController

@dynamic listings;

@synthesize header;
@synthesize updateIntroLabel;
@synthesize updateTimeLabel;
@synthesize updateSpinner;

@synthesize listingSelectionDelegate;

- (NSArray *)listings
{
    if (listings == nil) {
        listings = [NSMutableArray array];
    }
    return listings;
}

- (void)setListings:(NSArray *)newListings
{
    listings = [NSMutableArray arrayWithArray:newListings];
    [listings sortUsingFunction:compareListingsByDate context:NULL];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = kKassiLightBrownColor;
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.updateIntroLabel = [[UILabel alloc] init];
    updateIntroLabel.frame = CGRectMake(20, -54, 280, 30);
    updateIntroLabel.font = [UIFont boldSystemFontOfSize:13];
    updateIntroLabel.text = @"Pull down to update...";
    updateIntroLabel.textColor = [UIColor whiteColor];
    updateIntroLabel.backgroundColor = [UIColor clearColor];
    updateIntroLabel.textAlignment = UITextAlignmentCenter;
    updateIntroLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    updateIntroLabel.alpha = 0.8;
    
    self.updateTimeLabel = [[UILabel alloc] init];
    updateTimeLabel.frame = CGRectMake(20, -36, 280, 30);
    updateTimeLabel.font = [UIFont systemFontOfSize:12];
    updateTimeLabel.textColor = [UIColor whiteColor];
    updateTimeLabel.backgroundColor = [UIColor clearColor];
    updateTimeLabel.textAlignment = UITextAlignmentCenter;
    updateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    updateTimeLabel.alpha = 0.8;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy  HH:mm";
    updateTimeLabel.text = [NSString stringWithFormat:@"Last updated:  %@", [formatter stringFromDate:[NSDate date]]];
    
    self.updateSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    updateSpinner.frame = CGRectMake(26, -40, 20, 20);
    updateSpinner.hidesWhenStopped = NO;
    updateSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    UIView *headerBackground = [[UIView alloc] init];
    headerBackground.frame = CGRectMake(0, -460, 320, 460);
    headerBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    headerBackground.backgroundColor = kKassiDarkOrangeColor;
    
    self.header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, 320, 0);
    header.backgroundColor = [UIColor clearColor];
    [header addSubview:headerBackground];
    [header addSubview:updateIntroLabel];
    [header addSubview:updateTimeLabel];
    [header addSubview:updateSpinner];
    self.tableView.tableHeaderView = header;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.listingSelectionDelegate = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateFinished
{
    updateIntroLabel.text = @"Updated!";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy  HH:mm";
    updateTimeLabel.text = [NSString stringWithFormat:@"Last updated:  %@", [formatter stringFromDate:[NSDate date]]];
    
    [updateSpinner stopAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    updateSpinner.alpha = 0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDuration:0.3];
    self.tableView.tableHeaderView.height = 0;
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    [UIView commitAnimations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListingCell";
    
    ListingCell *cell = (ListingCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ListingCell instance];
    }
    
    Listing *listing = [listings objectAtIndex:indexPath.row];
    [cell setListing:listing];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kListingCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Listing *listing = [listings objectAtIndex:indexPath.row];
    [listingSelectionDelegate viewController:self didSelectListing:listing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!updateSpinner.isAnimating) {
        if (scrollView.contentOffset.y < -60) {
            updateIntroLabel.text = @"Release to update...";
            updateSpinner.alpha = 1;
        } else {
            updateIntroLabel.text = @"Pull down to update...";
            updateSpinner.alpha = 0.3;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -60) {            
            
        updateIntroLabel.text = @"Updating...";
        updateSpinner.alpha = 1;
        [updateSpinner startAnimating];
            
        [UIView beginAnimations:nil context:NULL];
        self.tableView.tableHeaderView.height = 60;
        self.tableView.tableHeaderView = self.tableView.tableHeaderView;
        [UIView commitAnimations];
            
        [self performSelector:@selector(updateFinished) withObject:nil afterDelay:2.5];
    }
}

@end
