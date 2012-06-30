//
//  MessageThread.h
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@class Message;

@interface MessageThread : NSObject

@property (strong) NSString *subject;
@property (strong) NSMutableArray *messages;
@property (strong) User *recipient;
@property (readonly) NSDate *date;
@property (assign) BOOL hasUnreadMessages;

@end
