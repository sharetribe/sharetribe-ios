//
//  Location.m
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location

@synthesize location;
@synthesize address;

- (id)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude address:(NSString *)theAddress
{
    self = [super init];
    if (self != nil) {
        self.location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.address = address;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return location.coordinate;
}

@end
