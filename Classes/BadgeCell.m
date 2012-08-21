//
//  BadgeCell.m
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import "BadgeCell.h"

#import "Badge.h"
#import "NSDate+Sharetribe.h"
#import "UIImageView+AFNetworking.h"

@interface BadgeCell () {
    Badge *badge;
}
@end

@implementation BadgeCell

@synthesize iconView;
@synthesize titleLabel;
@synthesize descriptionLabel;
@synthesize dateLabel;

@dynamic badge;

- (Badge *)badge
{
    return badge;
}

- (void)setBadge:(Badge *)newBadge
{
    badge = newBadge;
    
    titleLabel.text = [[badge.name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
    descriptionLabel.text = badge.description;
    dateLabel.text = [badge.createdAt agestamp];
    
    descriptionLabel.height = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabel.width, 1000) lineBreakMode:UILineBreakModeCharacterWrap].height;
    dateLabel.y = descriptionLabel.y+descriptionLabel.height;
    
    [iconView setImageWithURL:badge.pictureURL];
}

- (CGFloat)heightWithBadge:(Badge *)aBadge
{
    int y = descriptionLabel.y + [aBadge.description sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabel.width, 1000) lineBreakMode:UILineBreakModeCharacterWrap].height;
    y += dateLabel.height+8;
    return y;
}

+ (BadgeCell *)newInstance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"BadgeCell" owner:self options:nil];
    if (nibContents.count > 0) {
        BadgeCell *cell = [nibContents objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

+ (NSString *)reuseIdentifier
{
    return @"BadgeCell";
}

@end
