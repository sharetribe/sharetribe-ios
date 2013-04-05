//
//  ListingCluster.h
//  Sharetribe
//
//  Created by Janne Käki on 9/21/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Listing;

@interface ListingCluster : NSObject <MKAnnotation>

@property (readonly) NSMutableArray *listings;
@property (readonly) CLLocationCoordinate2D coordinate;
@property (assign) NSInteger selectedListingIndex;

- (void)addListing:(Listing *)listing;
- (void)removeListing:(Listing *)listing;

@end
