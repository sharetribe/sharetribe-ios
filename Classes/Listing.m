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

@dynamic coordinate;
@dynamic fullTitle;

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)fullTitle
{
    if (self.shareType != nil) {
        NSString *labelKey = [NSString stringWithFormat:@"listing.%@ing_type.%@", self.type, self.shareType];
        return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(labelKey, @""), self.title];
    } else {
        return self.title;
    }
}

- (NSString *)subtitle
{
    return self.description;
}

- (void)setCategory:(NSString *)newCategory
{
    _category = newCategory;
    
    if (![self.category isEqual:@"item"] && ![self.category isEqual:@"housing"]) {
        self.shareType = nil;
    }
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    JSON[@"listing_type"] = self.type;
    JSON[@"category"] = self.category;
    
    if (self.subcategory) {
        JSON[@"subcategory"] = self.subcategory;
    }
    
    if (self.shareType) {
        JSON[@"share_type"] = self.shareType;
    }
    
    if (self.title) {
        JSON[@"title"] = self.title;
    }
    
    if (self.description) {
        JSON[@"description"] = self.description;
    }
    
    if (self.location) {
        JSON[@"latitude"] = @(self.location.coordinate.latitude);
        JSON[@"longitude"] = @(self.location.coordinate.longitude);
        if (self.location.address != nil) {
            if ([self.category isEqual:@"rideshare"]) {
                JSON[@"origin"] = self.location.address;
            } else {
                JSON[@"address"] = self.location.address;
            }
        }
    }
    
    if ([self.category isEqual:@"rideshare"] && self.destination != nil) {
        JSON[@"destination_latitude"] = @(self.destination.coordinate.latitude);
        JSON[@"destination_longitude"] = @(self.destination.coordinate.longitude);
        if (self.destination.address != nil) {
            JSON[@"destination"] = self.destination.address;
        }
    }
    
    if (self.visibility) {
        JSON[@"visibility"] = self.visibility;
    }
    
    if (self.privacy) {
        JSON[@"privacy"] = self.privacy;
    }
    
    if (self.validUntil) {
        JSON[@"valid_until"] = [self.validUntil timestamp];
    }
    
    NSLog(@"listing as JSON: %@", JSON);
    
    return JSON;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:Listing.class]) {
        return NO;
    }
    return (self.listingId == [object listingId]);
}

+ (UIImage *)iconForCategory:(NSString *)category
{
    return [self iconForCategory:category withPointSize:32];
}

+ (UIImage *)tinyIconForCategory:(NSString *)category
{
    return [self iconForCategory:category withPointSize:12];
}

+ (UIImage *)iconForCategory:(NSString *)category withPointSize:(CGFloat)pointSize
{
    NSDictionary *iconNames = @{ @"item": @"box", @"favor": @"heart", @"rideshare": @"car", @"space": @"warehouse" };
    NSString *iconName = (iconNames[category]) ? iconNames[category]: @"box";
    return [UIImage imageWithIconNamed:iconName pointSize:pointSize color:[UIColor blackColor] insets:UIEdgeInsetsMake((int) (pointSize / 6), 0, 0, 0)];
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
    
    // if ([listing.category isEqual:@"housing"]) {
    //    listing.category = @"space";
    // } else
    if ([listing.category isEqual:@"other"]) {
        listing.category = @"item";
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
