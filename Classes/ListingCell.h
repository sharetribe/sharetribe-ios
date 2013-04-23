//
//  ListingCell.h
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Listing.h"

#define kListingCellHeight 90

@interface ListingCell : UITableViewCell

@property (nonatomic, strong) Listing *listing;

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UIImageView *listingImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *listingImageSpinner;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UIView *categoryView;
@property (nonatomic, weak) IBOutlet UILabel *categoryIconView;
@property (nonatomic, weak) IBOutlet UILabel *shareTypeLabel;

@property (nonatomic, weak) IBOutlet UIView *priceView;
@property (nonatomic, weak) IBOutlet UILabel *priceIconView;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;

@property (nonatomic, weak) IBOutlet UIView *separator;

+ (ListingCell *)instance;
+ (NSString *)reuseIdentifier;

@end
