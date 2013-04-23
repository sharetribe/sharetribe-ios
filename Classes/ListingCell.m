//
//  ListingCell.m
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingCell.h"

#import "User.h"
#import "NSDate+Sharetribe.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListingCell

+ (ListingCell *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ListingCell" owner:self options:nil];
    if (nibContents.count > 0) {
        ListingCell *cell = [nibContents objectAtIndex:0];
        return cell;
    }
    return nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userImageView.layer.cornerRadius = 5;
    self.listingImageView.layer.cornerRadius = 5;
    
    [self setSelected:NO];
}

+ (NSString *)reuseIdentifier
{
    return @"ListingCell";
}

- (void)setListing:(Listing *)listing
{
    _listing = listing;
    
    self.titleLabel.text = listing.title;
    self.subtitleLabel.text = [listing.description stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    self.usernameLabel.text = listing.author.shortName;
    self.timeLabel.text = [listing.createdAt agestamp];
    
    self.usernameLabel.width = [self.usernameLabel.text sizeWithFont:self.usernameLabel.font].width;
    self.timeLabel.x = self.usernameLabel.x + self.usernameLabel.width + 5;
    
    NSURL *imageURL = [listing.imageURLs lastObject];
    if (imageURL != nil) {
        self.listingImageView.hidden = NO;
        self.listingImageSpinner.hidden = NO;
        [self.listingImageSpinner startAnimating];
        self.listingImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.listingImageView setImageWithURL:imageURL placeholderImage:nil];
        self.titleLabel.width = self.listingImageView.left - self.titleLabel.x - 10;
    } else {
        self.listingImageView.hidden = YES;
        self.listingImageSpinner.hidden = YES;
        [self.listingImageSpinner stopAnimating];
        self.titleLabel.width = self.listingImageView.right - self.titleLabel.x;
    }
    
    [self.userImageView setImageWithURL:listing.author.pictureURL placeholderImage:nil];
    
    int oneRowHeight = [@"Something" sizeWithFont:self.titleLabel.font].height;
    self.titleLabel.height = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.titleLabel.width, 2 * oneRowHeight) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    self.shareTypeLabel.text = listing.localizedShareType;
    [self.shareTypeLabel sizeToFit];
    self.shareTypeLabel.height = self.categoryIconView.height;
    [self.categoryIconView setIconWithName:[Listing iconNameForItem:listing.category]];
    
    self.categoryView.x = self.titleLabel.x;
    self.categoryView.y = self.titleLabel.bottom + 1;
    self.categoryView.width = self.shareTypeLabel.right;
    
    if (listing.priceInCents > 0) {
        [self.priceIconView setIconWithName:@"tag"];
        self.priceLabel.text = listing.formattedPrice;
        self.priceView.hidden = NO;
        self.priceView.x = self.categoryView.right + 10;
        self.priceView.y = self.categoryView.y;
    } else {
        self.priceView.hidden = YES;
    }
    
    self.subtitleLabel.width = self.titleLabel.width;
    self.subtitleLabel.y = self.categoryView.bottom + 1;
    self.subtitleLabel.height = [self.subtitleLabel.text sizeWithFont:self.subtitleLabel.font constrainedToSize:CGSizeMake(self.subtitleLabel.width, (self.separator.y - self.subtitleLabel.y - 2)) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    self.subtitleLabel.hidden = (self.subtitleLabel.bottom > self.separator.y);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundView.backgroundColor = kSharetribeThemeColor;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.usernameLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.titleLabel.textColor = kSharetribeThemeColor;
        self.usernameLabel.textColor = kSharetribeThemeColor;
    }
}

@end
