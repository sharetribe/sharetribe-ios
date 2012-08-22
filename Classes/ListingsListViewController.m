//
//  ListingsListViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsListViewController.h"

#import "ClockStampView.h"
#import "Listing.h"
#import "ListingCell.h"
#import "ListingViewController.h"
#import "ListingsTopViewController.h"
#import "SharetribeAPIClient.h"

@interface ListingsListViewController () <ClockStampViewDelegate> {
    NSMutableArray *listings;
    BOOL refreshingTopOfList;
    BOOL gettingNextPage;
}

@property (strong) ClockStampView *clockStampView;
@property (strong) UIView *footer;
@property (strong) UIActivityIndicatorView *footerSpinner;

@end

@implementation ListingsListViewController

@synthesize tableView = _tableView;
@synthesize header;
@synthesize listingCollectionViewDelegate;

@synthesize currentPage;
@synthesize numberOfPages;
@synthesize itemsPerPage;
@synthesize disallowsRefreshing;

@synthesize clockStampView;
@synthesize footer;
@synthesize footerSpinner;

- (void)addListings:(NSArray *)newListings
{
    if (listings == nil) {
        listings = [NSMutableArray array];
    }
    
    for (Listing *newListing in newListings) {
        NSInteger oldIndex = [listings indexOfObject:newListing];
        if (oldIndex != NSNotFound) {
            [listings removeObjectAtIndex:oldIndex];
        }
        [listings addObject:newListing];
    }
    
    [listings sortUsingFunction:compareListingsByDate context:NULL];
    [self.tableView reloadData];
    
    if (listings.count > 0 && refreshingTopOfList) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)clearAllListings
{
    [listings removeAllObjects];
    [self.tableView reloadData];
    
    currentPage = kFirstPage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = kSharetribeLightBrownColor;
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.clockStampView = [[ClockStampView alloc] initWithDelegate:self];
    
    if (!disallowsRefreshing) {
        self.header = [[PullDownToRefreshHeaderView alloc] init];
        self.tableView.tableHeaderView = header;
    }
    
    self.footer = [[UIView alloc] init];
    footer.frame = CGRectMake(0, 0, 320, 60);
    self.footerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    footerSpinner.frame = CGRectMake((320-20)/2, (60-20)/2, 20, 20);
    footerSpinner.hidesWhenStopped = NO;
    [footer addSubview:footerSpinner];
    
    [self observeNotification:kNotificationForDidRefreshListing withSelector:@selector(listingRefreshed:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self stopObservingAllNotifications];
    
    self.listingCollectionViewDelegate = nil;
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

- (void)startIndicatingRefresh
{
    [header startIndicatingRefreshWithTableView:self.tableView];
}

- (void)updateFinished
{
    [header updateFinishedWithTableView:self.tableView];
    
    refreshingTopOfList = NO;
    gettingNextPage = NO;
    [footerSpinner stopAnimating];
    
    if (currentPage < numberOfPages) {
        self.tableView.tableFooterView = footer;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)listingRefreshed:(NSNotification *)notification
{
    NSInteger index = [listings indexOfObject:notification.object];
    if (index != NSNotFound) {
        [listings replaceObjectAtIndex:index withObject:notification.object];
    }
}

#pragma mark - UITableViewDataSource

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
    ListingCell *cell = (ListingCell *) [tableView dequeueReusableCellWithIdentifier:[ListingCell reuseIdentifier]];
    if (cell == nil) {
        cell = [ListingCell instance];
    }
    
    Listing *listing = [listings objectAtIndex:indexPath.row];
    [cell setListing:listing];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kListingCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Listing *listing = [listings objectAtIndex:indexPath.row];
    
    if (listingCollectionViewDelegate != nil) {
        
        [listingCollectionViewDelegate viewController:self didSelectListing:listing];
        
    } else {
        
        ListingViewController *listingViewer = [[ListingViewController alloc] init];
        listingViewer.listing = listing;
        [self.navigationController pushViewController:listingViewer animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [clockStampView scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [header tableViewDidScroll:self.tableView];
    
    if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.height-10) {
        if (!gettingNextPage && (currentPage < numberOfPages)) {
            gettingNextPage = YES;
            [footerSpinner startAnimating];
            [listingCollectionViewDelegate viewController:self wantsToRefreshPage:currentPage+1];
        }
    }
    
    [clockStampView scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([header triggersRefreshAsTableViewEndsDragging:self.tableView]) {
        refreshingTopOfList = YES;
        [listingCollectionViewDelegate viewController:self wantsToRefreshPage:1];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [clockStampView scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - ClockStampViewDelegate

- (NSDate *)timeForIndexPath:(NSIndexPath *)indexPath
{
    Listing *listing = [listings objectAtIndex:indexPath.row];
    return listing.createdAt;
}

- (BOOL)clockStampViewShouldShow
{
    return (listings.count > 5);
}

@end
