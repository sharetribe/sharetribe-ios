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
    
    [JSON setValue:title forKey:@"title"];
    [JSON setValue:description forKey:@"description"];
    [JSON setValue:[Listing stringFromCategory:category] forKey:@"category"];
    [JSON setValue:[Listing stringFromType:type] forKey:@"listing_type"];
    
    NSString *shareTypeForJSON = [shareType lowercaseString];
    shareTypeForJSON = [shareTypeForJSON stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [JSON setValue:shareTypeForJSON forKey:@"share_type"];
    
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
    
    listing.category = [Listing categoryFromString:[dict valueForKey:@"category"]];
    listing.type = [Listing typeFromString:[dict valueForKey:@"listing_type"]];
    listing.shareType = [dict valueForKey:@"share_type"];
    
    listing.listingId = [[dict valueForKey:@"id"] intValue];
    listing.title = [dict valueForKey:@"title"];
    listing.description = [dict valueForKey:@"description"];
    listing.tags = [[dict valueForKey:@"tags"] componentsSeparatedByString:@","];
    listing.address = [dict valueForKey:@"address"];
    
    NSDictionary *coordinates = [dict valueForKey:@"coordinates"];
    if (coordinates != nil) {
        listing.location = [[CLLocation alloc] initWithLatitude:[[coordinates valueForKey:@"latitude"] doubleValue] longitude:[[coordinates valueForKey:@"longitude"] doubleValue]];
    }
        
    listing.author = [User userFromDict:[dict valueForKey:@"author"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy HH:mm";
    listing.date = [formatter dateFromString:[dict valueForKey:@"createdAt"]];
    
    listing.comments = [Message messagesFromArrayOfDicts:[dict valueForKey:@"comments"]];
    
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
