//
//  ListingsMapViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsMapViewController.h"

#import "Listing.h"
#import "ListingCell.h"
#import "ListingsTopViewController.h"
#import "ListingAnnotationView.h"
#import "Location.h"
#import "SharetribeAPIClient.h"
#import <QuartzCore/QuartzCore.h>

@interface ListingsMapViewController () {
    BOOL shouldRefocusRegion;
    MKCoordinateRegion targetRegion;
    MKCoordinateRegion defaultRegion;
}

@end

@implementation ListingsMapViewController

@synthesize map;
@synthesize cell;

@synthesize listingCollectionViewDelegate;

- (void)addListings:(NSArray *)newListings
{
    BOOL shouldFocusToDefaultRegion = (map.annotations.count < 2);
    
    for (Listing *newListing in newListings) {
        if (newListing.coordinate.latitude != 0 || newListing.coordinate.longitude != 0) {
            if ([map.annotations containsObject:newListing]) {
                [map removeAnnotation:newListing];  // this should in truth remove the older duplicate
            }
            [map addAnnotation:newListing];
        }
    }
    
    CLLocationCoordinate2D min, max;
    min.longitude = 0;
    min.latitude = 0;
    max.latitude = 0;
    max.longitude = 0;
    double latitudeSum = 0;
    double longitudeSum = 0;
    int numberOfItems = 0;
    
    NSMutableArray *mappedListings = [NSMutableArray arrayWithCapacity:map.annotations.count];
    for (id<MKAnnotation> annotation in map.annotations) {
        if ([annotation isKindOfClass:Listing.class]) {
            [mappedListings addObject:annotation];
        }
    }
    
    if (mappedListings.count > 10) {
        [mappedListings sortUsingFunction:compareByLatitude context:NULL];
        [mappedListings removeObjectAtIndex:0];
        [mappedListings removeLastObject];
        [mappedListings sortUsingFunction:compareByLongitude context:NULL];
        [mappedListings removeObjectAtIndex:0];
        [mappedListings removeLastObject];
    }
    
    for (Listing *listing in mappedListings) {
        CLLocationCoordinate2D coordinate = listing.coordinate;
        latitudeSum += coordinate.latitude;
        longitudeSum += coordinate.longitude;
        numberOfItems += 1;
        if (coordinate.latitude < min.latitude || min.latitude == 0) {
            min.latitude = coordinate.latitude;
        }
        if (coordinate.latitude > max.latitude || max.latitude == 0) {
            max.latitude = coordinate.latitude;
        }
        if (coordinate.longitude < min.longitude || min.longitude == 0) {
            min.longitude = coordinate.longitude;
        }
        if (coordinate.longitude > max.longitude || max.longitude == 0) {
            max.longitude = coordinate.longitude;
        }
    }
    CLLocationCoordinate2D averageCoordinate;
    averageCoordinate.latitude = latitudeSum/numberOfItems;
    averageCoordinate.longitude = longitudeSum/numberOfItems;
    MKCoordinateSpan span;
    span.latitudeDelta = (max.latitude-min.latitude)*0.8;
    span.longitudeDelta = (max.longitude-min.longitude)*0.8;
    defaultRegion = MKCoordinateRegionMake(averageCoordinate, span);
    if (shouldFocusToDefaultRegion) {
        if (self.isViewLoaded && self.view.window) {
            [map setRegion:defaultRegion animated:YES];
        } else {
            targetRegion = defaultRegion;
            shouldRefocusRegion = YES;
        }
    }
}

- (void)clearAllListings
{
    [map removeAnnotations:map.annotations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.map = [[MKMapView alloc] init];
    map.frame = CGRectMake(0, 0, 320, 460-2*44-5);
    map.showsUserLocation = YES;
    map.delegate = self;
    map.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(60.170, 24.939), 4000, 4000);
    [self.view addSubview:map];
    
    self.cell = [ListingCell instance];
    cell.frame = CGRectMake(0, 0, 320, kListingCellHeight-5);
    cell.alpha = 0;
    
    CAGradientLayer *cellShadow = [[CAGradientLayer alloc] init];
    cellShadow.frame = CGRectMake(0, cell.height, 320, 5);
    cellShadow.colors = [NSArray arrayWithObjects:(id)([UIColor colorWithWhite:0 alpha:0.3].CGColor), (id)[UIColor clearColor].CGColor, nil];
    [cell.layer insertSublayer:cellShadow atIndex:0];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed)];
    [cell addGestureRecognizer:tapRecognizer];
    
    [self observeNotification:kNotificationForDidChangeRegion withSelector:@selector(regionChangedByMapView:)];
    [self observeNotification:kNotificationForDidRefreshListing withSelector:@selector(refreshedListing:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (shouldRefocusRegion) {
        
        shouldRefocusRegion = NO;
        
        CGPoint targetCenterPoint = [map convertCoordinate:targetRegion.center toPointToView:map];
        targetCenterPoint.y -= 1;
        targetRegion.center = [map convertPoint:targetCenterPoint toCoordinateFromView:map];
    
        [map setRegion:targetRegion animated:NO];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-location-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(focusOnUserLocation)];
    self.navigationItem.rightBarButtonItem.enabled = (map.userLocation.coordinate.latitude != 0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [cell setSelected:NO animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.map = nil;
    self.cell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cellPressed
{
    [listingCollectionViewDelegate viewController:self didSelectListing:cell.listing];
}

- (IBAction)focusOnUserLocation
{
    if (map.userLocation.coordinate.latitude != 0) {
        MKCoordinateRegion userRegion = MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 2000, 2000);
        [map setRegion:userRegion animated:YES];
    }
}

- (void)regionChangedByMapView:(NSNotification *)notification
{
    MKMapView *mapView = notification.object;
    if (map != mapView) {
        targetRegion = mapView.region;
        shouldRefocusRegion = YES;
    }
}

- (void)refreshedListing:(NSNotification *)notification
{
    if ([map.annotations containsObject:notification.object]) {
        [map removeAnnotation:notification.object];  // actually removes the older duplicate...
        [map addAnnotation:notification.object];     // ...and this replaces it with current data! en garde!
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidChangeRegion object:mapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:Listing.class]) {
        
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:@"ListingPin"];
        if (view == nil) {
            view = [[ListingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ListingPin"];
            view.canShowCallout = NO;
        }
        return view;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:MKUserLocation.class]) {
            view.canShowCallout = NO;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:Listing.class]) {
        
        if (cell.superview != self.view) {
            [self.view addSubview:cell];
        }
        [cell setListing:view.annotation];
    
        [UIView beginAnimations:nil context:NULL];
        cell.alpha = 1;
        [UIView commitAnimations];
        
        CGPoint pinPoint = [mapView convertCoordinate:view.annotation.coordinate toPointToView:mapView];
        if (pinPoint.y < cell.height+60) {
            CLLocationDegrees visibleLatitude = [mapView convertPoint:CGPointMake(pinPoint.x, cell.height+60) toCoordinateFromView:mapView].latitude;
            CLLocationDegrees latitudeDiff = view.annotation.coordinate.latitude - visibleLatitude;
            CLLocationCoordinate2D newCenterCoordinate = mapView.centerCoordinate;
            newCenterCoordinate.latitude += latitudeDiff;
            [mapView setCenterCoordinate:newCenterCoordinate animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if (mapView.selectedAnnotations.count == 0 && [view.annotation isKindOfClass:Listing.class]) {
    
        [UIView beginAnimations:nil context:NULL];
        cell.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    Location *currentLocation = [[Location alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude address:@""];
    [Location setCurrentLocation:currentLocation];
    
    self.navigationItem.rightBarButtonItem.enabled = (map.userLocation.coordinate.latitude != 0);
}

NSComparisonResult compareByLatitude(id annotation1, id annotation2, void *context)
{
    return [annotation1 coordinate].latitude - [annotation2 coordinate].latitude;
}

NSComparisonResult compareByLongitude(id annotation1, id annotation2, void *context)
{
    return [annotation1 coordinate].longitude - [annotation2 coordinate].longitude;
}

@end
