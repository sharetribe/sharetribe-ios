//
//  Listing.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Listing.h"

#import "Location.h"
#import "Message.h"
#import "User.h"
#import "NSDate+Sharetribe.h"
#import "NSDictionary+Sharetribe.h"

@implementation Listing

@synthesize listingId;
@synthesize title;
@synthesize description;

@synthesize category;
@synthesize type;
@synthesize shareType;
@synthesize tags;

@synthesize thumbnailURL;
@synthesize imageURLs;

@synthesize image;
@synthesize imageData;

@synthesize location;
@synthesize destination;

@synthesize author;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize validUntil;
@synthesize status;

@synthesize numberOfTimesViewed;
@synthesize numberOfComments;
@synthesize visibility;

@synthesize comments;

@dynamic coordinate;

- (CLLocationCoordinate2D)coordinate
{
    return location.coordinate;
}

- (NSString *)subtitle
{
    return description;
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    [JSON setObject:[Listing stringFromCategory:category] forKey:@"category"];
    [JSON setObject:[Listing stringFromType:type] forKey:@"listing_type"];

    if (title != nil) {
        [JSON setObject:title forKey:@"title"];
    }
    
    if (description != nil) {
        [JSON setObject:description forKey:@"description"];
    }
    
    if (shareType != nil) {
        NSString *shareTypeForJSON = [shareType lowercaseString];
        shareTypeForJSON = [shareTypeForJSON stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [JSON setObject:shareTypeForJSON forKey:@"share_type"];
    }
    
    if (location != nil) {
        [JSON setObject:[location asJSON] forKey:@"origin_location"];
    }
    
    if (category == ListingCategoryRide && destination != nil) {
        [JSON setObject:[destination asJSON] forKey:@"destination_location"];
    }
    
    if (visibility != nil) {
        [JSON setObject:visibility forKey:@"visibility"];
    }
    
    return JSON;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Listing.class]) {
        return NO;
    }
    return (listingId == [object listingId]);
}

+ (NSString *)stringFromType:(ListingType)type
{
    switch (type) {
        case ListingTypeOffer:
            return @"offer";
        case ListingTypeRequest:
            return @"request";
        default:
            return nil;
    }
}

+ (ListingType)typeFromString:(NSString *)string
{
    if ([string isEqualToString:@"offer"]) {
        return ListingTypeOffer;
    } else if ([string isEqualToString:@"request"]) {
        return ListingTypeRequest;
    }
    return ListingTypeAny;
}

+ (NSString *)stringFromCategory:(ListingCategory)category
{
    switch (category) {
        case ListingCategoryItem:
            return @"item";
        case ListingCategoryFavor:
            return @"favor";
        case ListingCategoryRide:
            return @"ride";
        case ListingCategoryAccommodation:
            return @"accommodation";
        default:
            return nil;
    }
}

+ (ListingCategory)categoryFromString:(NSString *)string
{
    if ([string isEqualToString:@"item"]) {
        return ListingCategoryItem;
    } else if ([string isEqualToString:@"favor"]) {
        return ListingCategoryFavor;
    } else if ([string isEqualToString:@"ride"]) {
        return ListingCategoryRide;
    } else if ([string isEqualToString:@"accommodation"]) {
        return ListingCategoryAccommodation;
    }
    return ListingCategoryAny;
}

+ (UIImage *)iconForCategory:(ListingCategory)target
{
    NSString *targetName = [self stringFromCategory:target];
    return [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@", targetName]];
}

+ (Listing *)listingFromDict:(NSDictionary *)dict
{
    Listing *listing = [[Listing alloc] init];
    
    listing.listingId = [[dict objectOrNilForKey:@"id"] intValue];
    listing.title = [dict objectOrNilForKey:@"title"];
    listing.description = [dict objectOrNilForKey:@"description"];
    
    listing.category = [Listing categoryFromString:[dict objectOrNilForKey:@"category"]];
    listing.type = [Listing typeFromString:[dict objectOrNilForKey:@"listing_type"]];
    listing.shareType = [[dict objectOrNilForKey:@"share_type"] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    listing.tags = [dict objectOrNilForKey:@"tags"];
    
    NSString *thumbnailURLString = [dict objectOrNilForKey:@"thumbnail_url"];
    listing.thumbnailURL = (thumbnailURLString != nil) ? [NSURL URLWithString:thumbnailURLString] : nil;
    
    NSArray *imageURLStrings = [dict objectOrNilForKey:@"image_urls"];
    if (imageURLStrings.count > 0) {
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *imageURLString in imageURLStrings) {
            [imageURLs addObject:[NSURL URLWithString:imageURLString]];
        }
        listing.imageURLs = imageURLs;
    }
    
    NSDictionary *locationDict = [dict objectOrNilForKey:@"origin_location"];
    if (locationDict != nil) {
        CLLocationDegrees latitude = [[locationDict objectOrNilForKey:@"latitude"] doubleValue];
        CLLocationDegrees longitude = [[locationDict objectOrNilForKey:@"longitude"] doubleValue];
        NSString *address = [locationDict objectOrNilForKey:@"address"];
        listing.location = [[Location alloc] initWithLatitude:latitude longitude:longitude address:address];
    }
    
    listing.author = [User userFromDict:[dict objectOrNilForKey:@"author"]];
    listing.numberOfTimesViewed = [[dict objectOrNilForKey:@"times_viewed"] intValue];
    listing.visibility = [dict objectOrNilForKey:@"visibility"];
    
    listing.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    listing.updatedAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"updated_at"]];
    listing.validUntil = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"valid_until"]];
        
    listing.comments = [Message messagesFromArrayOfDicts:[dict objectOrNilForKey:@"comments"]];
    
    NSLog(@"parsed listing: %@", dict);
    
    return listing;
}

+ (NSArray *)listingsFromArrayOfDicts:(NSArray *)dicts
{
    NSMutableArray *listings = [NSMutableArray arrayWithCapacity:dicts.count];
        
    for (NSDictionary *dict in dicts) {
        Listing *listing = [self listingFromDict:dict];
        [listings addObject:listing];
    }
    
    return listings;
}

NSComparisonResult compareListingsByDate(id object1, id object2, void *context)
{
    return [[object2 createdAt] compare:[object1 createdAt]];
}

@end
