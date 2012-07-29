//
//  ButtonTabBarController.m
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ButtonTabBarController.h"

@implementation ButtonTabBarController

@synthesize middleViewController;

@synthesize middleButton;
@synthesize middleButtonLabel;

- (id)initWithMiddleViewController:(UIViewController *)theMiddleViewController otherViewControllers:(NSArray *)theOtherViewControllers
{
    self = (([super init]));
    if (self) {
        
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:theOtherViewControllers];
        
        UIViewController *placeholder = [[UIViewController alloc] init];
        NSInteger middleIndex = theOtherViewControllers.count/2;
        [viewControllers insertObject:placeholder atIndex:middleIndex];
        
        self.viewControllers = viewControllers;
        self.middleViewController = theMiddleViewController;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    middleButton.frame = CGRectMake((320-70)/2, 480-68, 70, 66);
    middleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 14, 0);
    [middleButton setBackgroundImage:[UIImage imageNamed:@"tab-bar-bezel"] forState:UIControlStateNormal];
    [middleButton setBackgroundImage:[UIImage imageNamed:@"tab-bar-bezel"] forState:UIControlStateHighlighted];
    [middleButton addTarget:self action:@selector(middleButtonActivated:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [middleButton addTarget:self action:@selector(middleButtonDeactivated:) forControlEvents:UIControlEventTouchCancel | UIControlEventTouchDragExit | UIControlEventTouchUpInside];
    [middleButton addTarget:self action:@selector(middleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:middleButton];
    
    self.middleButtonLabel = [[UILabel alloc] init];
    middleButtonLabel.font = [UIFont boldSystemFontOfSize:10];
    middleButtonLabel.textColor = [UIColor lightGrayColor];
    middleButtonLabel.backgroundColor = [UIColor clearColor];
    middleButtonLabel.frame = CGRectMake(10, 42, 46, 24);
    middleButtonLabel.textAlignment = UITextAlignmentCenter;
    middleButtonLabel.numberOfLines = 2;
    middleButtonLabel.lineBreakMode = UILineBreakModeWordWrap;
    [middleButton addSubview:middleButtonLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:middleButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setMiddleButtonTitle:(NSString *)title
{
    middleButtonLabel.text = title;
}

- (void)setMiddleButtonImage:(UIImage *)image forState:(UIControlState)state
{
    [middleButton setImage:image forState:state];
}

- (IBAction)middleButtonActivated:(UIButton *)sender
{
    middleButtonLabel.textColor = [UIColor whiteColor];
}

- (IBAction)middleButtonDeactivated:(UIButton *)sender
{
    middleButtonLabel.textColor = [UIColor lightGrayColor];
}

- (IBAction)middleButtonPressed:(UIButton *)sender
{
    [self presentViewController:middleViewController animated:YES completion:nil];
}

@end