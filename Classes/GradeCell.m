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
    
    iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"kaapo-grade-%d", grade.grade]];
    NSString *titleKey = [NSString stringWithFormat:@"grade.%@", grade.name];
    titleLabel.text = NSLocalizedString(titleKey, @"");
    amountLabel.text = [NSString stringWithFormat:@"%d", grade.amount];
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
