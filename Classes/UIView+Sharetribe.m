//
//  UIView+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+Sharetribe.h"

#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Sharetribe)

@dynamic x, y, width, height, top, bottom, left, right;

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (CGFloat)top
{
    return self.y;
}

- (CGFloat)bottom
{
    return self.y + self.height;
}

- (CGFloat)left
{
    return self.x;
}

- (CGFloat)right
{
    return self.x + self.width;
}

- (void)setShadowWithOpacity:(float)opacity radius:(CGFloat)radius
{
    [self setShadowWithColor:nil opacity:opacity radius:radius offset:CGSizeZero usingDefaultPath:YES];
}

- (void)setShadowWithOpacity:(float)opacity radius:(CGFloat)radius offset:(CGSize)offset usingDefaultPath:(BOOL)usingDefaultPath
{
    [self setShadowWithColor:nil opacity:opacity radius:radius offset:offset usingDefaultPath:usingDefaultPath];
}

- (void)setShadowWithColor:(UIColor *)color opacity:(float)opacity radius:(CGFloat)radius offset:(CGSize)offset usingDefaultPath:(BOOL)usingDefaultPath
{
    if (color) {
        self.layer.shadowColor = color.CGColor;
    }
    
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
    self.layer.shadowOffset = offset;
    
    if (usingDefaultPath) {
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    }
}

- (void)setIconWithName:(NSString *)name
{
    UILabel *label = nil;
    UIButton *button = nil;
    if ([self isKindOfClass:UIButton.class]) {
        button = (UIButton *) self;
        label = button.titleLabel;
    } else if ([self isKindOfClass:UILabel.class]) {
        label = (UILabel *) self;
    }
    UIFont *font = [UIFont fontWithName:@"SSPika" size:label.font.pointSize];
    label.font = font;
    
    NSMutableAttributedString *string = (name) ? [[NSMutableAttributedString alloc] initWithString:name] : nil;
    [string setAttributes:@{(NSString *) kCTLigatureAttributeName: @(2)}
                    range:NSMakeRange(0, string.length)];
    
    if (button) {
        [button setAttributedTitle:string forState:UIControlStateNormal];
    } else {
        label.attributedText = string;
    }    
}

@end
