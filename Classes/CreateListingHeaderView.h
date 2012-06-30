//
//  CreateListingHeaderView.h
//  Kassi
//
//  Created by Janne Käki on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@protocol ListingTypeSelectionDelegate <NSObject>
- (void)listingTypeSelected:(ListingType)type;
- (void)listingTargetSelected:(ListingTarget)target;
@end

@interface CreateListingHeaderView : UIView {

    ListingType type;
    ListingTarget target;
}

@property (strong, nonatomic) IBOutlet UILabel *listingTypeLabelForRequests;
@property (strong, nonatomic) IBOutlet UILabel *listingTypeLabelForOffers;
@property (strong, nonatomic) IBOutlet UIView *listingTypeTabForRequests;
@property (strong, nonatomic) IBOutlet UIView *listingTypeTabForOffers;
@property (strong, nonatomic) IBOutlet UIView *listingTypeButtonForRequests;
@property (strong, nonatomic) IBOutlet UIView *listingTypeButtonForOffers;

@property (strong, nonatomic) IBOutlet UIButton *listingTargetButtonForItems;
@property (strong, nonatomic) IBOutlet UIButton *listingTargetButtonForServices;
@property (strong, nonatomic) IBOutlet UIButton *listingTargetButtonForRides;
@property (strong, nonatomic) IBOutlet UIButton *listingTargetButtonForAccommodation;

@property (strong, nonatomic) IBOutlet UIView *listingTargetPointerView;
@property (strong, nonatomic) IBOutlet UILabel *listingTargetIntroLabel;
@property (strong, nonatomic) IBOutlet UILabel *listingTargetTypeLabel;
@property (strong, nonatomic) IBOutlet UIView *listingTargetBackgroundView;

@property (strong, nonatomic) IBOutlet UIView *formBackgroundView;

@property (strong, nonatomic) NSArray *listingTargetButtons;

@property (unsafe_unretained, nonatomic) id<ListingTypeSelectionDelegate> delegate;

+ (CreateListingHeaderView *)instance;

- (void)setListingType:(ListingType)newType;
- (void)setListingTarget:(ListingTarget)newTarget;

- (IBAction)listingTypeSelected:(UIButton *)sender;
- (IBAction)listingTargetSelected:(UIButton *)sender;

@end

@interface ButtonWithBackgroundView : UIButton
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@end