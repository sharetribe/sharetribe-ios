//
//  ListingsMapViewController.m
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingsMapViewController.h"

#import "Listing.h"
#import "ListingsTopViewController.h"
#import "ListingAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListingsMapViewController

@synthesize map;
@synthesize cell;

@dynamic listings;

@synthesize listingSelectionDelegate;

- (NSArray *)listings
{
    if (listings == nil) {
        listings = [NSMutableArray array];
    }
    return listings;
}

- (void)setListings:(NSArray *)newListings
{
    [map removeAnnotations:listings];
    listings = [NSMutableArray arrayWithArray:newListings];
    [map addAnnotations:listings];
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
    map.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(60.185, 24.828), 1000, 1000);
    [self.view addSubview:map];
    
    self.cell = [ListingCell instance];
    cell.frame = CGRectMake(0, 0, 320, kListingCellHeight-6);
    cell.alpha = 0;
    
    CAGradientLayer *cellShadow = [[CAGradientLayer alloc] init];
    cellShadow.frame = CGRectMake(0, cell.height, 320, 5);
    cellShadow.colors = [NSArray arrayWithObjects:(id)([UIColor colorWithWhite:0 alpha:0.3].CGColor), (id)[UIColor clearColor].CGColor, nil];
    [cell.layer insertSublayer:cellShadow atIndex:0];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellPressed)];
    [cell addGestureRecognizer:tapRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(regionChangedByMapView:) name:kNotificationForRegionChange object:nil];
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
    [listingSelectionDelegate viewController:self didSelectListing:cell.listing];
}

- (void)regionChangedByMapView:(NSNotification *)notification
{
    MKMapView *mapView = notification.object;
    if (map != mapView) {
        targetRegion = mapView.region;
        shouldRefocusRegion = YES;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForRegionChange object:mapView];
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

@end
