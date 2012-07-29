//
//  MessagesListViewController.m
//  Kassi
//
//  Created by Janne Käki on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationListViewController.h"

#import "Conversation.h"
#import "ConversationListCell.h"
#import "ConversationViewController.h"
#import "Message.h"
#import "SharetribeAPIClient.h"
#import "User.h"

@implementation ConversationListViewController

@synthesize conversations;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.conversations = [NSMutableArray array];
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessagePosted:) name:kNotificationForPostingNewMessage object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.conversations = nil;
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Messages";
    
    self.tableView.backgroundColor = kKassiLightBrownColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotConversations:) name:kNotificationForDidReceiveConversations object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotUser:) name:kNotificationForDidReceiveUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postedMessage:) name:kNotificationForDidPostMessage object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SharetribeAPIClient sharedClient] getConversations];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)gotConversations:(NSNotification *)notification
{
    self.conversations = notification.object;    
    [self.tableView reloadData];
}

- (void)gotUser:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)postedMessage:(NSNotification *)notification
{
    Conversation *conversation = notification.object;
    NSInteger conversationIndex = [conversations indexOfObject:conversation];
    if (conversationIndex == NSNotFound) {
        [conversations addObject:conversation];
    } else {
        // If the thread is present (as another instance) but doesn't have the new message yet, let's add it:
        // TODO think this through again!
        Message *newMessage = conversation.messages.lastObject;
        Conversation *existingConversation = [conversations objectAtIndex:conversationIndex];
        if (![newMessage isEqual:existingConversation.messages.lastObject]) {
            existingConversation.messages = [existingConversation.messages arrayByAddingObject:newMessage];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessagesListCell";
    
    ConversationListCell *cell = (ConversationListCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ConversationListCell instance];
    }
    
    cell.conversation = [conversations objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [conversations removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kConversationListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConversationViewController *threadViewer = [[ConversationViewController alloc] init];
    threadViewer.conversation = [conversations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:threadViewer animated:YES];
}

@end
