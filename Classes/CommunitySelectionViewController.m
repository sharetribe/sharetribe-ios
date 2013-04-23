//
//  CommunitySelectionViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 7/29/12.
//
//

#import "CommunitySelectionViewController.h"

#import "Community.h"
#import "SharetribeAPIClient.h"
#import "User.h"

@interface CommunitySelectionViewController ()

@end

@implementation CommunitySelectionViewController

@synthesize tableView = _tableView;

- (id)init
{
    self = [super initWithNibName:@"CommunitySelectionViewController" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kSharetribeThemeColor;
    
    [self.logoView setShadowWithColor:[UIColor blackColor] opacity:0.9 radius:1 offset:CGSizeZero usingDefaultPath:NO];
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
    return [[[User currentUser] communities] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *currentUser = [User currentUser];
    Community *community = [currentUser.communities objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommunityCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CommunityCell"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    
    cell.textLabel.text = community.name;
    cell.detailTextLabel.text = [community.domain stringByAppendingString:@".sharetribe.com"];
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *currentUser = [User currentUser];
    Community *community = [currentUser.communities objectAtIndex:indexPath.row];
    
    [[SharetribeAPIClient sharedClient] setCurrentCommunityId:community.communityId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForDidSelectCommunity object:community];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
