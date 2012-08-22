//
//  FeedbackListCell.m
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import "FeedbackListCell.h"

@implementation FeedbackListCell

+ (FeedbackListCell *)newInstance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"FeedbackListCell" owner:self options:nil];
    if (nibContents.count > 0) {
        FeedbackListCell *cell = [nibContents objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

+ (NSString *)reuseIdentifier
{
    return @"FeedbackListCell";
}

@end
