//
//  ListingViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Listing.h"
#import "MessagesView.h"

@interface ListingViewController : UIViewController <MessagesViewDelegate>

@property (strong) Listing *listing;
@property (assign) NSInteger listingId;

@property (strong) IBOutlet UIScrollView *scrollView;
@property (strong) IBOutlet UIImageView *imageView;
@property (strong) IBOutlet UIView *backgroundView;
@property (strong) IBOutlet UIView *topShadowBar;

@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *textLabel;
@property (strong) IBOutlet UILabel *tagTitleLabel;
@property (strong) IBOutlet UILabel *tagListLabel;

@property (strong) MKMapView *mapView;

@property (strong) IBOutlet UIView *authorView;
@property (strong) IBOutlet UIImageView *authorImageView;
@property (strong) IBOutlet UILabel *authorIntroLabel;
@property (strong) IBOutlet UILabel *authorNameLabel;
@property (strong) IBOutlet UILabel *feedbackIntroLabel;
@property (strong) IBOutlet UILabel *feedbackPercentLabel;
@property (strong) IBOutlet UILabel *feedbackOutroLabel;

@property (strong) IBOutlet UIButton *respondButton;

@property (strong) MessagesView *commentsView;

- (IBAction)showAuthorProfile;

@end
