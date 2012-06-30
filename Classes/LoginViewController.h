//
//  LoginViewController.h
//  Kassi
//
//  Created by Janne Käki on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong) IBOutlet UITextField *usernameField;
@property (strong) IBOutlet UITextField *passwordField;
@property (strong) IBOutlet UIButton *loginButton;
@property (strong) IBOutlet UIActivityIndicatorView *loginSpinner;

- (IBAction)performLogin;

@end
