//
//  Listing.m
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Listing.h"

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
@synthesize thumbnailImage;
@synthesize image;
@synthesize address;
@synthesize location;
@synthesize author;
@synthesize date;
@synthesize expiresAt;
@synthesize departureAt;
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
    [JSON setObject:description forKey:@"description"];
    [JSON setObject:[Listing stringFromCategory:category] forKey:@"category"];
    [JSON setObject:[Listing stringFromType:type] forKey:@"listing_type"];
    
    NSString *shareTypeForJSON = [shareType lowercaseString];
    shareTypeForJSON = [shareTypeForJSON stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [JSON setObject:shareTypeForJSON forKey:@"share_type"];
    
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
    
    listing.category = [Listing categoryFromString:[dict objectOrNilForKey:@"category"]];
    listing.type = [Listing typeFromString:[dict objectOrNilForKey:@"listing_type"]];
    listing.shareType = [[dict objectOrNilForKey:@"share_type"] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    listing.listingId = [[dict objectOrNilForKey:@"id"] intValue];
    listing.title = [dict objectOrNilForKey:@"title"];
    listing.description = [dict objectOrNilForKey:@"description"];
    listing.tags = [dict objectOrNilForKey:@"tags"];
    listing.address = [dict objectOrNilForKey:@"address"];
    
    NSDictionary *coordinates = [dict objectOrNilForKey:@"coordinates"];
    if (coordinates != nil) {
        listing.location = [[CLLocation alloc] initWithLatitude:[[coordinates objectOrNilForKey:@"latitude"] doubleValue] longitude:[[coordinates objectOrNilForKey:@"longitude"] doubleValue]];
    }
        
    listing.author = [User userFromDict:[dict objectOrNilForKey:@"author"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy HH:mm";
    listing.date = [formatter dateFromString:[dict objectOrNilForKey:@"createdAt"]];
    
    listing.comments = [Message messagesFromArrayOfDicts:[dict objectOrNilForKey:@"comments"]];
    
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
    return [[object2 date] compare:[object1 date]];
}

@end
