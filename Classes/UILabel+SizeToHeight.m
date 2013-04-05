//
//  UILabel+SizeToHeight.m
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import "UILabel+SizeToHeight.h"

@implementation UILabel (SizeToHeight)

- (CGFloat)sizeToHeight
{
    self.height = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    return self.height;
}

@end
