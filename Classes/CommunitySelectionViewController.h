//
//  CommunitySelectionViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 7/29/12.
//
//

#import <UIKit/UIKit.h>

@interface CommunitySelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
