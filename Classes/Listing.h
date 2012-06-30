//
//  Listing.h
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kNoListingType   -1
#define kNoListingTarget -1

typedef enum {
    ListingTypeOffer = 0,
    ListingTypeRequest,
    ListingTypeBoth
} ListingType;

typedef enum {
    ListingTargetItem = 0,
    ListingTargetService,
    ListingTargetRide,
    ListingTargetAccommodation
} ListingTarget;

@class User;

@interface Listing : NSObject <MKAnnotation>

@property (assign) NSInteger listingId;
@property (nonatomic, copy) NSString *title;
@property (strong) NSString *text;
@property (assign) ListingType type;
@property (assign) ListingTarget target;
@property (strong) NSArray *tags;
@property (strong) NSString *transactionType;
@property (strong) UIImage *thumbnailImage;
@property (strong) UIImage *image;
@property (strong) NSString *address;
@property (strong) CLLocation *location;
@property (strong) User *author;
@property (strong) NSDate *date;
@property (strong) NSString *expiresAt;
@property (strong) NSString *departureAt;
@property (assign) NSInteger numberOfTimesViewed;
@property (assign) NSInteger numberOfComments;
@property (strong) NSString *visibility;
@property (strong) NSArray *comments;

- (CLLocationCoordinate2D)coordinate;

+ (NSString *)stringFromType:(ListingType)type;
+ (NSString *)stringFromTarget:(ListingTarget)target;
+ (UIImage *)iconForTarget:(ListingTarget)target;

+ (Listing *)listingFromDict:(NSDictionary *)dict;
+ (NSArray *)listingsFromArrayOfDicts:(NSArray *)dicts;

NSComparisonResult compareListingsByDate(id object1, id object2, void *context);

@end
