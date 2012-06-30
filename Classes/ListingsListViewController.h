//
//  ListingsListViewController.h
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListingSelectionDelegate;

@interface ListingsListViewController : UITableViewController {

    NSMutableArray *listings;
}

@property (copy) NSArray *listings;

@property (strong) UIView *header;
@property (strong) UILabel *updateIntroLabel;
@property (strong) UILabel *updateTimeLabel;
@property (strong) UIActivityIndicatorView *updateSpinner;

@property (unsafe_unretained) id<ListingSelectionDelegate> listingSelectionDelegate;

@end
