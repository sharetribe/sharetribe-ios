//
//  UIView+Sharetribe.h
//  SHaretribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Sharetribe)

@property (assign) CGFloat x;
@property (assign) CGFloat y;
@property (assign) CGFloat width;
@property (assign) CGFloat height;

@property (readonly) CGFloat top;
@property (readonly) CGFloat bottom;
@property (readonly) CGFloat left;
@property (readonly) CGFloat right;

- (void)setShadowWithOpacity:(float)opacity radius:(CGFloat)radius;
- (void)setShadowWithOpacity:(float)opacity radius:(CGFloat)radius offset:(CGSize)offset usingDefaultPath:(BOOL)usingDefaultPath;
- (void)setShadowWithColor:(UIColor *)color opacity:(float)opacity radius:(CGFloat)radius offset:(CGSize)offset usingDefaultPath:(BOOL)usingDefaultPath;

- (void)setIconWithName:(NSString *)name;

@end
