//
//  ListingsMapViewController.h
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ListingCell.h"

@protocol ListingSelectionDelegate;

@interface ListingsMapViewController : UIViewController <MKMapViewDelegate> {

    NSMutableArray *listings;
    
    BOOL shouldRefocusRegion;
    MKCoordinateRegion targetRegion;
}

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) ListingCell *cell;

@property (copy) NSArray *listings;

@property (unsafe_unretained) id<ListingSelectionDelegate> listingSelectionDelegate;

@end
