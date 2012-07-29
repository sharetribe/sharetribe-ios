//
//  ConversationViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesView.h"

@class Conversation;
@class Listing;
@class User;

@interface ConversationViewController : UIViewController <MessagesViewDelegate>

@property (strong) UIScrollView *scrollView;
@property (strong) MessagesView *messagesView;

@property (strong) Conversation *conversation;
@property (strong) Listing *listing;
@property (strong) User *recipient;

@property (assign) BOOL inModalComposerMode;
@property (assign) BOOL isDirectReplyToListing;

@end
