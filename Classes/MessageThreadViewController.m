//
//  MessageThreadViewController.m
//  Kassi
//
//  Created by Janne Käki on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageThreadViewController.h"

#import "Message.h"

@implementation MessageThreadViewController

@synthesize scrollView;
@synthesize messagesView;

@synthesize messageThread;

@synthesize inModalComposerMode;

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
    [self.view addSubview:scrollView];
    
    self.messagesView = [[MessagesView alloc] init];
    messagesView.y = 0;
    messagesView.width = 320;
    messagesView.delegate = self;
    messagesView.sendButtonTitle = @"Send";
    messagesView.composeFieldPlaceholder = @"Write a reply";
    [scrollView addSubview:messagesView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = kKassiDarkBrownColor;
    self.view.backgroundColor = kKassiLightBrownColor;
        
    int contentHeight = messagesView.y+messagesView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    if (inModalComposerMode) {
        
        self.title = @"New Message";
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed)];
        
        self.view.backgroundColor = kKassiBrownColor;
        
        messagesView.x = 0;
        messagesView.width = 320;
        
        messagesView.showUserAvatars = NO;
        messagesView.showComposerButtons = NO;
        [messagesView.composeField becomeFirstResponder];
        
    } else {
        
        self.title = messageThread.subject;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
        
        messagesView.x = 10;
        messagesView.width = 300;
    }
    
    messagesView.messages = messageThread.messages;
    messagesView.y = 10;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

#pragma mark - MessagesViewDelegate

- (void)messagesViewDidBeginEditing:(MessagesView *)theMessagesView
{
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 416-216;
    // self.view.backgroundColor = kKassiBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = messagesView.y+messagesView.height+((inModalComposerMode) ? 0 : 10);
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    [scrollView setContentOffset:CGPointMake(0, messagesView.y+messagesView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidChange:(MessagesView *)theMessagesView
{
    [scrollView setContentOffset:CGPointMake(0, messagesView.y+messagesView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidEndEditing:(MessagesView *)theMessagesView
{    
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 460-2*44-5;
    // self.view.backgroundColor = kKassiLightBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = messagesView.y+messagesView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (void)messagesView:(MessagesView *)theMessagesView didSaveMessageText:(NSString *)messageText
{
    Message *message = [[Message alloc] init];
    message.authorId = [[User currentUser] userId];
    message.content = messageText;
    message.createdAt = [NSDate date];
    
    [messageThread.messages addObject:message];
    messagesView.messages = messageThread.messages;
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForPostingNewMessage object:messageThread];
}

@end
