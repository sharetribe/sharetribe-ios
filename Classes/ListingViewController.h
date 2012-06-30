//
//  ListingViewController.h
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Listing.h"
#import "MessagesView.h"

@interface ListingViewController : UIViewController <MessagesViewDelegate>

@property (strong) Listing *listing;

@property (strong) UIScrollView *scrollView;
@property (strong) UIImageView *imageView;
@property (strong) UILabel *titleLabel;
@property (strong) UILabel *textLabel;
@property (strong) MessagesView *commentsView;
@property (strong) UIButton *followButton;
@property (strong) UIButton *messageButton;

@end
