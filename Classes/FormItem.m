//
//  FormItem.m
//  Sharetribe
//
//  Created by Janne Käki on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormItem.h"

#import "NSDate+Sharetribe.h"

@implementation FormItem

@synthesize type;
@synthesize typeAsString;

@synthesize formItemId;
@synthesize subtitleKey;
@synthesize mapsTo;
@synthesize providesExplanation;
@synthesize mandatory;
@synthesize alternatives;
@synthesize defaultAlternative;
@synthesize defaultTimeIntervalInDays;
@synthesize includeTime;
@synthesize autocapitalizationType;
@synthesize listSeparator;

+ (NSArray *)formItemsFromDataArray:(NSArray *)dataArray
{
    NSMutableArray *formItems = [NSMutableArray arrayWithCapacity:dataArray.count];
    
    for (NSDictionary *dataDict in dataArray) {
        
        FormItem *item = [[FormItem alloc] init];
        
        item.typeAsString = [dataDict valueForKey:@"type"];
        if ([item.typeAsString isEqualToString:@"textfield"]) {
            item.type = FormItemTypeTextField;
        } else if ([item.typeAsString isEqualToString:@"textarea"]) {
            item.type = FormItemTypeTextArea;
        } else if ([item.typeAsString isEqualToString:@"choice"]) {
            item.type = FormItemTypeChoice;
        } else if ([item.typeAsString isEqualToString:@"date"]) {
            item.type = FormItemTypeDate;
        } else if ([item.typeAsString isEqualToString:@"location"]) {
            item.type = FormItemTypeLocation;
        } else if ([item.typeAsString isEqualToString:@"photo"]) {
            item.type = FormItemTypePhoto;
        }
        
        item.formItemId = [dataDict valueForKey:@"id"];
        item.subtitleKey = [dataDict valueForKey:@"subtitle"];
        item.mapsTo = [dataDict valueForKey:@"maps_to"];
        item.mandatory = [[dataDict valueForKey:@"mandatory"] boolValue];
        item.alternatives = [[dataDict valueForKey:@"alternatives"] mutableCopy];
        item.defaultAlternative = [dataDict valueForKey:@"default_alternative"];
        item.defaultTimeIntervalInDays = [[dataDict valueForKey:@"default_time_interval_in_days"] intValue];
        item.includeTime = [[dataDict valueForKey:@"include_time"] boolValue];
        item.allowsUndefined = [[dataDict valueForKey:@"allows_undefined"] boolValue];
        item.providesExplanation = [[dataDict objectForKey:@"provides_explanation"] boolValue];
        item.listSeparator = [dataDict valueForKey:@"list_separator"];
        
        if (item.type == FormItemTypeDate) {
            NSDate *defaultDate = [NSDate dateWithTimeIntervalSinceNow:(item.defaultTimeIntervalInDays * kOneDay)];
            item.defaultAlternative = defaultDate;
            if (item.allowsUndefined) {
                item.alternatives = @[defaultDate, kValidForTheTimeBeing].mutableCopy;
            } else {
                item.alternatives = @[defaultDate].mutableCopy;
            }
        }
        
        // NSLog(@"%@ maps to %@", item.title, item.mapsTo);
        
        NSString *autocapitalizationValue = [dataDict valueForKey:@"autocapitalization"];
        if ([autocapitalizationValue isEqual:@"none"]) {
            item.autocapitalizationType = UITextAutocapitalizationTypeNone;
        } else if ([autocapitalizationValue isEqual:@"sentences"]) {
            item.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        } else if ([autocapitalizationValue isEqual:@"words"]) {
            item.autocapitalizationType = UITextAutocapitalizationTypeWords;
        } else if ([autocapitalizationValue isEqual:@"all"]) {
            item.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        } else {
            item.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        }
            
        [formItems addObject:item];
    }
    
    return formItems;
}

- (NSString *)localizedTitle
{
    NSString *key = [NSString stringWithFormat:@"listing.%@", formItemId];
    return NSLocalizedString(key, @"");
}

- (NSString *)localizedTitleForAlternative:(NSString *)alternative
{
    NSString *key = [NSString stringWithFormat:@"listing.%@.%@", formItemId, alternative];
    return NSLocalizedString(key, @"");
}

- (NSString *)localizedSubtitle
{
    NSString *key = [NSString stringWithFormat:@"listing.subtitle.%@", subtitleKey];
    return NSLocalizedString(key, @"");
}

- (NSString *)localizedExplanation
{
    NSString *key = [NSString stringWithFormat:@"listing.explanation.%@", formItemId];
    return NSLocalizedString(key, @"");
}
    
@end
