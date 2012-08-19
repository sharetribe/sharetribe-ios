//
//  ListingsTopViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingCollectionView.h"
#import "ListingCollectionViewDelegate.h"
#import "ListingsListViewController.h"
#import "ListingsMapViewController.h"
#import "Listing.h"

#define kViewChoiceList @"list"
#define kViewChoiceMap  @"map"

@interface ListingsTopViewController : UIViewController <ListingCollectionView, ListingCollectionViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) ListingsListViewController *listViewer;
@property (strong, nonatomic) ListingsMapViewController *mapViewer;
@property (strong, nonatomic) UISearchBar *search;
@property (strong, nonatomic) UIButton *dismissSearchButton;

@property (strong) NSString* listingType;

- (id)initWithListingType:(NSString *)type;

- (void)refreshListings;

- (void)setViewChoice:(NSString *)viewChoice animated:(BOOL)animated;
- (NSString *)viewChoice;
- (NSString *)flippedViewChoice;

@end
