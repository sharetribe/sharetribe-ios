//
//  ProfileViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class User;

@interface ProfileViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate>

@property (strong) User *user;

@property (strong) IBOutlet UIScrollView *scrollView;
@property (strong) IBOutlet MKMapView *mapView;
@property (strong) IBOutlet UIImageView *avatarView;
@property (strong) IBOutlet UILabel *nameLabel;
@property (strong) IBOutlet UILabel *locationLabel;
@property (strong) IBOutlet UIButton *phoneButton;
@property (strong) IBOutlet UIImageView *locationIconView;
@property (strong) IBOutlet UIImageView *phoneIconView;

@end
