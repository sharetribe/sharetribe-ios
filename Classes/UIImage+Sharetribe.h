//
//  UIImage+Sharetribe.h
//  Sharetribe
//
//  Created by Janne Käki on 4/14/13.
//  Copyright (c) 2013 Janne Käki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Sharetribe)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithIconNamed:(NSString *)name pointSize:(CGFloat)pointSize color:(UIColor *)color;
+ (UIImage *)imageWithIconNamed:(NSString *)name pointSize:(CGFloat)pointSize color:(UIColor *)color insets:(UIEdgeInsets)insets;

@end
