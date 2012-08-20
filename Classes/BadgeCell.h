//
//  BadgeCell.h
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import <UIKit/UIKit.h>

@class Badge;

@interface BadgeCell : UITableViewCell

@property (strong) IBOutlet UIImageView *iconView;
@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *descriptionLabel;
@property (strong) IBOutlet UILabel *dateLabel;

@property (strong) Badge *badge;

- (CGFloat)heightWithBadge:(Badge *)badge;

+ (BadgeCell *)newInstance;
+ (NSString *)reuseIdentifier;

@end
