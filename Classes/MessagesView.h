//
//  MessagesView.h
//  Kassi
//
//  Created by Janne Käki on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessagesView;
@class MessageThread;

@protocol MessagesViewDelegate <NSObject>
- (void)messagesViewDidBeginEditing:(MessagesView *)messagesView;
- (void)messagesViewDidChange:(MessagesView *)messagesView;
- (void)messagesViewDidEndEditing:(MessagesView *)messagesView;
- (void)messagesView:(MessagesView *)messagesView didSaveMessageText:(NSString *)messageText;
@end

@interface MessagesView : UIView <UITextViewDelegate> {

    NSArray *messages;
    MessageThread *messageThread;
}

@property (strong) UIView *backgroundView;
@property (strong) UIView *pointerView;

@property (strong) NSMutableArray *avatarViews;
@property (strong) NSMutableArray *usernameLabels;
@property (strong) NSMutableArray *dateLabels;
@property (strong) NSMutableArray *textLabels;

@property (strong) UITextView *composeField;
@property (strong) UITextField *composeFieldContainer;
@property (strong) UIButton *sendMessageButton;
@property (strong) UIButton *cancelMessageButton;
@property (strong) UILabel *recipientLabel;
@property (strong) UILabel *subjectLabel;

@property (strong) MessageThread *messageThread;
@property (strong) NSArray *messages;
@property (strong) NSString *sendButtonTitle;
@property (strong) NSString *composeFieldPlaceholder;
@property (assign) BOOL showComposerButtons;
@property (assign) BOOL showUserAvatars;

@property (unsafe_unretained) id<MessagesViewDelegate> delegate;

@end
