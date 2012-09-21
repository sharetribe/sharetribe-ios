//
//  ListingCluster.m
//  Sharetribe
//
//  Created by Janne Käki on 9/21/12.
//
//

#import "ListingCluster.h"

#import "Listing.h"

@interface ListingCluster () {
    NSMutableArray *listings;
    CLLocationCoordinate2D averageCoordinate;
    BOOL shouldRecalculateCoordinate;
}

@end

@implementation ListingCluster

@synthesize listings;

- (id)init
{
    if ((self = [super init])) {
        listings = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    if (shouldRecalculateCoordinate) {
        double latitudeSum = 0;
        double longitudeSum = 0;
        for (Listing *listing in listings) {
            latitudeSum += listing.coordinate.latitude;
            longitudeSum += listing.coordinate.longitude;
        }
        averageCoordinate.latitude = latitudeSum / listings.count;
        averageCoordinate.longitude = longitudeSum / listings.count;
        shouldRecalculateCoordinate = NO;
    }
    
    return averageCoordinate;
}

- (NSString *)title
{
    return @" ";
}

- (void)addListing:(Listing *)listing
{
    [listings addObject:listing];
    shouldRecalculateCoordinate = YES;
}

- (void)removeListing:(Listing *)listing
{
    [listings removeObject:listing];
    shouldRecalculateCoordinate = YES;
}

@end
