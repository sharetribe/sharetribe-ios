//
//  GradeCell.m
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import "GradeCell.h"

#import "Grade.h"

@interface GradeCell () {
    Grade *grade;
}
@end

@implementation GradeCell

@synthesize iconView;
@synthesize titleLabel;
@synthesize amountLabel;

@dynamic grade;

- (Grade *)grade
{
    return grade;
}

- (void)setGrade:(Grade *)newGrade
{
    grade = newGrade;
    
    iconView.image = grade.icon;
    titleLabel.text = grade.title;
    amountLabel.text = [NSString stringWithFormat:@"%d", grade.amount];
    
    iconView.alpha = (grade.amount > 0) ? 1 : 0.4;
}

+ (GradeCell *)newInstance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"GradeCell" owner:self options:nil];
    if (nibContents.count > 0) {
        GradeCell *cell = [nibContents objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

+ (NSString *)reuseIdentifier
{
    return @"GradeCell";
}

@end
