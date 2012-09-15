//
//  MessagesListViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationListViewController.h"

#import "Conversation.h"
#import "ConversationListCell.h"
#import "ConversationViewController.h"
#import "Message.h"
#import "PullDownToRefreshHeaderView.h"
#import "SharetribeAPIClient.h"
#import "User.h"

@interface ConversationListViewController ()
@property (strong) PullDownToRefreshHeaderView *header;
@end

@implementation ConversationListViewController

@synthesize conversations;

@synthesize header;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessagePosted:) name:kNotificationForPostingNewMessage object:nil];
    }
    return self;
}

- (void)dealloc
{
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

    // self.title = NSLocalizedString(@"messaging.conversations.title", @"");
    
    self.header = [[PullDownToRefreshHeaderView alloc] init];
    self.tableView.tableHeaderView = header;
    
    self.tableView.backgroundColor = kSharetribeLightBrownColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotConversations:) name:kNotificationForDidReceiveConversations object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotUser:) name:kNotificationForDidReceiveUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postedMessage:) name:kNotificationForDidPostMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
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

- (void)refreshConversations
{
    [[SharetribeAPIClient sharedClient] getConversations];
}

- (void)gotConversations:(NSNotification *)notification
{
    self.conversations = notification.object;    
    [self.tableView reloadData];
    [header updateFinishedWithTableView:self.tableView];
    
    NSInteger unreadConversationCount = 0;
    for (Conversation *conversation in conversations) {
        if (conversation.isUnread) {
            unreadConversationCount++;
        }
    }
    if (unreadConversationCount > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unreadConversationCount];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
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
        [conversations sortUsingSelector:@selector(compare:)];
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

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self refreshConversations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (conversations.count > 0) {
        return conversations.count;
    } else if (conversations != nil) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (conversations.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = NSLocalizedString(@"messaging.no_conversations_yet", @"");
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.shadowColor = [UIColor whiteColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        return cell;
    }
    
    static NSString *CellIdentifier = @"MessagesListCell";
    
    ConversationListCell *cell = (ConversationListCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ConversationListCell instance];
    }
    
    id conversation = [conversations objectAtIndex:indexPath.row];
    if ([conversation isKindOfClass:Conversation.class]) {
        cell.conversation = conversation;
    } else {
        NSLog(@"that's no moon: %@", conversation);
        cell.conversation = nil;
    }
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [conversations removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kConversationListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (conversations.count == 0) {
        return;
    }
    
    ConversationViewController *threadViewer = [[ConversationViewController alloc] init];
    threadViewer.conversation = [conversations objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:threadViewer animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [header tableViewDidScroll:self.tableView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([header triggersRefreshAsTableViewEndsDragging:self.tableView]) {
        [self refreshConversations];
    }
}

@end
