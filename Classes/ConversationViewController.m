//
//  ConversationViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationViewController.h"

#import "Conversation.h"
#import "Listing.h"
#import "ListingViewController.h"
#import "Message.h"
#import "ProfileViewController.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "NSObject+Observing.h"
#import <QuartzCore/QuartzCore.h>

#define kAlertTagForConfirmingAccept  1000
#define kAlertTagForConfirmingReject  2000

@interface ConversationViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong) UIImageView *disclosureIndicatorView;
@end

@interface UITextFieldWithInsets : UITextField
@end

@implementation ConversationViewController

@synthesize scrollView;
@synthesize messagesView;
@synthesize conversationTitlePrefixLabel;
@synthesize conversationTitleLabel;
@synthesize conversationTitleField;
@synthesize showListingButton;
@synthesize disclosureIndicatorView;
@synthesize acceptButton;
@synthesize rejectButton;
@synthesize statusView;

@synthesize conversation;
@synthesize listing;
@synthesize recipient;

@synthesize inModalComposerMode;
@synthesize isDirectReplyToListing;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 2*44 - 5);
    scrollView.alwaysBounceVertical = YES;
    scrollView.scrollsToTop = YES;
    [self.view addSubview:scrollView];
    
    self.messagesView = [[MessagesView alloc] init];
    messagesView.width = 320;
    messagesView.delegate = self;
    messagesView.sendButtonTitle = NSLocalizedString(@"button.send.message", @"");
    [scrollView addSubview:messagesView];
    
    self.conversationTitlePrefixLabel = [[UILabel alloc] init];
    conversationTitlePrefixLabel.font = [UIFont systemFontOfSize:16];
    conversationTitlePrefixLabel.textColor = [UIColor blackColor];
    conversationTitlePrefixLabel.backgroundColor = [UIColor clearColor];
    conversationTitlePrefixLabel.x = 10;
    conversationTitlePrefixLabel.y = 14;
    conversationTitlePrefixLabel.width = 260;
    [scrollView addSubview:conversationTitlePrefixLabel];
        
    self.conversationTitleLabel = [[UILabel alloc] init];
    conversationTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    conversationTitleLabel.numberOfLines = 0;
    conversationTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
    conversationTitleLabel.textColor = [UIColor blackColor];
    conversationTitleLabel.backgroundColor = [UIColor clearColor];
    conversationTitleLabel.x = 10;
    conversationTitleLabel.y = 14;
    conversationTitleLabel.width = 260;
    [scrollView addSubview:conversationTitleLabel];
    
    self.conversationTitleField = [[UITextFieldWithInsets alloc] init];
    conversationTitleField.borderStyle = UITextBorderStyleRoundedRect;
    conversationTitleField.backgroundColor = [UIColor whiteColor];
    conversationTitleField.font = [UIFont boldSystemFontOfSize:13];
    conversationTitleField.returnKeyType = UIReturnKeyNext;
    conversationTitleField.enablesReturnKeyAutomatically = YES;
    conversationTitleField.keyboardAppearance = UIKeyboardAppearanceAlert;
    conversationTitleField.x = 10;
    conversationTitleField.y = 10;
    conversationTitleField.width = 300;
    conversationTitleField.height = 30;
    conversationTitleField.delegate = self;
    [scrollView addSubview:conversationTitleField];
        
    self.showListingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showListingButton.backgroundColor = [UIColor whiteColor];
    showListingButton.layer.cornerRadius = 5;
    showListingButton.layer.borderWidth = 1;
    showListingButton.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.9].CGColor;
    showListingButton.x = 10;
    showListingButton.y = 10;
    showListingButton.width = 300;
    [showListingButton addTarget:self action:@selector(showListing) forControlEvents:UIControlEventTouchUpInside];
    [scrollView insertSubview:showListingButton belowSubview:conversationTitleLabel];
    
    self.disclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-arrow"]];
    disclosureIndicatorView.x = 276;
    disclosureIndicatorView.y = (showListingButton.height - disclosureIndicatorView.height) / 2;
    [showListingButton addSubview:disclosureIndicatorView];
    
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.7] forState:UIControlStateNormal];
    [acceptButton setBackgroundImage:[[UIImage imageNamed:@"button-pattern-green"] stretchableImageWithLeftCapWidth:5 topCapHeight:19] forState:UIControlStateNormal];
    acceptButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    acceptButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    acceptButton.layer.cornerRadius = 5;
    acceptButton.clipsToBounds = YES;
    acceptButton.x = 10;
    acceptButton.width = 145;
    acceptButton.height = 37;
    [acceptButton addTarget:self action:@selector(acceptButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:acceptButton];
    
    self.rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rejectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rejectButton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.7] forState:UIControlStateNormal];
    [rejectButton setBackgroundImage:[[UIImage imageNamed:@"button-pattern-red"] stretchableImageWithLeftCapWidth:5 topCapHeight:19] forState:UIControlStateNormal];
    rejectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    rejectButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    rejectButton.layer.cornerRadius = 5;
    rejectButton.clipsToBounds = YES;
    rejectButton.x = 165;
    rejectButton.width = 145;
    rejectButton.height = 37;
    [rejectButton addTarget:self action:@selector(rejectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:rejectButton];
    
    self.statusView = [UIButton buttonWithType:UIButtonTypeCustom];
    statusView.userInteractionEnabled = NO;
    statusView.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    statusView.backgroundColor = [UIColor clearColor];
    statusView.x = 10;
    statusView.width = 300;
    statusView.height = 37;
    [scrollView addSubview:statusView];
    
    [self observeNotification:kNotificationForDidReceiveMessagesForConversation withSelector:@selector(gotMessagesForConversation:)];
    [self observeNotification:kNotificationForDidRefreshListing withSelector:@selector(gotListing:)];
    [self observeNotification:kNotificationForDidChangeConversationStatus withSelector:@selector(didChangeConversationStatus:)];
    [self observeNotification:kNotificationForFailedToChangeConversationStatus withSelector:@selector(failedToChangeConversationStatus:)];

    self.navigationController.navigationBar.tintColor = kSharetribeDarkBrownColor;
    self.view.backgroundColor = kSharetribeLightBrownColor;
    
    [self refreshView];
    
    messagesView.messages = conversation.messages;
    
    [self refreshContentHeight];
    
    if (conversation != nil) {
        [[SharetribeAPIClient sharedClient] getMessagesForConversation:conversation];
        if (conversation.listingId != 0 && conversation.listing == nil) {
            [[SharetribeAPIClient sharedClient] getListingWithId:conversation.listingId];
        }
    }
}

- (void)refreshView
{
    if (conversation.listing != nil) {
        self.listing = conversation.listing;
    }
    
    conversationTitleLabel.hidden = NO;
    
    conversationTitlePrefixLabel.hidden = YES;
    conversationTitleField.hidden = YES;
    showListingButton.hidden = YES;
    acceptButton.hidden = YES;
    rejectButton.hidden = YES;
    statusView.hidden = YES;
    // Then let's see if we have a reason to yet reveal some of these.
    
    if (conversation != nil) {
        conversationTitleLabel.text = conversation.title;
    } else if (listing != nil) {
        if (inModalComposerMode) {
            conversationTitlePrefixLabel.hidden = NO;
            conversationTitlePrefixLabel.text = [NSLocalizedString(@"composer.message.subject", @"") stringByAppendingString:@": "];
            conversationTitleLabel.text = listing.title;
            [conversationTitlePrefixLabel sizeToFit];
            conversationTitleLabel.x = conversationTitlePrefixLabel.x+conversationTitlePrefixLabel.width;
        } else {
            conversationTitleLabel.text = listing.title;
        }
    }
    conversationTitleLabel.height = [conversationTitleLabel.text sizeWithFont:conversationTitleLabel.font constrainedToSize:CGSizeMake(conversationTitleLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    
    if (listing != nil) {
        
        if (inModalComposerMode) {
            messagesView.y = conversationTitleLabel.y+conversationTitleLabel.height + 4;
        } else {
            showListingButton.hidden = NO;
            showListingButton.height = conversationTitleLabel.height + 20;
            disclosureIndicatorView.y = (showListingButton.height - disclosureIndicatorView.height) / 2;
            conversationTitleLabel.x = 20;
            conversationTitleLabel.y = 20;
            conversationTitleLabel.width = 256;
            
            int nextY = conversationTitleLabel.y + conversationTitleLabel.height + 22;
            if ([conversation.status isEqual:kConversationStatusPending]) {
                if (conversation.listing.author.isCurrentUser) {
                    acceptButton.hidden = NO;
                    rejectButton.hidden = NO;
                    acceptButton.y = nextY;
                    rejectButton.y = nextY;
                    nextY += acceptButton.height+14;
                    
                    if ([conversation.listing.type isEqual:kListingTypeOffer]) {
                        [acceptButton setTitle:NSLocalizedString(@"button.accept_request", @"") forState:UIControlStateNormal];
                        [rejectButton setTitle:NSLocalizedString(@"button.reject_request", @"") forState:UIControlStateNormal];
                    } else {
                        [acceptButton setTitle:NSLocalizedString(@"button.accept_offer", @"") forState:UIControlStateNormal];
                        [rejectButton setTitle:NSLocalizedString(@"button.reject_offer", @"") forState:UIControlStateNormal];
                    }
                }
            } else if ([conversation.status isEqual:kConversationStatusAccepted] || [conversation.status isEqual:kConversationStatusRejected]) {
                statusView.hidden = NO;
                statusView.y = nextY;
                nextY += statusView.height + 14;
                NSString *statusFormatKey;
                if ([conversation.status isEqual:kConversationStatusAccepted]) {
                    [statusView setTitleColor:[UIColor colorWithRed:0 green:0.4 blue:0 alpha:1] forState:UIControlStateNormal];
                    if (conversation.listing.author.isCurrentUser) {
                        statusFormatKey = [NSString stringWithFormat:@"conversation_status_format.you_accepted_%@", conversation.listing.type];
                    } else {
                        statusFormatKey = [NSString stringWithFormat:@"conversation_status_format.other_accepted_%@", conversation.listing.type];
                    }
                } else {
                    [statusView setTitleColor:[UIColor colorWithRed:0.4 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
                    if (conversation.listing.author.isCurrentUser) {
                        statusFormatKey = [NSString stringWithFormat:@"conversation_status_format.you_rejected_%@", conversation.listing.type];
                    } else {
                        statusFormatKey = [NSString stringWithFormat:@"conversation_status_format.other_rejected_%@", conversation.listing.type];
                    }
                }
                NSString *statusFormat = NSLocalizedString(statusFormatKey, @"");
                [statusView setTitle:[NSString stringWithFormat:statusFormat, conversation.recipient.givenName] forState:UIControlStateNormal];
            }
            
            messagesView.y = nextY;
        }
        
    } else {
        
        if (conversation != nil) {
            messagesView.y = conversationTitleLabel.y + conversationTitleLabel.height + 14;
        } else {
            conversationTitleLabel.hidden = YES;
            conversationTitleField.hidden = NO;
            messagesView.alwaysShowFullSizeComposeField = YES;
            messagesView.y = conversationTitleField.y + conversationTitleField.height;
        }
    }
    
    if (inModalComposerMode) {
        
        NSString *titleFormat = NSLocalizedString(@"composer.message.title_format", @"");;
        self.title = [NSString stringWithFormat:titleFormat, recipient.name];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.send", @"") style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed)];
        
        self.view.backgroundColor = kSharetribeBrownColor;
        
        messagesView.x = 0;
        messagesView.width = 320;
        
        messagesView.showUserAvatars = NO;
        messagesView.showComposerButtons = NO;
        
        if (conversationTitleField.hidden) {
            [messagesView.composeField becomeFirstResponder];
        } else {
            [conversationTitleField becomeFirstResponder];
        }
        
        showListingButton.hidden = YES;  // we came from the listing, so, no need
        
    } else {
        
        self.title = conversation.recipient.name;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.profile", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showRecipientProfile)];
        
        messagesView.x = 10;
        messagesView.width = 300;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor darkGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, -1);
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    conversationTitleField.placeholder = NSLocalizedString(@"placeholder.conversation_title", @"");
    messagesView.composeFieldPlaceholder = (conversation != nil) ? NSLocalizedString(@"placeholder.reply", @"") : NSLocalizedString(@"placeholder.message", @"");
    
    [self refreshContentHeight];
}

- (void)refreshContentHeight
{
    int contentHeight = messagesView.y + messagesView.height + 10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    conversation.unread = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelButtonPressed
{
    messagesView.alpha = 0;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendButtonPressed
{
    [self messagesView:messagesView didSaveMessageText:messagesView.composeField.text];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showRecipientProfile
{
    [self showProfileForUser:conversation.recipient];
}

- (void)showProfileForUser:(User *)user
{
    ProfileViewController *profileViewer = [[ProfileViewController alloc] init];
    profileViewer.user = user;
    [self.navigationController pushViewController:profileViewer animated:YES];
}

- (IBAction)showListing
{
    ListingViewController *listingViewer = [[ListingViewController alloc] init];
    listingViewer.listingId = conversation.listingId;
    if (conversation.listing != nil) {
        listingViewer.listing = conversation.listing;
    }
    [self.navigationController pushViewController:listingViewer animated:YES];
}

- (void)gotMessagesForConversation:(NSNotification *)notification
{
    if (conversation.conversationId == [notification.object conversationId]) {
        self.conversation = notification.object;
        messagesView.messages = conversation.messages;
        [self refreshContentHeight];
        
        [scrollView setContentOffset:CGPointMake(0, MAX(0, scrollView.contentSize.height - scrollView.height)) animated:YES];
        
        // TODO 1) prevent losing field focus if already typing a reply, 2) take care of content height
    }
}

- (void)gotListing:(NSNotification *)notification
{
    Listing *theListing = notification.object;
    if (conversation.listingId == theListing.listingId) {
        listing = theListing;
        conversation.listing = theListing;
    }
    [self refreshView];
    [scrollView setContentOffset:CGPointMake(0, MAX(0, scrollView.contentSize.height - scrollView.height)) animated:YES];
}

- (void)didChangeConversationStatus:(NSNotification *)notification
{
    if (conversation.conversationId == [notification.object conversationId]) {
        self.conversation = notification.object;
        conversation.listing = listing;
        [self refreshView];
    }
}

- (void)failedToChangeConversationStatus:(NSNotification *)notification
{
    
}

- (IBAction)acceptButtonPressed
{
    NSString *titleFormatKey = [NSString stringWithFormat:@"confirm.accept_%@.title_format", ([conversation.listing.type isEqual:kListingTypeOffer] ? kListingTypeRequest : kListingTypeOffer)];
    NSString *messageFormatKey = [NSString stringWithFormat:@"confirm.accept_%@.message_format", ([conversation.listing.type isEqual:kListingTypeOffer] ? kListingTypeRequest : kListingTypeOffer)];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(titleFormatKey, @""), conversation.recipient.givenName];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(messageFormatKey, @""), conversation.recipient.givenName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancel", @"") otherButtonTitles:NSLocalizedString(@"button.accept", @""), nil];
    alert.tag = kAlertTagForConfirmingAccept;
    [alert show];
}

- (IBAction)rejectButtonPressed
{
    NSString *titleFormatKey = [NSString stringWithFormat:@"confirm.reject_%@.title_format", ([conversation.listing.type isEqual:kListingTypeOffer] ? kListingTypeRequest : kListingTypeOffer)];
    NSString *messageFormatKey = [NSString stringWithFormat:@"confirm.reject_%@.message_format", ([conversation.listing.type isEqual:kListingTypeOffer] ? kListingTypeRequest : kListingTypeOffer)];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(titleFormatKey, @""), conversation.recipient.givenName];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(messageFormatKey, @""), conversation.recipient.givenName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancel", @"") otherButtonTitles:NSLocalizedString(@"button.reject", @""), nil];
    alert.tag = kAlertTagForConfirmingReject;
    [alert show];
}

#pragma mark - MessagesViewDelegate

- (void)messagesViewDidBeginEditing:(MessagesView *)theMessagesView
{
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = self.view.height - 216 + 5;
    if (self.navigationController.tabBarController != nil) {
        scrollView.height += 44;
    }
    // self.view.backgroundColor = kSharetribeBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = messagesView.y + messagesView.height + ((inModalComposerMode) ? 0 : 10);
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    NSLog(@"height checkpoint 2a: %d", contentHeight);
    
    int scrollY = (conversation.messages.count > 0) ? (messagesView.y + messagesView.composeField.y - 10) : 0;
    [scrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];
}

- (void)messagesViewDidChange:(MessagesView *)theMessagesView
{
    int scrollY = (conversation.messages.count > 0) ? (messagesView.y + messagesView.composeField.y - 10) : 0;
    [scrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];
}

- (void)messagesViewDidEndEditing:(MessagesView *)theMessagesView
{    
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = self.view.height;
    // self.view.backgroundColor = kSharetribeLightBrownColor;
    [UIView commitAnimations];
    
    [self refreshContentHeight];
}

- (void)messagesView:(MessagesView *)theMessagesView didSaveMessageText:(NSString *)messageText
{
    User *currentUser = [User currentUser];
    Message *message = [Message messageWithAuthor:currentUser content:messageText createdAt:[NSDate date]];
    
    if (conversation == nil) {
        NSString *status = (isDirectReplyToListing) ? kConversationStatusPending : kConversationStatusFree;
        NSString *title = (conversationTitleField.text.length > 0) ? conversationTitleField.text : nil;
        [[SharetribeAPIClient sharedClient] startNewConversationWith:recipient aboutListing:listing withInitialMessage:messageText title:title conversationStatus:status];
        messagesView.messages = [NSArray arrayWithObject:message];
    } else {
        [[SharetribeAPIClient sharedClient] postNewMessage:messageText toConversation:conversation];
        conversation.messages = [conversation.messages arrayByAddingObject:message];
        messagesView.messages = conversation.messages;
    }
}

- (void)messagesView:(MessagesView *)messagesView didSelectUser:(User *)user
{
    [self showProfileForUser:user];
}

- (CGFloat)availableHeightForComposerInMessagesView:(MessagesView *)theMessagesView
{
    CGFloat height = self.view.height - 216;
    if (conversation.messages.count == 0) {
        height -= messagesView.y;
    }
    if (self.navigationController.tabBarController != nil) {
        height += 44;
    }
    return height;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [messagesView.composeField becomeFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == kAlertTagForConfirmingAccept) {
            [[SharetribeAPIClient sharedClient] changeStatusTo:kConversationStatusAccepted forConversation:conversation];
        } else if (alertView.tag == kAlertTagForConfirmingReject) {
            [[SharetribeAPIClient sharedClient] changeStatusTo:kConversationStatusRejected forConversation:conversation];
        }
    }
}

@end

@implementation UITextFieldWithInsets

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 8, 6);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 8, 6);
}

@end
