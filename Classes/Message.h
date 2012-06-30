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

@property (strong) NSString *content;
@property (strong) NSDate *createdAt;
@property (strong) NSString *authorId;

+ (NSArray *)messagesFromArrayOfDicts:(NSArray *)dicts;

@end
