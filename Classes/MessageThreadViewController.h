//
//  MessageThreadViewController.h
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessagesView.h"
#import "MessageThread.h"

@interface MessageThreadViewController : UIViewController <MessagesViewDelegate>

@property (strong) UIScrollView *scrollView;
@property (strong) MessagesView *messagesView;

@property (strong) MessageThread *messageThread;

@property (assign) BOOL inModalComposerMode;

@end
