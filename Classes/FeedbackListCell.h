//
//  FeedbackListCell.h
//  Sharetribe
//
//  Created by Janne Käki on 8/22/12.
//
//

#import <UIKit/UIKit.h>

@interface FeedbackListCell : UITableViewCell

+ (FeedbackListCell *)newInstance;
+ (NSString *)reuseIdentifier;

@end
