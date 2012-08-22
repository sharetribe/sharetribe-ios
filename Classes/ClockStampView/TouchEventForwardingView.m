//
//  TouchEventForwardingView.m
//
//  Created by Janne Käki on 11/2/11.
//  Copyright (c) 2011 Futurice Ltd. All rights reserved.
//

#import "TouchEventForwardingView.h"

@implementation TouchEventForwardingView

@synthesize touchDelegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([(id) touchDelegate respondsToSelector:@selector(touchesBegan:withEvent:inView:)]) {
        [touchDelegate touchesBegan:touches withEvent:(UIEvent *)event inView:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([(id) touchDelegate respondsToSelector:@selector(touchesMoved:withEvent:inView:)]) {
        [touchDelegate touchesMoved:touches withEvent:(UIEvent *)event inView:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([(id) touchDelegate respondsToSelector:@selector(touchesEnded:withEvent:inView:)]) {
        [touchDelegate touchesEnded:touches withEvent:(UIEvent *)event inView:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([(id) touchDelegate respondsToSelector:@selector(touchesCancelled:withEvent:inView:)]) {
        [touchDelegate touchesCancelled:touches withEvent:(UIEvent *)event inView:self];
    }
}

- (void)dealloc
{
    touchDelegate = nil;
}

@end
