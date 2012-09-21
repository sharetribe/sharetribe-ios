//
//  UIScrollView+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 9/21/12.
//
//

#import "UIScrollView+Sharetribe.h"

@implementation UIScrollView (Sharetribe)

- (void)rewind
{
    [self setContentOffset:CGPointZero animated:YES];
}

@end
