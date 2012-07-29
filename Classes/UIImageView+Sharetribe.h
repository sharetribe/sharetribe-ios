//
//  UIImageView+Sharetribe.h
//  Sharetribe
//
//  Created by Janne Käki on 7/28/12.
//
//

#import <UIKit/UIKit.h>

#import "User.h"

@interface UIImageView (Sharetribe)

- (void)setImageWithUser:(User *)user;
- (void)setThumbnailImageWithUser:(User *)user;

@end
