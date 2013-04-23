//
//  ChoicesViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/24/13.
//  Copyright (c) 2013 Janne Käki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoicesViewController : UITableViewController

@property (strong, nonatomic) NSArray *choices;

@property (assign, nonatomic) BOOL isMultipleChoice;
@property (strong, nonatomic) NSMutableArray *selectedValues;

- (id)initWithChoices:(NSArray *)choices;

- (void)presentAsPopoverFromButton:(UIButton *)button onChoice:(void (^)(id choice))onChoice;

- (CGFloat)popoverWidth;

@end
