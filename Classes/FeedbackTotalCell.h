//
//  FeedbackTotalCell.h
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import <UIKit/UIKit.h>

@interface FeedbackTotalCell : UITableViewCell

@property (strong) IBOutlet UILabel *percentageLabel;
@property (strong) IBOutlet UILabel *detailLabel;
@property (strong) IBOutlet UIButton *whatIsThisButton;

+ (FeedbackTotalCell *)newInstance;
+ (NSString *)reuseIdentifier;

- (IBAction)whatIsThisButtonPressed;

@end
