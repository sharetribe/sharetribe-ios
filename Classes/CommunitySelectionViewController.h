//
//  CommunitySelectionViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 7/29/12.
//
//

#import <UIKit/UIKit.h>

@interface CommunitySelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong) IBOutlet UITableView *tableView;

@end
