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
        return [NSString stringWithFormat:@"%@: %@", self.localizedShareType, self.title];
    } else {
        return self.title;
    }
}

- (NSString *)subtitle
{
    return self.description;
}

- (NSString *)formattedPrice
{
    static NSNumberFormatter *priceFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        priceFormatter = [[NSNumberFormatter alloc] init];
        priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    });
    priceFormatter.currencyCode = self.priceCurrency;
    NSString *price = [priceFormatter stringFromNumber:@(self.priceInCents / 100)];
    price = [price stringByReplacingOccurrencesOfString:@".00" withString:@""];
    if (self.priceQuantity) {
        price = [price stringByAppendingFormat:@" / %@", self.priceQuantity.lowercaseString];
    }
    return price;
}

- (NSString *)localizedShareType
{
    NSString *key = [NSString stringWithFormat:@"listing.%@ing_type.%@", self.type, self.shareType];
    return NSLocalizedString(key, nil);
}

- (void)setCategory:(NSString *)newCategory
{
    _category = newCategory;
    
    if (![self.category isEqual:@"item"] && ![self.category isEqual:@"housing"]) {
        self.shareType = nil;
    }
}

- (void)setPriceDict:(NSMutableDictionary *)priceDict
{
    _priceDict = priceDict;
    self.priceInCents  = [[NSNumber cast:priceDict[@"priceInCents"]] integerValue];
    self.priceCurrency = [NSString cast:priceDict[@"priceCurrency"]];
    self.priceQuantity = [NSString cast:priceDict[@"priceQuantity"]];
}

- (NSDictionary *)asJSON
{
    NSMutableDictionary *JSON = [NSMutableDictionary dictionary];
    
    JSON[@"listing_type"] = self.type;
    JSON[@"category"] = (self.subcategory) ? self.subcategory : self.category;
        
    if (self.shareType) {
        JSON[@"share_type"] = self.shareType;
    }
    
    if (self.title) {
        JSON[@"title"] = self.title;
    }
    
    if (self.description) {
        JSON[@"description"] = self.description;
    }
    
    if (self.priceInCents > 0) {
        JSON[@"price_cents"] = @(self.priceInCents);
        JSON[@"currency"] = self.priceCurrency;
        JSON[@"quantity"] = self.priceQuantity;
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

+ (Listing *)listingFromDict:(NSDictionary *)dict
{
    Listing *listing = [[Listing alloc] init];
    
    listing.listingId = [[NSNumber cast:dict[@"id"]] intValue];
    listing.title = [NSString cast:dict[@"title"]];
    listing.description = [NSString cast:dict[@"description"]];
    
    listing.type = [NSString cast:dict[@"listing_type"]];
    listing.category = [NSString cast:dict[@"category"]];
    listing.shareType = [NSString cast:dict[@"share_type"]];
    
    // if ([listing.category isEqual:@"housing"]) {
    //    listing.category = @"space";
    // } else
    if ([listing.category isEqual:@"other"]) {
        listing.category = @"item";
    }
    
    listing.priceInCents = [[NSNumber cast:dict[@"price_cents"]] integerValue];
    listing.priceCurrency = [NSString cast:dict[@"currency"]];
    listing.priceQuantity = [NSString cast:dict[@"quantity"]];
    
    NSString *thumbnailURLString = [NSString cast:dict[@"thumbnail_url"]];
    listing.thumbnailURL = (thumbnailURLString != nil) ? [NSURL URLWithString:thumbnailURLString] : nil;
    
    NSArray *imageURLStrings = [NSArray cast:dict[@"image_urls"]];
    if (imageURLStrings.count > 0) {
        NSMutableArray *imageURLs = [NSMutableArray array];
        for (NSString *imageURLString in imageURLStrings) {
            NSString *escapedImageURLString = [imageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [imageURLs addObject:[NSURL URLWithString:escapedImageURLString]];
        }
        listing.imageURLs = imageURLs;
    }
    
    NSDictionary *locationDict = [NSDictionary cast:dict[@"origin_location"]];
    if (locationDict != nil) {
        listing.location = [Location locationFromDict:locationDict];
    }
    
    NSDictionary *destinationDict = [NSDictionary cast:dict[@"destination_location"]];
    if (destinationDict != nil) {
        listing.destination = [Location locationFromDict:destinationDict];
    }
    
    listing.author = [User userFromDict:[NSDictionary cast:dict[@"author"]]];
    listing.numberOfTimesViewed = [[NSNumber cast:dict[@"times_viewed"]] intValue];
    listing.visibility = [NSString cast:dict[@"visibility"]];
    listing.privacy = [NSString cast:dict[@"privacy"]];
    
    listing.createdAt = [NSDate dateFromTimestamp:[NSString cast:dict[@"created_at"]]];
    listing.updatedAt = [NSDate dateFromTimestamp:[NSString cast:dict[@"updated_at"]]];
    listing.validUntil = [NSDate dateFromTimestamp:[NSString cast:dict[@"valid_until"]]];
        
    listing.comments = [Message messagesFromArrayOfDicts:[NSArray cast:dict[@"comments"]]];
    
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

+ (NSString *)iconNameForItem:(NSString *)item
{
    static NSDictionary *iconsByItem = nil;
    static dispatch_once_t onceTokenForIconsByItem;
    dispatch_once(&onceTokenForIconsByItem, ^{
        NSData *iconsByItemData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icons-by-item" ofType:@"json"]];
        iconsByItem = [NSJSONSerialization JSONObjectWithData:iconsByItemData options:0 error:nil];
    });
    return iconsByItem[item];
}

NSComparisonResult compareListingsByDate(id object1, id object2, void *context)
{
    return [[object2 createdAt] compare:[object1 createdAt]];
}

@end
