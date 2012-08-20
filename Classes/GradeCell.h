//
//  GradeCell.h
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import <UIKit/UIKit.h>

@class Grade;

@interface GradeCell : UITableViewCell

@property (strong) IBOutlet UIImageView *iconView;
@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *amountLabel;

@property (strong) Grade *grade;

+ (GradeCell *)newInstance;
+ (NSString *)reuseIdentifier;

@end
