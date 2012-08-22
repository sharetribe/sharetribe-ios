//
//  TouchEventForwardingView.h
//
//  Created by Janne Käki on 11/2/11.
//  Copyright (c) 2011 Futurice Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchEventForwardingView;

@protocol TouchEventForwardingViewDelegate
@optional
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view;
@end

@interface TouchEventForwardingView : UIView

@property (unsafe_unretained) id<TouchEventForwardingViewDelegate> touchDelegate;

@end
