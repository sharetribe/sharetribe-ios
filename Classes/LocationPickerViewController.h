//
//  LocationPickerViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class LocationPickerViewController;

@protocol LocationPickerDelegate <NSObject>
- (void)locationPicker:(LocationPickerViewController *)picker pickedCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)locationPickedDidCancel:(LocationPickerViewController *)picker;
@end

@interface LocationPickerViewController : UIViewController <MKAnnotation, MKMapViewDelegate>

@property (strong, nonatomic) MKMapView *map;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@property (unsafe_unretained, nonatomic) id<LocationPickerDelegate> delegate;

@end
