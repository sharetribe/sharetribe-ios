//
//  ListingsTopViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsTopViewController.h"

#import "Listing.h"
#import "ListingViewController.h"
#import "Location.h"
#import "SharetribeAPIClient.h"

@interface ListingsTopViewController () {
    
    UIViewController *frontViewer;
    BOOL clearPreviousListingsOnGettingResults;
}

@property (strong, nonatomic) UIImage *mapIcon;
@property (strong, nonatomic) UIImage *listIcon;
@property (strong, nonatomic) UIButton *viewChangeButton;

@end

@implementation ListingsTopViewController

@synthesize listViewer;
@synthesize mapViewer;

@synthesize listingType;
@synthesize listingCategory;
@synthesize search;

- (id)initWithListingType:(NSString *)type
{
    if ((self = [super init])) {
        self.listingType = type;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveListings:) name:kNotificationForDidReceiveListings object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newListingPosted:) name:kNotificationForDidPostListing object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)addListings:(NSArray *)listings
{
    [listViewer addListings:listings];
    [mapViewer addListings:listings];
}

- (void)clearAllListings
{
    [listViewer clearAllListings];
    [mapViewer clearAllListings];
}

- (void)refreshListings
{
    [self startIndicatingRefresh];
    if (search.length > 0) {
        [[SharetribeAPIClient sharedClient] getListingsOfType:listingType withSearch:search forPage:kFirstPage];
    } else {
        [[SharetribeAPIClient sharedClient] getListingsOfType:listingType inCategory:listingCategory forPage:kFirstPage];
    }
}

- (void)startIndicatingRefresh
{
    [listViewer startIndicatingRefresh];
}

- (void)didReceiveListings:(NSNotification *)notification
{
    if (clearPreviousListingsOnGettingResults) {
        [self clearAllListings];
        clearPreviousListingsOnGettingResults = NO;
    }
    
    NSString *resultType = [notification.userInfo objectForKey:kInfoKeyForListingType];
    if ([resultType isEqual:self.listingType]) {
        
        [self addListings:notification.object];
        
        listViewer.currentPage = [[notification.userInfo objectForKey:kInfoKeyForPage] intValue];
        listViewer.numberOfPages = [[notification.userInfo objectForKey:kInfoKeyForNumberOfPages] intValue];
        listViewer.itemsPerPage = [[notification.userInfo objectForKey:kInfoKeyForItemsPerPage] intValue];
        
        [listViewer updateFinished];
    }
}

- (void)newListingPosted:(NSNotification *)notification
{
    Listing *newListing = notification.object;
    if (newListing.type == self.listingType) {
        [self addListings:[NSArray arrayWithObject:newListing]];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listViewer = [[ListingsListViewController alloc] init];
    self.mapViewer = [[ListingsMapViewController alloc] init];
    
    [self.view addSubview:listViewer.view];
    [self.view addSubview:mapViewer.view];
    
    listViewer.view.frame = self.view.bounds;
    mapViewer.view.frame = self.view.bounds;
    
    mapViewer.view.hidden = YES;
    frontViewer = listViewer;
    
    listViewer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mapViewer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    listViewer.listingCollectionViewDelegate = self;
    mapViewer.listingCollectionViewDelegate = self;
    
    self.mapIcon = [UIImage imageWithIconNamed:@"map" pointSize:24 color:[UIColor whiteColor] insets:UIEdgeInsetsMake(5, 4, 0, 4)];
    self.listIcon = [UIImage imageWithIconNamed:@"list" pointSize:24 color:[UIColor whiteColor] insets:UIEdgeInsetsMake(5, 4, 0, 4)];
    
    self.viewChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.viewChangeButton.frame = CGRectMake(0, 0, 44, 44);
    [self.viewChangeButton setImage:self.mapIcon forState:UIControlStateNormal];
    [self.viewChangeButton addTarget:self action:@selector(viewChangeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewChangeButton setShadowWithOpacity:0.5 radius:2 offset:CGSizeMake(0, 1) usingDefaultPath:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.viewChangeButton];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewChoiceChanged:) name:kNotificationForDidFlipView object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *chosenViewChoice = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsKeyForViewChoice];
    if (chosenViewChoice != nil && ![chosenViewChoice isEqualToString:self.viewChoice]) {
        [self setViewChoice:chosenViewChoice animated:NO];
    }
    
    [frontViewer viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (IBAction)viewChangeButtonPressed:(UIBarButtonItem *)sender
{
    [self setViewChoice:self.flippedViewChoice animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidFlipView object:self.viewChoice];
    [[NSUserDefaults standardUserDefaults] setObject:self.viewChoice forKey:kDefaultsKeyForViewChoice];
}

- (void)viewChoiceChanged:(NSNotification *)notification
{
    [self setViewChoice:notification.object animated:NO];
}

- (void)setViewChoice:(NSString *)viewChoice animated:(BOOL)animated
{
    if ([viewChoice isEqualToString:self.viewChoice]) {
        return;
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.6];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
                               forView:self.view cache:NO];
    }
    
    [frontViewer viewWillDisappear:animated];
    
    if (frontViewer == listViewer) {
        frontViewer = mapViewer;
        mapViewer.view.hidden = NO;
        listViewer.view.hidden = YES;
        [self.viewChangeButton setImage:self.listIcon forState:UIControlStateNormal];
    } else {
        frontViewer = listViewer;
        listViewer.view.hidden = NO;
        mapViewer.view.hidden = YES;
        [self.viewChangeButton setImage:self.mapIcon forState:UIControlStateNormal];
    }
        
    [frontViewer viewWillAppear:animated];
        
    if (animated) {
        [UIView commitAnimations];
    }
    
    self.navigationItem.rightBarButtonItem = frontViewer.navigationItem.rightBarButtonItem;
}

- (NSString *)viewChoice
{
    if (frontViewer == listViewer) {
        return kViewChoiceList;
    } else {
        return kViewChoiceMap;
    }
}

- (NSString *)flippedViewChoice
{
    if (frontViewer == listViewer) {
        return kViewChoiceMap;
    } else {
        return kViewChoiceList;
    }
}

- (void)viewController:(UIViewController *)viewer didSelectListing:(Listing *)listing
{
    ListingViewController *listingViewer = [[ListingViewController alloc] init];
    listingViewer.listing = listing;
    [self.navigationController pushViewController:listingViewer animated:YES];
}

- (void)viewController:(UIViewController *)viewer didSelectListings:(NSArray *)listings
{
    ListingsListViewController *newListViewer = [[ListingsListViewController alloc] init];
    newListViewer.listingCollectionViewDelegate = self;
    newListViewer.title = [[(Listing *) [listings objectAtIndex:0] location] address];
    newListViewer.disallowsRefreshing = YES;
    [newListViewer addListings:listings];
    [self.navigationController pushViewController:newListViewer animated:YES];
}

- (void)viewController:(UIViewController *)viewer wantsToRefreshPage:(NSInteger)page
{
    if (page == kFirstPage) {
        clearPreviousListingsOnGettingResults = YES;
    }
    
    if (search.length > 0) {
        [[SharetribeAPIClient sharedClient] getListingsOfType:listingType withSearch:search forPage:page];
    } else {
        [[SharetribeAPIClient sharedClient] getListingsOfType:listingType inCategory:listingCategory forPage:page];
    }
}

- (void)viewController:(UIViewController *)viewer wantsToSearch:(NSString *)newSearch
{
    [self clearAllListings];
    
    self.search = newSearch;
    [self viewController:viewer wantsToRefreshPage:kFirstPage];
}

@end
