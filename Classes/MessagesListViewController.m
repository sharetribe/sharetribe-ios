//
//  MessagesListViewController.m
//  Kassi
//
//  Created by Janne Käki on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesListViewController.h"

#import "Message.h"
#import "MessagesListCell.h"
#import "MessageThreadViewController.h"

@implementation MessagesListViewController

@synthesize messageThreads;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.messageThreads = [NSMutableArray array];
        // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessagePosted:) name:kNotificationForPostingNewMessage object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.messageThreads = nil;
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationForPostingNewMessage object:nil];
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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (void)newMessagePosted:(NSNotification *)notification
{
    MessageThread *messageThread = notification.object;
    NSInteger messageThreadIndex = [messageThreads indexOfObject:messageThread];
    if (messageThreadIndex == NSNotFound) {
        [messageThreads addObject:messageThread];
    } else {
        // If the thread is present (as another instance) but doesn't have the new message yet, let's add it: 
        Message *newMessage = messageThread.messages.lastObject;
        MessageThread *existingThread = [messageThreads objectAtIndex:messageThreadIndex];
        if (![newMessage isEqual:existingThread.messages.lastObject]) {
            [existingThread.messages addObject:newMessage];
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
    return messageThreads.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessagesListCell";
    
    MessagesListCell *cell = (MessagesListCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [MessagesListCell instance];
    }
    
    cell.messageThread = [messageThreads objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [messageThreads removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMessagesListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageThreadViewController *threadViewer = [[MessageThreadViewController alloc] init];
    threadViewer.messageThread = [messageThreads objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:threadViewer animated:YES];
}

@end
