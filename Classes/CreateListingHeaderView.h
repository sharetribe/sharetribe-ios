//
//  CreateListingHeaderView.h
//  Sharetribe
//
//  Created by Janne Käki on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@protocol ListingTypeSelectionDelegate <NSObject>
- (void)listingTypeSelected:(ListingType)type;
- (void)listingCategorySelected:(ListingCategory)category;
@end

@interface CreateListingHeaderView : UIView {

    ListingType type;
    ListingCategory category;
}

@property (strong, nonatomic) IBOutlet UILabel *listingTypeLabelForRequests;
@property (strong, nonatomic) IBOutlet UILabel *listingTypeLabelForOffers;
@property (strong, nonatomic) IBOutlet UIView *listingTypeTabForRequests;
@property (strong, nonatomic) IBOutlet UIView *listingTypeTabForOffers;
@property (strong, nonatomic) IBOutlet UIView *listingTypeButtonForRequests;
@property (strong, nonatomic) IBOutlet UIView *listingTypeButtonForOffers;

@property (strong, nonatomic) IBOutlet UIButton *listingCategoryButtonForItems;
@property (strong, nonatomic) IBOutlet UIButton *listingCategoryButtonForFavors;
@property (strong, nonatomic) IBOutlet UIButton *listingCategoryButtonForRides;
@property (strong, nonatomic) IBOutlet UIButton *listingCategoryButtonForAccommodation;

@property (strong, nonatomic) IBOutlet UIView *listingCategoryPointerView;
@property (strong, nonatomic) IBOutlet UILabel *listingCategoryIntroLabel;
@property (strong, nonatomic) IBOutlet UILabel *listingCategoryTypeLabel;
@property (strong, nonatomic) IBOutlet UIView *listingCategoryBackgroundView;

@property (strong, nonatomic) IBOutlet UIView *formBackgroundView;

@property (strong, nonatomic) NSArray *listingCategoryButtons;

@property (unsafe_unretained, nonatomic) id<ListingTypeSelectionDelegate> delegate;

+ (CreateListingHeaderView *)instance;

- (void)setListingType:(ListingType)newType;
- (void)setListingCategory:(ListingCategory)newCategory;

- (IBAction)listingTypeSelected:(UIButton *)sender;
- (IBAction)listingCategorySelected:(UIButton *)sender;

@end

@interface ButtonWithBackgroundView : UIButton
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@end