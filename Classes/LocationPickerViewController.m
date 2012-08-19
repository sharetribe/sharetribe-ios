//
//  LocationPickerViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationPickerViewController.h"

@implementation LocationPickerViewController

@synthesize map;
@synthesize mapType;
@synthesize coordinate;

@synthesize delegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.map = [[MKMapView alloc] init];
    map.frame = CGRectMake(0, 0, 320, 416);
    map.delegate = self;
    map.mapType = (mapType != 0) ? mapType : MKMapTypeStandard;
    map.showsUserLocation = YES;
    [self.view addSubview:map];
    
    [map addAnnotation:self];
    
    if (delegate != nil) {
        self.title = NSLocalizedString(@"listing.location.picker.help", @"");
    
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedOnMap:)];
        pressRecognizer.minimumPressDuration = 0.5;
        [map addGestureRecognizer:pressRecognizer];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:self action:@selector(pop)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-location-white"] style:UIBarButtonItemStyleBordered target:self action:@selector(locate)];
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
    [delegate locationPicker:self pickedCoordinate:coordinate];
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
}

#pragma mark - MKMapViewDelegate



@end
