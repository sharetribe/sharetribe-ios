//
//  ListingCell.h
//  Kassi
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Listing.h"

#define kListingCellHeight 110

@interface ListingCell : UITableViewCell {

    Listing *listing;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

+ (ListingCell *)instance;

- (Listing *)listing;
- (void)setListing:(Listing *)listing;

@end
