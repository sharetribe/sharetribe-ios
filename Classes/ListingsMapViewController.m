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
#import "ListingCluster.h"
#import "ListingsListViewController.h"
#import "ListingsTopViewController.h"
#import "ListingAnnotationView.h"
#import "Location.h"
#import "SharetribeAPIClient.h"
#import "UIScrollView+Sharetribe.h"
#import <QuartzCore/QuartzCore.h>

@interface ListingsMapViewController () {
    BOOL shouldRefocusRegion;
    MKCoordinateRegion targetRegion;
    MKCoordinateRegion defaultRegion;
    Listing *selectedListing;
    ListingCluster *selectedCluster;
    MKAnnotationView *selectedAnnotationView;
    NSMutableDictionary *listingsByRoughCoordinate;
}

NSComparisonResult compareByLatitude(id annotation1, id annotation2, void *context);
NSComparisonResult compareByLongitude(id annotation1, id annotation2, void *context);

@end

@implementation ListingsMapViewController

@synthesize map;
@synthesize cell;

@synthesize listingCollectionViewDelegate;

- (void)addListings:(NSArray *)newListings
{
    if (newListings.count == 0) {
        return;
    }
    
    if (listingsByRoughCoordinate == nil) {
        listingsByRoughCoordinate = [NSMutableDictionary dictionaryWithCapacity:100];
    }
    
    BOOL shouldFocusToDefaultRegion = (map.annotations.count < 2);
    
    NSMutableArray *annotationsToAdd = [NSMutableArray arrayWithCapacity:100];
    
    for (Listing *newListing in newListings) {
        if (newListing.coordinate.latitude != 0 || newListing.coordinate.longitude != 0) {
            if ([map.annotations containsObject:newListing]) {
                [map removeAnnotation:newListing];  // this should in truth remove the older duplicate
            }
            
            NSString *roughCoordinate = [NSString stringWithFormat:@"%.3f %.2f", newListing.coordinate.latitude, newListing.coordinate.longitude];
            id listingAtRoughCoordinate = [listingsByRoughCoordinate objectForKey:roughCoordinate];
            // NSLog(@"%@: %@", roughCoordinate, listingAtRoughCoordinate);
            if (listingAtRoughCoordinate == nil || [listingAtRoughCoordinate isEqual:newListing]) {
                
                [annotationsToAdd addObject:newListing];
                [listingsByRoughCoordinate setObject:newListing forKey:roughCoordinate];
                
            } else if ([listingAtRoughCoordinate isKindOfClass:Listing.class]) {
                
                ListingCluster *cluster = [[ListingCluster alloc] init];
                [cluster addListing:listingAtRoughCoordinate];
                [cluster addListing:newListing];
                [listingsByRoughCoordinate setObject:cluster forKey:roughCoordinate];
                [annotationsToAdd addObject:cluster];
                [annotationsToAdd removeObject:listingAtRoughCoordinate];
                
            } else if ([listingAtRoughCoordinate isKindOfClass:ListingCluster.class]) {
                
                ListingCluster *cluster = (ListingCluster *) listingAtRoughCoordinate;
                if (![cluster.listings containsObject:newListing]) {
                    [cluster addListing:newListing];
                }
            }
        }
    }
    
    [map addAnnotations:annotationsToAdd];
    
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
        } else if ([annotation isKindOfClass:ListingCluster.class]) {
            [mappedListings addObjectsFromArray:[(ListingCluster *) annotation listings]];
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
        if (self.isViewLoaded
                && self.view.window
                && defaultRegion.span.latitudeDelta > 0
                && defaultRegion.span.longitudeDelta > 0) {
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
    [listingsByRoughCoordinate removeAllObjects];
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
    map.frame = CGRectMake(0, 0, self.view.width, self.view.height-2*44-5);
    map.mapType = MKMapTypeHybrid;
    map.showsUserLocation = YES;
    map.delegate = self;
    map.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(60.170, 24.939), 4000, 4000);
    [self.view addSubview:map];
    
    self.cell = [ListingCell instance];
    cell.frame = CGRectMake(0, 0, self.view.width, kListingCellHeight-5);
    cell.alpha = 0;
    
    CAGradientLayer *cellShadow = [[CAGradientLayer alloc] init];
    cellShadow.frame = CGRectMake(0, cell.height, self.view.width, 5);
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
    
    if (shouldRefocusRegion && (targetRegion.span.latitudeDelta > 0 && targetRegion.span.longitudeDelta > 0)) {
        
        shouldRefocusRegion = NO;
        [map setRegion:targetRegion animated:NO];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIconNamed:@"locate" pointSize:20 color:[UIColor whiteColor] insets:UIEdgeInsetsMake(5, 3, 0, 3)] style:UIBarButtonItemStyleBordered target:self action:@selector(focusOnUserLocation)];
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
        [map setCenterCoordinate:map.userLocation.coordinate animated:YES];
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

- (void)showOrHideCell
{
    [UIView beginAnimations:nil context:NULL];
    cell.alpha = (selectedListing != nil) ? 1 : 0;
    [UIView commitAnimations];
}

- (void)listingPinTappedInCluster:(UITapGestureRecognizer *)sender
{
    [selectedAnnotationView setSelected:NO];
    selectedCluster.selectedListingIndex = sender.view.tag;
    
    [self mapView:map didSelectAnnotationView:(MKAnnotationView *) sender.view];
}

- (void)showSelectedClusterInDetail
{
    [listingCollectionViewDelegate viewController:self didSelectListings:selectedCluster.listings];
}

- (void)centerMapWithAnimationAt:(CLLocation *)location
{
    [map setCenterCoordinate:location.coordinate animated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidChangeRegion object:mapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    return [self mapView:mapView viewForAnnotation:annotation reuse:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation reuse:(BOOL)reuse
{
    if ([annotation isKindOfClass:Listing.class] || [annotation isKindOfClass:ListingCluster.class]) {
        
        MKAnnotationView *view = (reuse) ? [mapView dequeueReusableAnnotationViewWithIdentifier:@"ListingPin"] : nil;
        if (view == nil) {
            view = [[ListingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ListingPin"];
        }
        return view;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:MKUserLocation.class]) {
            // view.canShowCallout = NO;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:Listing.class]) {
        selectedAnnotationView = view;
    }
    
    id<MKAnnotation> annotation = view.annotation;
        
    if ([annotation isKindOfClass:Listing.class]) {
        
        if (cell.superview != self.view) {
            [self.view addSubview:cell];
        }
        [cell setListing:annotation];
        
        [view setSelected:YES];
        
        selectedListing = (Listing *) annotation;
        
        [self performSelector:@selector(showOrHideCell) withObject:nil afterDelay:0.1];
        
    } else if ([annotation isKindOfClass:ListingCluster.class]) {
        
        ListingCluster *cluster = (ListingCluster *) annotation;
        selectedCluster = cluster;
        
        UIScrollView *clusterView = [[UIScrollView alloc] init];
        clusterView.clipsToBounds = NO;
        
        int listingWidthInCluster = 36;
        int clusterWidth = listingWidthInCluster * cluster.listings.count + 25;
        
        if (clusterWidth < 270) {
            clusterView.frame = CGRectMake(0, 0, clusterWidth, 25);
            clusterView.contentSize = clusterView.frame.size;
        } else {
            clusterView.frame = CGRectMake(0, 0, 270, 25);
            clusterView.contentSize = CGSizeMake(clusterWidth, 25);
        }
        
        ListingAnnotationView *viewToPreselect = nil;
        
        for (int i = 0; i < cluster.listings.count; i++) {
            
            Listing *listing = [cluster.listings objectAtIndex:i];
            ListingAnnotationView *listingPin = (ListingAnnotationView *) [self mapView:mapView viewForAnnotation:listing reuse:NO];
            listingPin.frame = CGRectMake(listingWidthInCluster * i + 5, -2, listingPin.width, listingPin.height);
            listingPin.tag = i;
            listingPin.fillColor = kSharetribeBrownColor;
            [clusterView addSubview:listingPin];
            
            for (UIGestureRecognizer *recognizer in listingPin.gestureRecognizers) {
                NSLog(@"removing a recognizer from %@", listing.title);
                [listingPin removeGestureRecognizer:recognizer];
            }
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listingPinTappedInCluster:)];
            [listingPin addGestureRecognizer:tap];
            
            if (cluster.selectedListingIndex == i) {
                viewToPreselect = listingPin;
            }
        }
        view.leftCalloutAccessoryView = clusterView;
        
        UIButton *showDetailsButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [showDetailsButton addTarget:self action:@selector(showSelectedClusterInDetail) forControlEvents:UIControlEventTouchUpInside];
        UIView *rightCalloutAccessoryView = [[UIView alloc] initWithFrame:showDetailsButton.frame];
        rightCalloutAccessoryView.width += 6;
        [rightCalloutAccessoryView addSubview:showDetailsButton];
        view.rightCalloutAccessoryView = rightCalloutAccessoryView;
        
        if (viewToPreselect != nil) {
            [self mapView:map didSelectAnnotationView:viewToPreselect];
        }
        
        if (clusterView.contentSize.width > clusterView.width) {
            clusterView.contentOffset = CGPointMake(clusterView.contentSize.width - clusterView.width, 0);
            [clusterView performSelector:@selector(rewind) withObject:nil afterDelay:0.7];
        }
    }
        
    CLLocationDegrees latitudeThreshold = map.centerCoordinate.latitude;
    if ([annotation isKindOfClass:[ListingCluster class]]) {
        latitudeThreshold -= 0.1 * map.region.span.latitudeDelta;
    }
    
    if (annotation.coordinate.latitude > latitudeThreshold && [map.annotations containsObject:annotation]) {
        
        CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(annotation.coordinate.latitude, map.centerCoordinate.longitude);
        newCenter.latitude += 0.05 * map.region.span.latitudeDelta;
        if ([annotation isKindOfClass:[ListingCluster class]]) {
            newCenter.latitude += 0.05 * map.region.span.latitudeDelta;
        }
        CLLocation *newCenterLocation = [[CLLocation alloc] initWithLatitude:newCenter.latitude longitude:newCenter.longitude];
        [self performSelector:@selector(centerMapWithAnimationAt:) withObject:newCenterLocation afterDelay:0.2];
    }
    
    [view setSelected:YES];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:Listing.class]) {
        
        if (selectedListing == view.annotation) {
            selectedListing = nil;
        }
        [self performSelector:@selector(showOrHideCell) withObject:nil afterDelay:0.1];

    } else if ([view.annotation isKindOfClass:ListingCluster.class]) {
        
        [self mapView:map didDeselectAnnotationView:selectedAnnotationView];
    }
    
    if (selectedAnnotationView == view) {
        selectedAnnotationView = nil;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    Location *currentLocation = [[Location alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude address:@""];
    [Location setCurrentLocation:currentLocation];
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
