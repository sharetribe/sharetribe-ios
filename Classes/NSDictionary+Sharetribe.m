//
//  NSDictionary+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Sharetribe.h"

@implementation NSDictionary (Sharetribe)

- (id)objectOrNilForKey:(id)key
{
    id value = [self objectForKey:key];
    if ([value isKindOfClass:NSNull.class]) {
        return nil;
    }
    return value;
}

@end
