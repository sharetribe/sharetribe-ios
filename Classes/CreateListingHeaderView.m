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

#define kListingCategoryButtonTagForItems  1000
#define kListingCategoryButtonTagForFavors 2000
#define kListingCategoryButtonTagForRides  3000
#define kListingCategoryButtonTagForSpace  4000

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
@synthesize listingCategoryButtonForSpace;

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
    
    [listingCategoryButtonForItems setImage:[UIImage imageWithIconNamed:@"box" pointSize:30 color:kSharetribeDarkBrownColor insets:UIEdgeInsetsMake(4, 0, 0, 0)] forState:UIControlStateNormal];
    [listingCategoryButtonForFavors setImage:[UIImage imageWithIconNamed:@"heart" pointSize:32 color:kSharetribeDarkBrownColor insets:UIEdgeInsetsMake(4, 0, 0, 0)] forState:UIControlStateNormal];
    [listingCategoryButtonForRides setImage:[UIImage imageWithIconNamed:@"car" pointSize:32 color:kSharetribeDarkBrownColor insets:UIEdgeInsetsMake(4, 0, 0, 0)] forState:UIControlStateNormal];
    [listingCategoryButtonForSpace setImage:[UIImage imageWithIconNamed:@"warehouse" pointSize:32 color:kSharetribeDarkBrownColor insets:UIEdgeInsetsMake(4, 0, 0, 0)] forState:UIControlStateNormal];
    
    listingCategoryButtonForItems.tag = kListingCategoryButtonTagForItems;
    listingCategoryButtonForFavors.tag = kListingCategoryButtonTagForFavors;
    listingCategoryButtonForRides.tag = kListingCategoryButtonTagForRides;
    listingCategoryButtonForSpace.tag = kListingCategoryButtonTagForSpace;
    
    listingTypeTabForRequests.layer.cornerRadius = 7;
    listingTypeTabForRequests.layer.borderColor = kSharetribeBrownColor.CGColor;
    
    listingTypeTabForOffers.layer.cornerRadius = 7;
    listingTypeTabForOffers.layer.borderColor = kSharetribeBrownColor.CGColor;
    
    self.listingCategoryButtons = [NSArray arrayWithObjects:listingCategoryButtonForItems, listingCategoryButtonForFavors, listingCategoryButtonForRides, listingCategoryButtonForSpace, nil];
    
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
        [self setListingType:kListingTypeRequest];
    } else {
        [self setListingType:kListingTypeOffer];
    }
        
    [delegate listingTypeSelected:type];
}

- (NSString *)categoryForButton:(UIButton *)button
{
    switch (button.tag) {
        case kListingCategoryButtonTagForItems:
            return kListingCategoryItem;
        case kListingCategoryButtonTagForFavors:
            return kListingCategoryFavor;
        case kListingCategoryButtonTagForRides:
            return kListingCategoryRideshare;
        case kListingCategoryButtonTagForSpace:
            return kListingCategorySpace;
        default:
            return nil;
    }
}

- (IBAction)listingCategorySelected:(UIButton *)sender
{
    NSString *selectedCategory = [self categoryForButton:sender];
    [self setListingCategory:selectedCategory];
    [delegate listingCategorySelected:selectedCategory];
}

- (void)setListingType:(NSString *)newType
{
    type = newType;
    [self refreshVisuals];
}

- (void)setListingCategory:(NSString *)newCategory
{
    category = newCategory;
    [self refreshVisuals];
}

- (void)refreshVisuals
{
    if (category == nil) {
        listingCategoryPointerView.hidden = YES;
        listingCategoryTypeLabel.hidden = YES;
        self.height = 416;
    } else {
        listingCategoryPointerView.hidden = NO;
        listingCategoryTypeLabel.hidden = NO;
        self.height = 250;
    }
        
    for (ButtonWithBackgroundView *button in listingCategoryButtons) {
        NSString *buttonCategory = [self categoryForButton:button];
        if ([buttonCategory isEqual:category]) {
            
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
    
    if ([type isEqual:kListingTypeRequest]) {
        listingTypeTabForRequests.backgroundColor = kSharetribeBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 0;
        listingTypeTabForOffers.backgroundColor = kSharetribeLightishBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 1;
    } else {
        listingTypeTabForRequests.backgroundColor = kSharetribeLightishBrownColor;
        listingTypeTabForRequests.layer.borderWidth = 1;
        listingTypeTabForOffers.backgroundColor = kSharetribeBrownColor;
        listingTypeTabForOffers.layer.borderWidth = 0;
    }
    
    if (category == nil) {
        
        listingCategoryIntroLabel.text = NSLocalizedString(@"listing.intro.general", @"");
        listingCategoryTypeLabel.text = nil;
        
        listingCategoryIntroLabel.textColor = kSharetribeDarkBrownColor;
        listingCategoryBackgroundView.backgroundColor = kSharetribeLightishBrownColor;
        
    } else {
        
        NSString *introLabelKey = [NSString stringWithFormat:@"listing.intro.%@", type];
        listingCategoryIntroLabel.text = [NSLocalizedString(introLabelKey, @"") stringByAppendingString:@" "];
        NSString *categoryLabelKey = [NSString stringWithFormat:@"listing.intro.%@_target.%@", type, category];
        listingCategoryTypeLabel.text = NSLocalizedString(categoryLabelKey, @"");
        
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
