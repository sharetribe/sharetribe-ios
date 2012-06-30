//
//  ListingsTopViewController.m
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsTopViewController.h"

#import "Listing.h"
#import "ListingViewController.h"

@implementation ListingsTopViewController

@synthesize listViewer;
@synthesize mapViewer;
@synthesize search;
@synthesize dismissSearchButton;

@dynamic listings;
@synthesize listingType;

- (id)initWithListingType:(ListingType)type
{
    if ((self = [super init])) {
        self.listingType = type;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSArray *)listings
{
    return listViewer.listings;
}

- (void)setListings:(NSArray *)newListings
{
    listViewer.listings = newListings;
    mapViewer.listings = newListings;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listViewer = [[ListingsListViewController alloc] init];
    self.mapViewer = [[ListingsMapViewController alloc] init];
    
    [self.view addSubview:listViewer.view];
    [self.view addSubview:mapViewer.view];
    
    listViewer.view.y -= 20;
    mapViewer.view.y -= 20;
    
    mapViewer.view.hidden = YES;
    frontViewer = listViewer;
    
    listViewer.listingSelectionDelegate = self;
    mapViewer.listingSelectionDelegate = self;
    
    self.search = [[UISearchBar alloc] init];
    search.frame = CGRectMake(0, 0, 180, 44);
    search.tintColor = kKassiDarkGreenColor;
    search.delegate = self;
    // [[search.subviews objectAtIndex:0] removeFromSuperview];
    search.userInteractionEnabled = NO;

    UIView *titleView = [[UIView alloc] init];
    titleView.frame = CGRectMake(0, 0, 180, 44);
    [titleView addSubview:search];
    self.navigationItem.titleView = titleView;
    
    self.dismissSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissSearchButton.frame = CGRectMake(0, 0, 320, 460);
    dismissSearchButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    [dismissSearchButton addTarget:search action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    dismissSearchButton.hidden = YES;
    [self.view addSubview:dismissSearchButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-map"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewChangeButtonPressed:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewChoiceChanged:) name:kNotificationForFlippingView object:nil];
    
    // dummy data for demo purposes:
    NSArray *allListings = [Listing listingsFromArrayOfDicts:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"listings-data" ofType:@"plist"]]];
    NSMutableArray *relevantListings = [NSMutableArray array];
    for (Listing *listing in allListings) {
        if (listing.type == self.listingType) {
            [relevantListings addObject:listing];
        }
    }
    self.listings = relevantListings;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForFlippingView object:self.viewChoice];
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
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"icon-list"]];
    } else {
        frontViewer = listViewer;
        listViewer.view.hidden = NO;
        mapViewer.view.hidden = YES;
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"icon-map"]];
    }
    
    [frontViewer viewWillAppear:animated];
    
    if (animated) {
        [UIView commitAnimations];
    }
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

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    dismissSearchButton.hidden = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    dismissSearchButton.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
