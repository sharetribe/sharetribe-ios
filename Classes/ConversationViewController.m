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
#import <QuartzCore/QuartzCore.h>

@interface ConversationViewController () <UITextFieldDelegate>
@end

@interface UITextFieldWithInsets : UITextField
@end

@implementation ConversationViewController

@synthesize scrollView;
@synthesize messagesView;
@synthesize recipientPrefixLabel;
@synthesize recipientLabel;
@synthesize conversationTitlePrefixLabel;
@synthesize conversationTitleLabel;
@synthesize conversationTitleField;
@synthesize showListingButton;

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
    scrollView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    self.messagesView = [[MessagesView alloc] init];
    messagesView.width = 320;
    messagesView.delegate = self;
    messagesView.sendButtonTitle = NSLocalizedString(@"button.send.message", @"");
    [scrollView addSubview:messagesView];
    
    self.conversationTitlePrefixLabel = [[UILabel alloc] init];
    conversationTitlePrefixLabel.font = [UIFont systemFontOfSize:15];
    conversationTitlePrefixLabel.textColor = [UIColor blackColor];
    conversationTitlePrefixLabel.backgroundColor = [UIColor clearColor];
    conversationTitlePrefixLabel.x = 20;
    conversationTitlePrefixLabel.y = 20;
    conversationTitlePrefixLabel.width = 260;
    [scrollView addSubview:conversationTitlePrefixLabel];
    
    self.recipientLabel = [[UILabel alloc] init];
    recipientLabel.font = [UIFont boldSystemFontOfSize:15];
    recipientLabel.numberOfLines = 0;
    recipientLabel.lineBreakMode = UILineBreakModeWordWrap;
    recipientLabel.textColor = [UIColor blackColor];
    recipientLabel.backgroundColor = [UIColor clearColor];
    recipientLabel.x = 20;
    recipientLabel.y = 20;
    recipientLabel.width = 260;
    [scrollView addSubview:recipientLabel];

    self.recipientPrefixLabel = [[UILabel alloc] init];
    recipientPrefixLabel.font = [UIFont systemFontOfSize:15];
    recipientPrefixLabel.textColor = [UIColor blackColor];
    recipientPrefixLabel.backgroundColor = [UIColor clearColor];
    recipientPrefixLabel.x = 20;
    recipientPrefixLabel.y = 20;
    recipientPrefixLabel.width = 260;
    [scrollView addSubview:recipientPrefixLabel];
    
    self.conversationTitleLabel = [[UILabel alloc] init];
    conversationTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    conversationTitleLabel.numberOfLines = 0;
    conversationTitleLabel.lineBreakMode = UILineBreakModeWordWrap;
    conversationTitleLabel.textColor = [UIColor blackColor];
    conversationTitleLabel.backgroundColor = [UIColor clearColor];
    conversationTitleLabel.x = 20;
    conversationTitleLabel.y = 20;
    conversationTitleLabel.width = 260;
    [scrollView addSubview:conversationTitleLabel];
    
    self.conversationTitleField = [[UITextFieldWithInsets alloc] init];
    conversationTitleField.borderStyle = UITextBorderStyleRoundedRect;
    conversationTitleField.backgroundColor = [UIColor whiteColor];
    conversationTitleField.font = [UIFont systemFontOfSize:13];
    conversationTitleField.returnKeyType = UIReturnKeyNext;
    conversationTitleField.enablesReturnKeyAutomatically = YES;
    conversationTitleField.x = 10;
    conversationTitleField.y = 20;
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
    
    UIImageView *disclosureIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-arrow"]];
    disclosureIndicatorView.x = 280;
    disclosureIndicatorView.y = (showListingButton.height-disclosureIndicatorView.height)/2;
    disclosureIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [showListingButton addSubview:disclosureIndicatorView];
    
    [self observeNotification:kNotificationForDidReceiveMessagesForConversation withSelector:@selector(gotMessagesForConversation:)];
    [self observeNotification:kNotificationForDidRefreshListing withSelector:@selector(gotListing:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = kSharetribeDarkBrownColor;
    self.view.backgroundColor = kSharetribeLightBrownColor;
    
    conversationTitleLabel.hidden = NO;
    
    recipientLabel.hidden = YES;
    recipientPrefixLabel.hidden = YES;
    conversationTitlePrefixLabel.hidden = YES;
    conversationTitleField.hidden = YES;
    showListingButton.hidden = YES;
    // Then let's see if we have a reason to yet reveal some of these.
    
    if (conversation != nil) {
        conversationTitleLabel.text = conversation.title;
    } else if (listing != nil) {
        if (inModalComposerMode) {
            recipientLabel.hidden = NO;
            recipientPrefixLabel.hidden = NO;
            conversationTitlePrefixLabel.hidden = NO;
            recipientPrefixLabel.text = [NSLocalizedString(@"composer.message.to", @"") stringByAppendingString:@": "];
            recipientLabel.text = recipient.name;
            conversationTitlePrefixLabel.text = [NSLocalizedString(@"composer.message.subject", @"") stringByAppendingString:@": "];
            conversationTitleLabel.text = listing.title;
            [recipientPrefixLabel sizeToFit];
            [recipientLabel sizeToFit];
            [conversationTitlePrefixLabel sizeToFit];
            recipientLabel.x = recipientPrefixLabel.x+recipientPrefixLabel.width;
            conversationTitleLabel.x = conversationTitlePrefixLabel.x+conversationTitlePrefixLabel.width;
        } else {
            conversationTitleLabel.text = listing.title;
        }
    }
    conversationTitleLabel.height = [conversationTitleLabel.text sizeWithFont:conversationTitleLabel.font constrainedToSize:CGSizeMake(conversationTitleLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    
    if (listing != nil || conversation.listingId != 0) {
        
        if (inModalComposerMode) {
            messagesView.y = conversationTitleLabel.y+conversationTitleLabel.height+10;
        } else {
            showListingButton.hidden = NO;
            showListingButton.height = conversationTitleLabel.height+20;
            messagesView.y = conversationTitleLabel.y+conversationTitleLabel.height+20;
        }
        
    } else {
        
        if (conversation != nil) {
            messagesView.y = conversationTitleLabel.y+conversationTitleLabel.height+10;
        } else {
            conversationTitleLabel.hidden = YES;
            conversationTitleField.hidden = NO;
            messagesView.alwaysShowFullSizeComposeField = YES;
            messagesView.y = conversationTitleField.y+conversationTitleField.height+10;
        }
    }
        
    if (inModalComposerMode) {
        
        self.title = NSLocalizedString(@"composer.message.title", @"");;
        
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
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.shadowOffset = CGSizeMake(0, -1);
        titleLabel.backgroundColor = [UIColor clearColor];
        [titleLabel sizeToFit];
        self.navigationItem.titleView = titleLabel;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.profile", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showRecipientProfile)];
        
        messagesView.x = 10;
        messagesView.width = 300;
    }
        
    messagesView.messages = conversation.messages;
    
    int contentHeight = messagesView.y+messagesView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    conversationTitleField.placeholder = NSLocalizedString(@"placeholder.conversation_title", @"");
    messagesView.composeFieldPlaceholder = (conversation != nil) ? NSLocalizedString(@"placeholder.reply", @"") : NSLocalizedString(@"placeholder.message", @"");
    
    [[SharetribeAPIClient sharedClient] getMessagesForConversation:conversation];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonPressed
{
    [self messagesView:messagesView didSaveMessageText:messagesView.composeField.text];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.conversation = notification.object;
    messagesView.messages = conversation.messages;
    // TODO 1) prevent losing field focus if already typing a reply, 2) take care of content height
}

- (void)gotListing:(NSNotification *)notification
{
    Listing *theListing = notification.object;
    if (conversation.listingId == theListing.listingId) {
        conversation.listing = theListing;
    }
}

#pragma mark - MessagesViewDelegate

- (void)messagesViewDidBeginEditing:(MessagesView *)theMessagesView
{
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 416-216;
    // self.view.backgroundColor = kSharetribeBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = messagesView.y+messagesView.height+((inModalComposerMode) ? 0 : 10);
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    int scrollY = (conversation.messages.count > 0) ? (messagesView.y+messagesView.composeField.y-10) : 0;
    [scrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];
}

- (void)messagesViewDidChange:(MessagesView *)theMessagesView
{
    int scrollY = (conversation.messages.count > 0) ? (messagesView.y+messagesView.composeField.y-10) : 0;
    [scrollView setContentOffset:CGPointMake(0, scrollY) animated:YES];
}

- (void)messagesViewDidEndEditing:(MessagesView *)theMessagesView
{    
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 460-2*44-5;
    // self.view.backgroundColor = kSharetribeLightBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = messagesView.y+messagesView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (void)messagesView:(MessagesView *)theMessagesView didSaveMessageText:(NSString *)messageText
{
    User *currentUser = [User currentUser];
    Message *message = [Message messageWithAuthor:currentUser content:messageText createdAt:[NSDate date]];
    
    if (conversation == nil) {
        ConversationStatus status = (isDirectReplyToListing) ? ConversationStatusPending : ConversationStatusFree;
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
    if (conversation.messages.count > 0) {
        return 416-216;
    } else {
        return 416-216-messagesView.y;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [messagesView.composeField becomeFirstResponder];
    return YES;
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
