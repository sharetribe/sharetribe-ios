//
//  FormItem.m
//  Sharetribe
//
//  Created by Janne Käki on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormItem.h"

@implementation FormItem

@synthesize type;
@synthesize typeAsString;

@synthesize title;
@synthesize subtitle;
@synthesize mapsTo;
@synthesize whatIsThis;
@synthesize mandatory;
@synthesize alternatives;
@synthesize defaultAlternative;
@synthesize defaultTimeIntervalInDays;
@synthesize includeTime;
@synthesize autocapitalizationType;

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
        
        item.title = [dataDict valueForKey:@"title"];
        item.subtitle = [dataDict valueForKey:@"subtitle"];
        item.mapsTo = [dataDict valueForKey:@"mapsTo"];
        NSLog(@"%@ maps to %@", item.title, item.mapsTo);
        item.whatIsThis = [dataDict valueForKey:@"whatIsThis"];
        item.mandatory = [[dataDict valueForKey:@"mandatory"] boolValue];
        item.alternatives = [dataDict valueForKey:@"alternatives"];
        item.defaultAlternative = [dataDict valueForKey:@"defaultAlternative"];
        item.defaultTimeIntervalInDays = [[dataDict valueForKey:@"defaultTimeIntervalInDays"] intValue];
        item.includeTime = [[dataDict valueForKey:@"includeTime"] boolValue];
        
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

@end
