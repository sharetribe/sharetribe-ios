//
//  ListingCell.m
//  Kassi
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingCell.h"

#import "User.h"
#import "NSDate+Extras.h"
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
    
    if (listing.transactionType != nil) {
        titleLabel.text = [NSString stringWithFormat:@"%@: %@", listing.transactionType.capitalizedString, listing.title];
    } else {
        titleLabel.text = listing.title;
    }
    subtitleLabel.text = [listing.text stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    usernameLabel.text = listing.author.name;
    timeLabel.text = [listing.date agestamp];
    
    if (listing.image != nil) {
        imageView.image = listing.image;
        imageView.contentMode = UIViewContentModeScaleToFill;
    } else {
        imageView.image = [Listing iconForTarget:listing.target];
        imageView.contentMode = UIViewContentModeCenter;
    }
    
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, usernameLabel.y) lineBreakMode:UILineBreakModeWordWrap].height;
    
    subtitleLabel.y = titleLabel.y + titleLabel.height+2;
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
