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
    map.showsUserLocation = YES;
    [self.view addSubview:map];
    
    [map addAnnotation:self];
    
    UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedOnMap:)];
    pressRecognizer.minimumPressDuration = 0.5;
    [map addGestureRecognizer:pressRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [map setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000) animated:NO];
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

- (IBAction)pressedOnMap:(UILongPressGestureRecognizer *)sender
{
    CGPoint mapPoint = [sender locationInView:map];
    self.coordinate = [map convertPoint:mapPoint toCoordinateFromView:map];
}

#pragma mark - MKMapViewDelegate



@end
