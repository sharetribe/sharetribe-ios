//
//  CreateListingHeaderView.m
//  Kassi
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

@synthesize listingTargetButtonForItems;
@synthesize listingTargetButtonForServices;
@synthesize listingTargetButtonForRides;
@synthesize listingTargetButtonForAccommodation;

@synthesize listingTargetPointerView;
@synthesize listingTargetIntroLabel;
@synthesize listingTargetTypeLabel;
@synthesize listingTargetBackgroundView;

@synthesize formBackgroundView;

@synthesize listingTargetButtons;

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
    formBackgroundView.backgroundColor = kKassiBrownColor;
    listingTargetBackgroundView.backgroundColor = kKassiLightBrownColor;
    
    UIView *topBackgroundView = [[UIView alloc] init];
    topBackgroundView.backgroundColor = kKassiLightBrownColor;
    topBackgroundView.frame = CGRectMake(0, -460, 320, 460+self.height);
    topBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:topBackgroundView];
    [self sendSubviewToBack:topBackgroundView];
    
    listingTargetButtonForItems.tag = ListingTargetItem;
    listingTargetButtonForServices.tag = ListingTargetService;
    listingTargetButtonForRides.tag = ListingTargetRide;
    listingTargetButtonForAccommodation.tag = ListingTargetAccommodation;
    
    listingTypeTabForRequests.layer.cornerRadius = 7;
    listingTypeTabForRequests.layer.borderColor = kKassiBrownColor.CGColor;
    
    listingTypeTabForOffers.layer.cornerRadius = 7;
    listingTypeTabForOffers.layer.borderColor = kKassiBrownColor.CGColor;
    
    self.listingTargetButtons = [NSArray arrayWithObjects:listingTargetButtonForItems, listingTargetButtonForServices, listingTargetButtonForRides, listingTargetButtonForAccommodation, nil];
    
    for (UIButton *button in listingTargetButtons) {
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

- (IBAction)listingTargetSelected:(UIButton *)sender
{       
    [self setListingTarget:sender.tag];
    
    [delegate listingTargetSelected:target];
}

- (void)setListingType:(ListingType)newType
{
    type = newType;
    [self refreshVisuals];
}

- (void)setListingTarget:(ListingTarget)newTarget
{
    target = newTarget;
    [self refreshVisuals];
}

- (void)refreshVisuals
{
    if (target == kNoListingTarget) {
        listingTargetPointerView.hidden = YES;
        listingTargetTypeLabel.hidden = YES;
        self.height = 416;
    } else {
        listingTargetPointerView.hidden = NO;
        listingTargetTypeLabel.hidden = NO;
        self.height = 250;
    }
    
    if (target == ListingTargetItem) {
        listingTargetTypeLabel.text = @"an item";
    } else if (target == ListingTargetService) {
        listingTargetTypeLabel.text = @"a service";
    } else if (target == ListingTargetRide) {
        listingTargetTypeLabel.text = @"a ride";
    } else if (target == ListingTargetAccommodation) {
        listingTargetTypeLabel.text = @"accommodation";
    } else if (target == kNoListingTarget) {
        listingTargetTypeLabel.text = nil;
    }
    
    for (ButtonWithBackgroundView *button in listingTargetButtons) {
        if (button.tag == target) {
            
            button.backgroundView.backgroundColor = kKassiLightBrownColor;
            button.backgroundView.layer.borderColor = [UIColor orangeColor].CGColor;
            button.backgroundView.layer.borderWidth = 1;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.1];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            listingTargetPointerView.x = button.x + button.width/2 - listingTargetPointerView.width/2;
            [UIView commitAnimations];
            
        } else {
            
            button.backgroundView.backgroundColor = kKassiLightishBrownColor;
            button.backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
            button.backgroundView.layer.borderWidth = 0;
        }
    }
    
    if (type == ListingTypeRequest) {
        listingTargetIntroLabel.text = @"I need ";
        listingTypeTabForRequests.backgroundColor = kKassiBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 0;
        listingTypeTabForOffers.backgroundColor = kKassiLightishBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 1;
    } else {
        listingTargetIntroLabel.text = @"I want to offer ";
        listingTypeTabForRequests.backgroundColor = kKassiLightishBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 1;
        listingTypeTabForOffers.backgroundColor = kKassiBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 0;
    }
    
    if (target == kNoListingTarget) {
        listingTargetIntroLabel.text = @"Item, service, ride, or accommodation?";
        listingTargetIntroLabel.textColor = kKassiDarkBrownColor;
        listingTargetBackgroundView.backgroundColor = kKassiLightishBrownColor;
    } else {
        listingTargetIntroLabel.textColor = [UIColor blackColor];
        listingTargetBackgroundView.backgroundColor = kKassiLightBrownColor;
    }
    
    listingTargetIntroLabel.width = [listingTargetIntroLabel.text sizeWithFont:listingTargetIntroLabel.font].width;
    if (listingTargetIntroLabel.width > 280) {
        listingTargetIntroLabel.width = 280;
    }
    listingTargetTypeLabel.width = [listingTargetTypeLabel.text sizeWithFont:listingTargetTypeLabel.font].width;
    
    int totalLabelWidth = listingTargetIntroLabel.width + listingTargetTypeLabel.width;
    listingTargetIntroLabel.x = (320 - totalLabelWidth)/2;
    listingTargetTypeLabel.x = listingTargetIntroLabel.x + listingTargetIntroLabel.width;
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
