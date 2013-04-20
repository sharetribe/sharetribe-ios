//
//  UILabel+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import "UILabel+Sharetribe.h"

@implementation UILabel (Sharetribe)

- (CGFloat)sizeToHeight
{
    self.height = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.width, 10000) lineBreakMode:NSLineBreakByWordWrapping].height;
    return self.height;
}

@end
