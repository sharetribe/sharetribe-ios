//
//  UIImageView+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 7/28/12.
//
//

#import "UIImageView+Sharetribe.h"

#import "UIImageView+AFNetworking.h"

@class User;

@implementation UIImageView (Sharetribe)

- (void)setImageWithUser:(User *)user
{
    [self setImageWithURL:user.pictureURL placeholderImage:[UIImage imageNamed:@"default-avatar"]];
}

- (void)setThumbnailImageWithUser:(User *)user
{
    [self setImageWithURL:user.thumbnailURL placeholderImage:[UIImage imageNamed:@"default-avatar"]];
}

@end
