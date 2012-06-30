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
@synthesize text;
@synthesize type;
@synthesize target;
@synthesize tags;
@synthesize transactionType;
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
    return text;
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

+ (NSString *)stringFromTarget:(ListingTarget)target
{
    switch (target) {
        case ListingTargetItem:
            return @"item";
        case ListingTargetService:
            return @"service";
        case ListingTargetRide:
            return @"ride";
        case ListingTargetAccommodation:
            return @"accommodation";
        default:
            return nil;
    }
}

+ (ListingTarget)targetFromString:(NSString *)string
{
    if ([string isEqualToString:@"item"]) {
        return ListingTargetItem;
    } else if ([string isEqualToString:@"service"]) {
        return ListingTargetService;
    } else if ([string isEqualToString:@"ride"]) {
        return ListingTargetRide;
    } else if ([string isEqualToString:@"accommodation"]) {
        return ListingTargetAccommodation;
    }
    return kNoListingTarget;
}

+ (UIImage *)iconForTarget:(ListingTarget)target
{
    NSString *targetName = [self stringFromTarget:target];
    return [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@", targetName]];
}

+ (Listing *)listingFromDict:(NSDictionary *)dict
{
    Listing *listing = [[Listing alloc] init];
    
    listing.type = [Listing typeFromString:[dict valueForKey:@"type"]];
    listing.target = [Listing targetFromString:[dict valueForKey:@"target"]];
    listing.transactionType = [dict valueForKey:@"transactionType"];
    
    listing.listingId = [[dict valueForKey:@"id"] intValue];
    listing.title = [dict valueForKey:@"title"];
    listing.text = [dict valueForKey:@"description"];
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
