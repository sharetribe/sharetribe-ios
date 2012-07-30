//
//  MessagesView.h
//  Sharetribe
//
//  Created by Janne Käki on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;
@class MessagesView;
@class User;

@protocol MessagesViewDelegate <NSObject>
- (void)messagesViewDidBeginEditing:(MessagesView *)messagesView;
- (void)messagesViewDidChange:(MessagesView *)messagesView;
- (void)messagesViewDidEndEditing:(MessagesView *)messagesView;
- (void)messagesView:(MessagesView *)messagesView didSaveMessageText:(NSString *)messageText;
- (void)messagesView:(MessagesView *)messagesView didSelectUser:(User *)user;
@end

@interface MessagesView : UIView <UITextViewDelegate> {

    NSArray *messages;
    Conversation *conversation;
}

@property (strong) UIView *backgroundView;
@property (strong) UIView *pointerView;

@property (strong) NSMutableArray *avatarViews;
@property (strong) NSMutableArray *usernameButtons;
@property (strong) NSMutableArray *dateLabels;
@property (strong) NSMutableArray *textLabels;
@property (strong) NSMutableArray *separators;

@property (strong) UITextView *composeField;
@property (strong) UITextField *composeFieldContainer;
@property (strong) UIButton *sendMessageButton;
@property (strong) UIButton *cancelMessageButton;
@property (strong) UILabel *recipientLabel;
@property (strong) UILabel *subjectLabel;

@property (strong) Conversation *conversation;
@property (strong) NSArray *messages;
@property (strong) NSString *sendButtonTitle;
@property (strong) NSString *composeFieldPlaceholder;
@property (assign) BOOL showComposerButtons;
@property (assign) BOOL showUserAvatars;

@property (unsafe_unretained) id<MessagesViewDelegate> delegate;

@end
