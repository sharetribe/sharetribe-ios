//
//  ButtonTabBarController.h
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTabBarController : UITabBarController

@property (strong, nonatomic) UIViewController *middleViewController;

@property (strong, nonatomic) UIButton *middleButton;
@property (strong, nonatomic) UILabel *middleButtonLabel;

@property (strong, nonatomic) NSString *middleButtonTitle;
@property (strong, nonatomic) UIImage *middleButtonNormalImage;
@property (strong, nonatomic) UIImage *middleButtonHighlightedImage;

- (id)initWithMiddleViewController:(UIViewController *)middleViewController otherViewControllers:(NSArray *)otherViewControllers;

@end
