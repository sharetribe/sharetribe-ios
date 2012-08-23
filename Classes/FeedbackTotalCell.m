//
//  FeedbackTotalCell.m
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import "FeedbackTotalCell.h"

@implementation FeedbackTotalCell

@synthesize percentageLabel;
@synthesize detailLabel;
@synthesize whatIsThisButton;

+ (FeedbackTotalCell *)newInstance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"FeedbackTotalCell" owner:self options:nil];
    if (nibContents.count > 0) {
        FeedbackTotalCell *cell = [nibContents objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

+ (NSString *)reuseIdentifier
{
    return @"FeedbackTotalCell";
}

- (IBAction)whatIsThisButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"profile.feedback", @"") message:NSLocalizedString(@"profile.explanation.feedback", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"button.ok", @"") otherButtonTitles:nil];
    [alert show];
}

@end
