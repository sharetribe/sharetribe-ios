//
//  ListingsTopViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingsListViewController.h"
#import "ListingsMapViewController.h"
#import "Listing.h"

#define kViewChoiceList @"list"
#define kViewChoiceMap  @"map"

@protocol ListingSelectionDelegate <NSObject>
- (void)viewController:(UIViewController *)viewer didSelectListing:(Listing *)listing;
@end

@interface ListingsTopViewController : UIViewController <UISearchBarDelegate, ListingSelectionDelegate>

@property (strong, nonatomic) ListingsListViewController *listViewer;
@property (strong, nonatomic) ListingsMapViewController *mapViewer;
@property (strong, nonatomic) UISearchBar *search;
@property (strong, nonatomic) UIButton *dismissSearchButton;

@property (copy, nonatomic) NSArray *listings;
@property (assign) ListingType listingType;

- (id)initWithListingType:(ListingType)type;

- (void)setViewChoice:(NSString *)viewChoice animated:(BOOL)animated;
- (NSString *)viewChoice;
- (NSString *)flippedViewChoice;

@end
