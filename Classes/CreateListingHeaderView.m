//
//  CreateListingHeaderView.m
//  Sharetribe
//
//  Created by Janne Käki on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateListingHeaderView.h"

#import "Listing.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateListingHeaderView ()
- (void)refreshVisuals;
@end

@implementation CreateListingHeaderView

@synthesize listingTypeLabelForRequests;
@synthesize listingTypeLabelForOffers;
@synthesize listingTypeTabForRequests;
@synthesize listingTypeTabForOffers;
@synthesize listingTypeButtonForRequests;
@synthesize listingTypeButtonForOffers;

@synthesize listingCategoryButtonForItems;
@synthesize listingCategoryButtonForFavors;
@synthesize listingCategoryButtonForRides;
@synthesize listingCategoryButtonForAccommodation;

@synthesize listingCategoryPointerView;
@synthesize listingCategoryIntroLabel;
@synthesize listingCategoryTypeLabel;
@synthesize listingCategoryBackgroundView;

@synthesize formBackgroundView;

@synthesize listingCategoryButtons;

@synthesize delegate;

+ (CreateListingHeaderView *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"CreateListingHeaderView" owner:self options:nil];
    if (nibContents.count > 0) {
        return [nibContents objectAtIndex:0];
    }
    return nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    formBackgroundView.backgroundColor = kSharetribeBrownColor;
    listingCategoryBackgroundView.backgroundColor = kSharetribeLightBrownColor;
    
    UIView *topBackgroundView = [[UIView alloc] init];
    topBackgroundView.backgroundColor = kSharetribeLightBrownColor;
    topBackgroundView.frame = CGRectMake(0, -460, 320, 460+self.height);
    topBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:topBackgroundView];
    [self sendSubviewToBack:topBackgroundView];
    
    listingCategoryButtonForItems.tag = ListingCategoryItem;
    listingCategoryButtonForFavors.tag = ListingCategoryFavor;
    listingCategoryButtonForRides.tag = ListingCategoryRide;
    listingCategoryButtonForAccommodation.tag = ListingCategoryAccommodation;
    
    listingTypeTabForRequests.layer.cornerRadius = 7;
    listingTypeTabForRequests.layer.borderColor = kSharetribeBrownColor.CGColor;
    
    listingTypeTabForOffers.layer.cornerRadius = 7;
    listingTypeTabForOffers.layer.borderColor = kSharetribeBrownColor.CGColor;
    
    self.listingCategoryButtons = [NSArray arrayWithObjects:listingCategoryButtonForItems, listingCategoryButtonForFavors, listingCategoryButtonForRides, listingCategoryButtonForAccommodation, nil];
    
    for (UIButton *button in listingCategoryButtons) {
        [button setImage:[button imageForState:UIControlStateNormal] forState:UIControlStateHighlighted];
    }
}

- (void)dealloc
{
}

- (IBAction)listingTypeSelected:(UIButton *)sender
{
    if (sender == listingTypeButtonForRequests) {
        [self setListingType:ListingTypeRequest];
    } else {
        [self setListingType:ListingTypeOffer];
    }
        
    [delegate listingTypeSelected:type];
}

- (IBAction)listingCategorySelected:(UIButton *)sender
{       
    [self setListingCategory:sender.tag];
    
    [delegate listingCategorySelected:category];
}

- (void)setListingType:(ListingType)newType
{
    type = newType;
    [self refreshVisuals];
}

- (void)setListingCategory:(ListingCategory)newCategory
{
    category = newCategory;
    [self refreshVisuals];
}

- (void)refreshVisuals
{
    if (category == kNoListingCategory) {
        listingCategoryPointerView.hidden = YES;
        listingCategoryTypeLabel.hidden = YES;
        self.height = 416;
    } else {
        listingCategoryPointerView.hidden = NO;
        listingCategoryTypeLabel.hidden = NO;
        self.height = 250;
    }
    
    if (category == ListingCategoryItem) {
        listingCategoryTypeLabel.text = @"an item";
    } else if (category == ListingCategoryFavor) {
        listingCategoryTypeLabel.text = @"a favor";
    } else if (category == ListingCategoryRide) {
        listingCategoryTypeLabel.text = @"a ride";
    } else if (category == ListingCategoryAccommodation) {
        listingCategoryTypeLabel.text = @"accommodation";
    } else if (category == kNoListingCategory) {
        listingCategoryTypeLabel.text = nil;
    }
    
    for (ButtonWithBackgroundView *button in listingCategoryButtons) {
        if (button.tag == category) {
            
            button.backgroundView.backgroundColor = kSharetribeLightBrownColor;
            button.backgroundView.layer.borderColor = [UIColor orangeColor].CGColor;
            button.backgroundView.layer.borderWidth = 1;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            listingCategoryPointerView.x = button.x + button.width/2 - listingCategoryPointerView.width/2;
            [UIView commitAnimations];
            
        } else {
            
            button.backgroundView.backgroundColor = kSharetribeLightishBrownColor;
            button.backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
            button.backgroundView.layer.borderWidth = 0;
        }
    }
    
    if (type == ListingTypeRequest) {
        listingCategoryIntroLabel.text = @"I need ";
        listingTypeTabForRequests.backgroundColor = kSharetribeBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 0;
        listingTypeTabForOffers.backgroundColor = kSharetribeLightishBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 1;
    } else {
        listingCategoryIntroLabel.text = @"I want to offer ";
        listingTypeTabForRequests.backgroundColor = kSharetribeLightishBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 1;
        listingTypeTabForOffers.backgroundColor = kSharetribeBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 0;
    }
    
    if (category == kNoListingCategory) {
        listingCategoryIntroLabel.text = @"Item, favor, ride, or accommodation?";
        listingCategoryIntroLabel.textColor = kSharetribeDarkBrownColor;
        listingCategoryBackgroundView.backgroundColor = kSharetribeLightishBrownColor;
    } else {
        listingCategoryIntroLabel.textColor = [UIColor blackColor];
        listingCategoryBackgroundView.backgroundColor = kSharetribeLightBrownColor;
    }
    
    listingCategoryIntroLabel.width = [listingCategoryIntroLabel.text sizeWithFont:listingCategoryIntroLabel.font].width;
    if (listingCategoryIntroLabel.width > 280) {
        listingCategoryIntroLabel.width = 280;
    }
    listingCategoryTypeLabel.width = [listingCategoryTypeLabel.text sizeWithFont:listingCategoryTypeLabel.font].width;
    
    int totalLabelWidth = listingCategoryIntroLabel.width + listingCategoryTypeLabel.width;
    listingCategoryIntroLabel.x = (320 - totalLabelWidth)/2;
    listingCategoryTypeLabel.x = listingCategoryIntroLabel.x + listingCategoryIntroLabel.width;
}

@end

@implementation ButtonWithBackgroundView

@synthesize backgroundView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundView.layer.cornerRadius = 5;
}

- (void)dealloc
{
    self.backgroundView = nil;
}

@end
