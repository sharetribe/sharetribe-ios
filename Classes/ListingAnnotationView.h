//
//  ListingAnnotationView.h
//  Sharetribe
//
//  Created by Janne Käki on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ListingAnnotationView : MKAnnotationView

@property (strong) UIImageView *iconView;
@property (strong) UILabel *countLabel;

@property (strong) UIColor *strokeColor;
@property (strong) UIColor *fillColor;

@end
