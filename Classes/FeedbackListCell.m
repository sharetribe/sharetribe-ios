//
//  FeedbackListCell.m
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import "FeedbackListCell.h"

#import "Feedback.h"
#import "Grade.h"
#import "User.h"
#import "NSDate+Sharetribe.h"

@implementation FeedbackListCell

@synthesize feedback;

@synthesize gradeIconView;
@synthesize authorNameLabel;
@synthesize timestampLabel;
@synthesize textLabel;

- (void)setFeedback:(Feedback *)newFeedback
{
    feedback = newFeedback;
    
    int grade = feedback.grade*4+1;
    gradeIconView.image = [Grade bigIconForGrade:grade];
    authorNameLabel.text = feedback.author.givenName;
    timestampLabel.text = feedback.createdAt.agestamp;
    textLabel.text = [NSString stringWithFormat:@"“%@”", feedback.text];
    
    authorNameLabel.width = [authorNameLabel.text sizeWithFont:authorNameLabel.font].width;
    timestampLabel.x = authorNameLabel.x+authorNameLabel.width+8;
    textLabel.height = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(textLabel.width, 1000) lineBreakMode:UILineBreakModeWordWrap].height;
}

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

+ (CGFloat)heightWithFeedback:(Feedback *)feedback
{
    static FeedbackListCell *prototypeCell = nil;
    if (prototypeCell == nil) {
        prototypeCell = [FeedbackListCell newInstance];
    }
    prototypeCell.feedback = feedback;
    return MAX((prototypeCell.gradeIconView.y*2+prototypeCell.gradeIconView.height+4), (prototypeCell.textLabel.y+prototypeCell.textLabel.height+16));
}

@end
