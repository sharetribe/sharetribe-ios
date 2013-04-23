//
//  LocationPickerViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationPickerViewController.h"

#import <CoreLocation/CoreLocation.h>

@interface LocationPickerViewController ()

@property (strong) CLGeocoder *geocoder;

@end

@implementation LocationPickerViewController

@synthesize map;
@synthesize mapType;
@synthesize coordinate;
@synthesize address = _address;

@synthesize delegate;

@synthesize geocoder;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.map = [[MKMapView alloc] init];
    map.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    map.delegate = self;
    map.mapType = (mapType != 0) ? mapType : MKMapTypeStandard;
    map.showsUserLocation = YES;
    map.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:map];
    
    [map addAnnotation:self];
    
    if (delegate != nil) {
        self.title = NSLocalizedString(@"listing.location.picker.help", @"");
    
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedOnMap:)];
        pressRecognizer.minimumPressDuration = 0.5;
        [map addGestureRecognizer:pressRecognizer];
    } else {
        self.title = self.address;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    
    UIButton *locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locateButton.frame = CGRectMake(0, 0, 44, 44);
    [locateButton setImage:[UIImage imageWithIconNamed:@"locate" pointSize:24 color:[UIColor whiteColor] insets:UIEdgeInsetsMake(5, 3, 0, 3)] forState:UIControlStateNormal];
    [locateButton addTarget:self action:@selector(locate) forControlEvents:UIControlEventTouchUpInside];
    [locateButton setShadowWithOpacity:0.5 radius:2 offset:CGSizeMake(0, 1) usingDefaultPath:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:locateButton];
    
    self.navigationItem.titleView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [map setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000) animated:NO];
    [map setSelectedAnnotations:[NSArray arrayWithObject:self]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [delegate locationPicker:self pickedCoordinate:self.coordinate withAddress:self.address];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locate
{
    if (map.userLocation != nil) {
        [map setCenterCoordinate:map.userLocation.coordinate animated:YES];
    }
}

- (IBAction)pressedOnMap:(UILongPressGestureRecognizer *)sender
{
    CGPoint mapPoint = [sender locationInView:map];
    self.coordinate = [map convertPoint:mapPoint toCoordinateFromView:map];
    
    [map deselectAnnotation:self animated:YES];
    
    if (NSClassFromString(@"CLGeocoder") != nil && [NSClassFromString(@"CLGeocoder") instancesRespondToSelector:@selector(reverseGeocodeLocation:completionHandler:)]) {
        [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(startReverseGeocoding) object:nil];
        [self performSelector:@selector(startReverseGeocoding) withObject:nil afterDelay:0.4];
    }
}

- (void)startReverseGeocoding
{
    [geocoder cancelGeocode];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    self.geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"placemarks: %@, error: %@", placemarks, error);
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSMutableString *address = [NSMutableString string];
            if (placemark.thoroughfare.length > 0) {
                [address appendString:placemark.thoroughfare];
                if (placemark.subThoroughfare.length > 0) {
                    [address appendFormat:@" %@", placemark.subThoroughfare];
                }
            }
            if (placemark.locality.length > 0) {
                if (address.length > 0) {
                    [address appendString:@", "];
                }
                if (placemark.postalCode.length > 0) {
                    [address appendFormat:@"%@ ", placemark.postalCode];
                }
                [address appendString:placemark.locality];
            }
            self.address = address;
            NSLog(@"did reverse geocode address: %@", address);
        }
    }];
}

#pragma mark - MKMapViewDelegate

@end
