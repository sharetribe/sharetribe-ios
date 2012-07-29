//
//  NSArray+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 7/28/12.
//
//

#import "NSArray+Sharetribe.h"

@implementation NSArray (Sharetribe)

- (id)objectOrNilAtIndex:(NSInteger)index
{
    if (index < 0 || index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end
