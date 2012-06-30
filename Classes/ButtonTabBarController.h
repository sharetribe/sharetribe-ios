//
//  ButtonTabBarController.h
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTabBarController : UITabBarController

@property (strong, nonatomic) UIViewController *middleViewController;

@property (strong, nonatomic) UIButton *middleButton;
@property (strong, nonatomic) UILabel *middleButtonLabel;

- (id)initWithMiddleViewController:(UIViewController *)middleViewController otherViewControllers:(NSArray *)otherViewControllers;

- (void)setMiddleButtonTitle:(NSString *)title;
- (void)setMiddleButtonImage:(UIImage *)image forState:(UIControlState)state;

@end
