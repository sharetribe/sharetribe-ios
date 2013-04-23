//
//  FeedbackListViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 8/20/12.
//
//

#import "FeedbackListViewController.h"

#import "Feedback.h"
#import "FeedbackListCell.h"
#import "NSArray+Sharetribe.h"

@interface FeedbackListViewController ()

@end

@implementation FeedbackListViewController

@synthesize feedbacks;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"profile.feedback", @"");
    
    self.tableView.backgroundColor = kSharetribeBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return feedbacks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedbackListCell *cell = [tableView dequeueReusableCellWithIdentifier:FeedbackListCell.reuseIdentifier];
    
    if (cell == nil) {
        cell = [FeedbackListCell newInstance];
    }
    
    Feedback *feedback = [feedbacks objectOrNilAtIndex:indexPath.row];
    cell.feedback = feedback;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feedback *feedback = [feedbacks objectOrNilAtIndex:indexPath.row];
    return [FeedbackListCell heightWithFeedback:feedback];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
