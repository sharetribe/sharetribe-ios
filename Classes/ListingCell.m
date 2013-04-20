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

@synthesize imageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize usernameLabel;
@synthesize timeLabel;
@synthesize commentIconView;
@synthesize commentCountLabel;
@synthesize separator;

+ (ListingCell *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ListingCell" owner:self options:nil];
    if (nibContents.count > 0) {
        ListingCell *cell = [nibContents objectAtIndex:0];
        cell.backgroundColor = kSharetribeLightBrownColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        return cell;
    }
    return nil;
}

+ (NSString *)reuseIdentifier
{
    return @"ListingCell";
}

- (Listing *)listing
{
    return listing;
}

- (void)setListing:(Listing *)newListing
{
    listing = newListing;
    
    titleLabel.text = listing.fullTitle;
    subtitleLabel.text = [listing.description stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    usernameLabel.text = listing.author.shortName;
    timeLabel.text = [listing.createdAt agestamp];
    
    usernameLabel.width = [usernameLabel.text sizeWithFont:usernameLabel.font].width;
    timeLabel.x = usernameLabel.x + usernameLabel.width + 10;
    
    UIImage *categoryImage = [Listing iconForCategory:listing.category];
    NSURL *imageURL = [listing.imageURLs lastObject];
    if (imageURL != nil) {
        [imageView setImageWithURL:imageURL placeholderImage:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        imageView.image = categoryImage;
        imageView.contentMode = UIViewContentModeCenter;
    }
    
    if (listing.comments.count > 0) {
        commentCountLabel.text = [NSString stringWithFormat:@"%d", listing.comments.count];
        commentIconView.hidden = NO;
    } else {
        commentCountLabel.text = nil;
        commentIconView.hidden = YES;
    }
    
    int oneRowHeight = [@"Something" sizeWithFont:titleLabel.font].height;
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, 3*oneRowHeight) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    subtitleLabel.hidden = (titleLabel.height > 50);
    
    subtitleLabel.y = titleLabel.y + titleLabel.height + 3;
    subtitleLabel.height = [subtitleLabel.text sizeWithFont:subtitleLabel.font constrainedToSize:CGSizeMake(subtitleLabel.width, (usernameLabel.y-subtitleLabel.y-2)) lineBreakMode:NSLineBreakByWordWrapping].height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = kSharetribeLightOrangeColor;
    } else {
        self.backgroundColor = kSharetribeLightBrownColor;
    }
}

@end
