//
//  ListingsListViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListingCollectionView.h"
#import "ListingCollectionViewDelegate.h"
#import "PullDownToRefreshHeaderView.h"

@interface ListingsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ListingCollectionView>

@property (strong) UITableView *tableView;
@property (strong) PullDownToRefreshHeaderView *header;

@property (unsafe_unretained) id<ListingCollectionViewDelegate> listingCollectionViewDelegate;

@property (assign) NSInteger currentPage;
@property (assign) NSInteger numberOfPages;
@property (assign) NSInteger itemsPerPage;
@property (assign) BOOL disallowsRefreshing;

- (void)startIndicatingRefresh;
- (void)updateFinished;

@end
