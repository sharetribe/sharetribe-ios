//
//  MessagesView.m
//  Sharetribe
//
//  Created by Janne Käki on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesView.h"

#import "Message.h"
#import "Conversation.h"
#import "User.h"
#import "NSDate+Sharetribe.h"
#import "UIImageView+Sharetribe.h"
#import <QuartzCore/QuartzCore.h>

#define kSeparatorTag      7

@interface MessagesViewCustomTextField : UITextField
@end

@interface MessagesView ()
@end

@implementation MessagesView

@synthesize backgroundView;
@synthesize pointerView;

@synthesize avatarViews;
@synthesize usernameButtons;
@synthesize dateLabels;
@synthesize textLabels;
@synthesize separators;

@synthesize composeField;
@synthesize composeFieldContainer;
@synthesize sendMessageButton;
@synthesize cancelMessageButton;
@synthesize recipientLabel;
@synthesize subjectLabel;

@dynamic messages;
@dynamic conversation;
@dynamic sendButtonTitle;
@dynamic composeFieldPlaceholder;
@synthesize showComposerButtons;
@synthesize showUserAvatars;
@synthesize alwaysShowFullSizeComposeField;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        
        self.width = 300;
        
        // self.pointerView = [[UIView alloc] init];
        // pointerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pointing-corner"]];
        // pointerView.frame = CGRectMake(12, 0, 27, 14);
        // [self addSubview:pointerView];
        
        self.backgroundView = [[UIView alloc] init];
        backgroundView.frame = CGRectMake(0, 0, self.width, 86);
        backgroundView.backgroundColor = kSharetribeLightThemeColor;
        backgroundView.layer.cornerRadius = 5;
        [self addSubview:backgroundView];
        
        self.avatarViews = [NSMutableArray array];
        self.usernameButtons = [NSMutableArray array];
        self.dateLabels = [NSMutableArray array];
        self.textLabels = [NSMutableArray array];
        self.separators = [NSMutableArray array];
                
        self.composeFieldContainer = [[MessagesViewCustomTextField alloc] init];
        composeFieldContainer.frame = CGRectMake(50, 0, self.width-50-10, 31);
        composeFieldContainer.borderStyle = UITextBorderStyleRoundedRect;
        composeFieldContainer.font = [UIFont systemFontOfSize:13];
        composeFieldContainer.userInteractionEnabled = NO;
        [self addSubview:composeFieldContainer];
        
        self.composeField = [[UITextView alloc] init];
        composeField.frame = CGRectMake(50, 0, self.width-50-10, 31);
        composeField.backgroundColor = [UIColor clearColor];
        composeField.font = [UIFont systemFontOfSize:13];
        composeField.keyboardAppearance = UIKeyboardAppearanceAlert;
        composeField.showsVerticalScrollIndicator = NO;
        // composeField.contentInset = UIEdgeInsetsMake(-2, 10, -2, 10);
        composeField.delegate = self;
        [self addSubview:composeField];
        
        self.sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendMessageButton.frame = CGRectMake(50, self.height-40, 150, 30);
        sendMessageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        sendMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [sendMessageButton setBackgroundImage:[[UIImage imageWithColor:kSharetribeSecondaryThemeColor] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [sendMessageButton addTarget:self action:@selector(sendMessagePressed) forControlEvents:UIControlEventTouchUpInside];
        sendMessageButton.hidden = YES;
        [self addSubview:sendMessageButton];
        
        self.cancelMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelMessageButton.frame = CGRectMake(50+sendMessageButton.width+10, self.height-40, self.width-50-20-sendMessageButton.width, 30);
        cancelMessageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        cancelMessageButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [cancelMessageButton setTitle:NSLocalizedString(@"button.cancel", @"") forState:UIControlStateNormal];
        [cancelMessageButton setBackgroundImage:[[UIImage imageWithColor:kSharetribeSecondaryThemeColor] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [cancelMessageButton addTarget:self action:@selector(cancelMessagePressed) forControlEvents:UIControlEventTouchUpInside];
        cancelMessageButton.hidden = YES;
        [self addSubview:cancelMessageButton];
        
        self.recipientLabel = [[UILabel alloc] init];
        recipientLabel.frame = CGRectMake(10, 0, self.width-20, 20);
        recipientLabel.font = [UIFont boldSystemFontOfSize:13];
        recipientLabel.backgroundColor = [UIColor clearColor];
        recipientLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:recipientLabel];
        recipientLabel.hidden = YES;

        self.subjectLabel = [[UILabel alloc] init];
        subjectLabel.frame = CGRectMake(10, 0, self.width-20, 20);
        subjectLabel.font = [UIFont boldSystemFontOfSize:13];
        subjectLabel.backgroundColor = [UIColor clearColor];
        subjectLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:subjectLabel];
        subjectLabel.hidden = YES;
        
        self.showComposerButtons = YES;
        self.showUserAvatars = YES;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    backgroundView.height = frame.size.height;
}

- (NSArray *)messages
{
    return messages;
}

- (void)setMessages:(NSArray *)newMessages
{
    messages = newMessages;
    
    int leftEdgeX = (showUserAvatars) ? 50 : 10;
    int yOffset = 10;
    
    for (int i = 0; i <= messages.count; i++) {  // Note: one extra for the "add comment" field
                
        UIImageView *avatarView;
        if (i < avatarViews.count) {
            avatarView = [avatarViews objectAtIndex:i];
        } else {
            avatarView = [[UIImageView alloc] init];
            avatarView.contentMode = UIViewContentModeScaleAspectFill;
            avatarView.clipsToBounds = YES;
            avatarView.layer.borderColor = kSharetribeBackgroundColor.CGColor;
            avatarView.layer.borderWidth = 1;
            avatarView.frame = CGRectMake(10, 0, 30, 30);
            [self addSubview:avatarView];
            [avatarViews addObject:avatarView];
        }
        avatarView.y = yOffset;
        avatarView.hidden = !showUserAvatars;
        
        if (i == messages.count) {
            User *currentUser = [User currentUser];
            [avatarView setImageWithUser:currentUser];
            break;
        }
        
        Message *message = [messages objectAtIndex:i];
        
        if (showUserAvatars) {
            [avatarView setImageWithUser:message.author];
        }
                
        UIButton *usernameButton;
        if (i < usernameButtons.count) {
            usernameButton = [usernameButtons objectAtIndex:i];
        } else {
            usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
            usernameButton.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-10, 16);
            usernameButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            [usernameButton setTitleColor:kSharetribeThemeColor forState:UIControlStateNormal];
            [usernameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [usernameButton addTarget:self action:@selector(usernameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            usernameButton.tag = i;
            [self addSubview:usernameButton];
            [usernameButtons addObject:usernameButton];
        }
        [usernameButton setTitle:message.author.name forState:UIControlStateNormal];
        usernameButton.width = [message.author.name sizeWithFont:usernameButton.titleLabel.font].width;
        usernameButton.y = yOffset-2;
        usernameButton.hidden = NO;

        UILabel *dateLabel;
        if (i < dateLabels.count) {
            dateLabel = [dateLabels objectAtIndex:i];
        } else {
            dateLabel = [[UILabel alloc] init];
            dateLabel.font = [UIFont systemFontOfSize:12];
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.textAlignment = NSTextAlignmentRight;
            dateLabel.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-12, 16);
            [self addSubview:dateLabel];
            [dateLabels addObject:dateLabel];
        }
        dateLabel.text = message.createdAt.agestamp;
        dateLabel.y = yOffset-2;
        dateLabel.hidden = NO;
        
        int dateWidth = [dateLabel.text sizeWithFont:dateLabel.font].width;
        int widthAvailableForName = self.width-leftEdgeX-15-dateWidth;
        usernameButton.width = MIN(usernameButton.width, widthAvailableForName);
        
        yOffset += 20;
        
        UILabel *textLabel;
        if (i < textLabels.count) {
            textLabel = [textLabels objectAtIndex:i];
        } else {
            textLabel = [[UILabel alloc] init];
            textLabel.font = [UIFont systemFontOfSize:13];
            textLabel.textColor = [UIColor blackColor];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.frame = CGRectMake(leftEdgeX, 24, self.width-leftEdgeX-10, 50);
            textLabel.numberOfLines = 0;
            textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self addSubview:textLabel];
            [textLabels addObject:textLabel];
        }
        textLabel.text = message.content;
        textLabel.y = yOffset;
        textLabel.height = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(textLabel.width, 10000) lineBreakMode:NSLineBreakByWordWrapping].height;
        textLabel.hidden = NO;
        
        UIView *separator;
        if (i < separators.count) {
            separator = [separators objectAtIndex:i];
        } else {
            separator = [[UIView alloc] init];
            separator.backgroundColor = kSharetribeBackgroundColor;
            separator.frame = CGRectMake(0, 0, self.width, 1);
            [self addSubview:separator];
            [separators addObject:separator];
        }
        
        separator.y = textLabel.y+textLabel.height+8;
        separator.hidden = NO;
        yOffset = separator.y+12;
        NSLog(@"separator y: %.0f for text: %@", separator.y, textLabel.text);
    }
    
    if (conversation != nil) {
        
        recipientLabel.y = yOffset;
        yOffset += recipientLabel.height;
        subjectLabel.y = yOffset;
        yOffset += subjectLabel.height+10;
        
        recipientLabel.text = [NSString stringWithFormat:@"To: %@", conversation.recipient.name];  // LOCALIZE
        subjectLabel.text = conversation.title;
        
        recipientLabel.hidden = NO;
        subjectLabel.hidden = NO;
        
    } else {
        
        recipientLabel.hidden = YES;
        subjectLabel.hidden = YES;
    }
    
    composeField.x = leftEdgeX;
    composeFieldContainer.x = composeField.x;
    
    composeField.width = self.width-leftEdgeX-10;
    composeFieldContainer.width = composeField.width;
    
    composeField.y = yOffset;
    composeFieldContainer.y = yOffset;
    if (!composeField.isFirstResponder) {
        [self setComposeFieldShowingInFullSize:alwaysShowFullSizeComposeField];
    }
    
    int heightForButtons = (showComposerButtons && (composeField.isFirstResponder || composeField.text.length > 0)) ? 40 : 0;
        
    self.height = yOffset + composeField.height + heightForButtons + 10;
    
    for (int i = messages.count+1; i < avatarViews.count; i++) {
        [[avatarViews objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < usernameButtons.count; i++) {
        [[usernameButtons objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < dateLabels.count; i++) {
        [[dateLabels objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < textLabels.count; i++) {
        [[textLabels objectAtIndex:i] setHidden:YES];
    }
    for (int i = messages.count; i < separators.count; i++) {
        [[separators objectAtIndex:i] setHidden:YES];
    }
}

- (Conversation *)conversation
{
    return conversation;
}

- (void)setConversation:(Conversation *)newConversation
{
    conversation = newConversation;
    
    self.messages = conversation.messages;
}

- (NSString *)sendButtonTitle
{
    return [sendMessageButton titleForState:UIControlStateNormal];
}

- (void)setSendButtonTitle:(NSString *)sendButtonTitle
{
    [sendMessageButton setTitle:sendButtonTitle forState:UIControlStateNormal];
}

- (NSString *)composeFieldPlaceholder
{
    return composeFieldContainer.placeholder;
}

- (void)setComposeFieldPlaceholder:(NSString *)composeFieldPlaceholder
{
    composeFieldContainer.placeholder = composeFieldPlaceholder;
}

- (IBAction)sendMessagePressed
{
    [delegate messagesView:self didSaveMessageText:composeField.text];
    composeField.text = nil;
    [composeField resignFirstResponder];
}

- (IBAction)cancelMessagePressed
{
    composeField.text = nil;
    [composeField resignFirstResponder];
}

- (IBAction)usernameButtonPressed:(UIButton *)sender
{
    Message *message = [messages objectAtIndex:sender.tag];
    [delegate messagesView:self didSelectUser:message.author];
}

- (void)setComposeFieldShowingInFullSize:(BOOL)fullSize
{
    if (fullSize) {
        
        int heightForButtons = (showComposerButtons) ? 40 : 0;
        composeField.height = [delegate availableHeightForComposerInMessagesView:self]-10-heightForButtons-10;
        composeFieldContainer.height = composeField.height;
        
        self.height = composeField.y + composeField.height + heightForButtons + 10;
        
    } else {
        
        composeField.height = 31;
        composeFieldContainer.height = composeField.height;
        self.height = composeField.y + composeField.height + 10;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.showsVerticalScrollIndicator = YES;
        
    sendMessageButton.hidden = !showComposerButtons;
    cancelMessageButton.hidden = !showComposerButtons;
    
    [self setComposeFieldShowingInFullSize:YES];
    
    composeFieldContainer.text = @" ";  // hide the placeholder
    
    [delegate messagesViewDidBeginEditing:self];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [delegate messagesViewDidChange:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    textView.showsVerticalScrollIndicator = NO;
    
    [self setComposeFieldShowingInFullSize:alwaysShowFullSizeComposeField];
    
    sendMessageButton.hidden = YES;
    cancelMessageButton.hidden = YES;
    
    composeFieldContainer.text = nil;
    
    [delegate messagesViewDidEndEditing:self];
}

@end

@implementation MessagesViewCustomTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 8, 6);
}

@end
