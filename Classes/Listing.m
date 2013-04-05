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
@synthesize privacy;

@synthesize comments;

@dynamic coordinate;
@dynamic fullTitle;

- (CLLocationCoordinate2D)coordinate
{
    return location.coordinate;
}

- (NSString *)fullTitle
{
    if (shareType != nil) {
        NSString *labelKey = [NSString stringWithFormat:@"listing.%@ing_type.%@", type, shareType];
        return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(labelKey, @""), title];
    } else {
        return title;
    }
}

- (NSString *)subtitle
{
    return description;
}

- (void)setCategory:(NSString *)newCategory
{
    category = newCategory;
    
    if (![category isEqual:kListingCategoryItem] && ![category isEqual:kListingCategorySpace]) {
        shareType = nil;
    }
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    [JSON setObject:type forKey:@"listing_type"];
    [JSON setObject:category forKey:@"category"];

    if (title != nil) {
        [JSON setObject:title forKey:@"title"];
    }
    
    if (description != nil) {
        [JSON setObject:description forKey:@"description"];
    }
    
    if (shareType != nil) {
        [JSON setObject:shareType forKey:@"share_type"];
    }
    
    if (tags.count > 0) {
        [JSON setObject:tags forKey:@"tags"];
    }
    
    if (location != nil) {
        // [JSON setObject:[location asJSON] forKey:@"origin_location"];
        [JSON setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [JSON setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        if (location.address != nil) {
            if ([category isEqual:kListingCategoryRideshare]) {
                [JSON setObject:location.address forKey: @"origin"];
            } else {
                [JSON setObject:location.address forKey: @"address"];
            }
        }
    }
    
    if ([category isEqual:kListingCategoryRideshare] && destination != nil) {
        // [JSON setObject:[destination asJSON] forKey:@"destination_location"];
        [JSON setObject:[NSNumber numberWithDouble:destination.coordinate.latitude] forKey:@"destination_latitude"];
        [JSON setObject:[NSNumber numberWithDouble:destination.coordinate.longitude] forKey:@"destination_longitude"];
        if (destination.address != nil) {
            [JSON setObject:destination.address forKey:@"destination"];
        }
    }
    
    if (visibility != nil) {
        [JSON setObject:visibility forKey:@"visibility"];
    }
    
    if (privacy != nil) {
        [JSON setObject:privacy forKey:@"privacy"];
    }
    
    if (validUntil != nil) {
        NSLog(@"validUntil: %@", validUntil);
        [JSON setObject:[validUntil timestamp] forKey:@"valid_until"];
    }
    
    NSLog(@"listing as JSON: %@", JSON);
    
    return JSON;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Listing.class]) {
        return NO;
    }
    return (listingId == [object listingId]);
}

+ (UIImage *)iconForCategory:(NSString *)category
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"icon-%@", category]];
}

+ (UIImage *)tinyIconForCategory:(NSString *)category
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"tinyicon-%@", category]];
}

+ (Listing *)listingFromDict:(NSDictionary *)dict
{
    Listing *listing = [[Listing alloc] init];
    
    listing.listingId = [[dict objectOrNilForKey:@"id"] intValue];
    listing.title = [dict objectOrNilForKey:@"title"];
    listing.description = [dict objectOrNilForKey:@"description"];
    
    listing.type = [dict objectOrNilForKey:@"listing_type"];
    listing.category = [dict objectOrNilForKey:@"category"];
    listing.shareType = [dict objectOrNilForKey:@"share_type"];
    listing.tags = [dict objectOrNilForKey:@"tags"];
    
    if ([listing.category isEqual:@"housing"]) {
        listing.category = kListingCategorySpace;
    }
    
    NSString *thumbnailURLString = [dict objectOrNilForKey:@"thumbnail_url"];
    listing.thumbnailURL = (thumbnailURLString != nil) ? [NSURL URLWithString:thumbnailURLString] : nil;
    
    NSArray *imageURLStrings = [dict objectOrNilForKey:@"image_urls"];
    if (imageURLStrings.count > 0) {
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *imageURLString in imageURLStrings) {
            NSString *escapedImageURLString = [imageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [imageURLs addObject:[NSURL URLWithString:escapedImageURLString]];
        }
        listing.imageURLs = imageURLs;
    }
    
    NSDictionary *locationDict = [dict objectOrNilForKey:@"origin_location"];
    if (locationDict != nil) {
        listing.location = [Location locationFromDict:locationDict];
    }
    
    NSDictionary *destinationDict = [dict objectOrNilForKey:@"destination_location"];
    if (destinationDict != nil) {
        listing.destination = [Location locationFromDict:destinationDict];
    }
    
    listing.author = [User userFromDict:[dict objectOrNilForKey:@"author"]];
    listing.numberOfTimesViewed = [[dict objectOrNilForKey:@"times_viewed"] intValue];
    listing.visibility = [dict objectOrNilForKey:@"visibility"];
    listing.privacy = [dict objectOrNilForKey:@"privacy"];
    
    listing.createdAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"created_at"]];
    listing.updatedAt = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"updated_at"]];
    listing.validUntil = [NSDate dateFromTimestamp:[dict objectOrNilForKey:@"valid_until"]];
        
    listing.comments = [Message messagesFromArrayOfDicts:[dict objectOrNilForKey:@"comments"]];
    
    // NSLog(@"parsed listing: %@", dict);
    
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
