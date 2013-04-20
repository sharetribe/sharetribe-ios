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

#define kListingStatusOpen          @"open"
#define kListingStatusClosed        @"closed"

@class Location;
@class User;

@interface Listing : NSObject <MKAnnotation>

@property (assign, nonatomic) NSInteger listingId;
@property (copy, nonatomic) NSString *title;
@property (readonly) NSString *fullTitle;
@property (strong, nonatomic) NSString *description;

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSString *subcategory;
@property (strong, nonatomic) NSString *shareType;

@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) NSArray *imageURLs;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *imageData;

@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) Location *destination;

@property (strong, nonatomic) User *author;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSDate *updatedAt;
@property (strong, nonatomic) NSDate *validUntil;
@property (strong, nonatomic) NSString *status;

@property (assign, nonatomic) NSInteger numberOfTimesViewed;
@property (assign, nonatomic) NSInteger numberOfComments;
@property (strong, nonatomic) NSString *visibility;
@property (strong, nonatomic) NSString *privacy;

@property (strong, nonatomic) NSArray *comments;

- (CLLocationCoordinate2D)coordinate;

- (NSDictionary *)asJSON;

+ (UIImage *)iconForCategory:(NSString *)category;
+ (UIImage *)tinyIconForCategory:(NSString *)category;

+ (Listing *)listingFromDict:(NSDictionary *)dict;
+ (NSArray *)listingsFromArrayOfDicts:(NSArray *)dicts;

NSComparisonResult compareListingsByDate(id object1, id object2, void *context);

@end
