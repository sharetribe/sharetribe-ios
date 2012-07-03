//
//  Listing.m
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Listing.h"

#import "Location.h"
#import "Message.h"
#import "User.h"
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

@synthesize location;
@synthesize destination;

@synthesize author;
@synthesize createdAt;
@synthesize updatedAt;
@synthesize validUntil;

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
    
    [JSON setObject:title forKey:@"title"];
    [JSON setObject:[Listing stringFromCategory:category] forKey:@"category"];
    [JSON setObject:[Listing stringFromType:type] forKey:@"listing_type"];
    
    if (description != nil) {
        [JSON setObject:description forKey:@"description"];
    }
    
    if (shareType != nil) {
        NSString *shareTypeForJSON = [shareType lowercaseString];
        shareTypeForJSON = [shareTypeForJSON stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        [JSON setObject:shareTypeForJSON forKey:@"share_type"];
    }
    
    if (visibility != nil) {
        [JSON setObject:visibility forKey:@"visibility"];
    }
    
    return JSON;
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
    return kNoListingType;
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
    return kNoListingCategory;
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
    
    listing.thumbnailURL = [dict objectOrNilForKey:@"thumbnail_url"];
    listing.imageURLs = [dict objectOrNilForKey:@"image_urls"];
    
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
        
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kTimestampFormatInAPI;
    listing.createdAt = [formatter dateFromString:[[dict objectOrNilForKey:@"created_at"] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    listing.updatedAt = [formatter dateFromString:[[dict objectOrNilForKey:@"updated_at"] stringByReplacingOccurrencesOfString:@":" withString:@""]];
    listing.validUntil = [formatter dateFromString:[[dict objectOrNilForKey:@"valid_until"] stringByReplacingOccurrencesOfString:@":" withString:@""]];
        
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
