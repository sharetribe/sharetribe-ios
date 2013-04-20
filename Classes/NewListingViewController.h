//
//  NewListingViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 4/20/13.
//
//

#import <UIKit/UIKit.h>

@interface NewListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSDictionary *categoriesTree;
@property (strong, nonatomic) NSDictionary *classifications;

@end

