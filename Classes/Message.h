//
//  Message.h
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface Message : NSObject

@property (strong) NSString *text;
@property (strong) User *sender;
@property (strong) NSDate *date;

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts;

@end
