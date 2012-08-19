//
//  NSString+Sharetribe.m
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import "NSString+Sharetribe.h"

@implementation NSString (Sharetribe)

- (NSString *)equalWhitespaceWithFont:(UIFont *)font
{
    NSMutableString *whitespace = [NSMutableString string];
    while ([self sizeWithFont:font].width > [whitespace sizeWithFont:font].width) {
        [whitespace appendString:@" "];
    }
    return whitespace;
}

@end
