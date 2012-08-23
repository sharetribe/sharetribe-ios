//
//  FeedbackListCell.h
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import <UIKit/UIKit.h>

@class Feedback;

@interface FeedbackListCell : UITableViewCell

@property (strong, nonatomic) Feedback *feedback;

@property (strong, nonatomic) IBOutlet UIImageView *gradeIconView;
@property (strong, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

+ (FeedbackListCell *)newInstance;
+ (NSString *)reuseIdentifier;
+ (CGFloat)heightWithFeedback:(Feedback *)feedback;

@end
