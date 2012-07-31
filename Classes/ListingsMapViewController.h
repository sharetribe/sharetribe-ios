//
//  ListingsMapViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ListingCollectionView.h"
#import "ListingCollectionViewDelegate.h"

@class ListingCell;

@interface ListingsMapViewController : UIViewController <ListingCollectionView, MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) ListingCell *cell;

@property (unsafe_unretained) id<ListingCollectionViewDelegate> listingCollectionViewDelegate;

@end
