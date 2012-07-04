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

- (id)copy
{
    return [[Location alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude address:address.copy];
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    [JSON setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [JSON setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];    
    if (address != nil) {
        [JSON setObject:address forKey:@"address"];
    }
    
    return JSON;
}

+ (Location *)currentLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CLLocationDegrees latitude = [defaults doubleForKey:@"current latitude"];
    CLLocationDegrees longitude = [defaults doubleForKey:@"current longitude"];
    NSString *address = [defaults objectForKey:@"current address"];
    
    return [[Location alloc] initWithLatitude:latitude longitude:longitude address:address];
}

+ (void)setCurrentLocation:(Location *)newCurrentLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:newCurrentLocation.coordinate.latitude forKey:@"current latitude"];
    [defaults setDouble:newCurrentLocation.coordinate.longitude forKey:@"current longitude"];
    [defaults setObject:newCurrentLocation.address forKey:@"current address"];
    [defaults synchronize];
}

@end
