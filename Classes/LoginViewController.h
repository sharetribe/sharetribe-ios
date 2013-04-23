//
//  LoginViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *logoButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginSpinner;

@property (weak, nonatomic) IBOutlet UIView *ouishareView;

- (IBAction)performLogin;
- (IBAction)openSharetribeWebsite;
- (IBAction)openOuishareSignUp;

@end
