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

@interface ListingsTopViewController : UIViewController <ListingCollectionView, ListingCollectionViewDelegate>

@property (strong, nonatomic) ListingsListViewController *listViewer;
@property (strong, nonatomic) ListingsMapViewController *mapViewer;

@property (strong) NSString *listingType;
@property (strong) NSString *listingCategory;
@property (strong) NSString *search;

- (id)initWithListingType:(NSString *)type;

- (void)refreshListings;

- (void)setViewChoice:(NSString *)viewChoice animated:(BOOL)animated;
- (NSString *)viewChoice;
- (NSString *)flippedViewChoice;

@end
