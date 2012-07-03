//
//  ListingCell.m
//  Kassi
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

@synthesize imageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize usernameLabel;
@synthesize timeLabel;

+ (ListingCell *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ListingCell" owner:self options:nil];
    if (nibContents.count > 0) {
        ListingCell *cell = [nibContents objectAtIndex:0];
        cell.backgroundColor = kKassiLightBrownColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        return cell;
    }
    return nil;
}

- (Listing *)listing
{
    return listing;
}

- (void)setListing:(Listing *)newListing
{
    listing = newListing;
    
    if (listing.shareType != nil) {
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", listing.shareType.capitalizedString, listing.title];
    } else {
        titleLabel.text = listing.title;
    }
    subtitleLabel.text = [listing.description stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    usernameLabel.text = listing.author.name;
    timeLabel.text = [listing.createdAt agestamp];
    
    UIImage *categoryImage = [Listing iconForCategory:listing.category];
    NSString *imageURL = [listing.imageURLs lastObject];
    if (imageURL != nil) {
        [imageView setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:categoryImage];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        imageView.image = categoryImage;
        imageView.contentMode = UIViewContentModeCenter;
    }
    
    int oneRowHeight = [@"Something" sizeWithFont:titleLabel.font].height;
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, 3*oneRowHeight) lineBreakMode:UILineBreakModeWordWrap].height;
    
    subtitleLabel.y = titleLabel.y + titleLabel.height + 3;
    subtitleLabel.height = [subtitleLabel.text sizeWithFont:subtitleLabel.font constrainedToSize:CGSizeMake(subtitleLabel.width, (usernameLabel.y-subtitleLabel.y-2)) lineBreakMode:UILineBreakModeWordWrap].height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = kKassiLightOrangeColor;
    } else {
        self.backgroundColor = kKassiLightBrownColor;
    }
}

@end
