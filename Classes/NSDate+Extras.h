//
//  NSDate+Extras.h
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kOneMinute (60)
#define kOneHour   (60*60)
#define kOneDay    (60*60*24)

@interface NSDate (Extras)

- (NSString *)agestamp;

@end
