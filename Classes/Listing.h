//
//  Listing.h
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kListingTypeOffer           @"offer"
#define kListingTypeRequest         @"request"

#define kListingCategoryItem        @"item"
#define kListingCategoryFavor       @"favor"
#define kListingCategoryRideshare   @"rideshare"
#define kListingCategorySpace       @"space"

#define kListingStatusOpen          @"open"
#define kListingStatusClosed        @"closed"

@class Location;
@class User;

@interface Listing : NSObject <MKAnnotation>

@property (assign) NSInteger listingId;
@property (nonatomic, copy) NSString *title;
@property (readonly) NSString *fullTitle;
@property (strong) NSString *description;

@property (strong) NSString *type;
@property (strong) NSString *category;
@property (strong) NSString *shareType;
@property (strong) NSArray *tags;

@property (strong) NSURL *thumbnailURL;
@property (strong) NSArray *imageURLs;

@property (strong) UIImage *image;
@property (strong) NSData *imageData;

@property (strong) Location *location;
@property (strong) Location *destination;

@property (strong) User *author;
@property (strong) NSDate *createdAt;
@property (strong) NSDate *updatedAt;
@property (strong) NSDate *validUntil;
@property (strong) NSString *status;

@property (assign) NSInteger numberOfTimesViewed;
@property (assign) NSInteger numberOfComments;
@property (strong) NSString *visibility;

@property (strong) NSArray *comments;

- (CLLocationCoordinate2D)coordinate;

- (NSDictionary *)asJSON;

+ (UIImage *)iconForCategory:(NSString *)category;

+ (Listing *)listingFromDict:(NSDictionary *)dict;
+ (NSArray *)listingsFromArrayOfDicts:(NSArray *)dicts;

NSComparisonResult compareListingsByDate(id object1, id object2, void *context);

@end
