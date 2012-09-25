//
//  PullDownToRefreshHeaderView.h
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import <UIKit/UIKit.h>

@interface PullDownToRefreshHeaderView : UIView

@property (strong, nonatomic) UILabel *updateIntroLabel;
@property (strong, nonatomic) UILabel *updateTimeLabel;
@property (strong, nonatomic) UIActivityIndicatorView *updateSpinner;
@property (strong, nonatomic) UIProgressView *updateProgressView;
@property (strong, nonatomic) UISearchBar *searchBar;

- (void)tableViewDidScroll:(UITableView *)tableView;
- (BOOL)triggersRefreshAsTableViewEndsDragging:(UITableView *)tableView;
- (void)updateFinishedWithTableView:(UITableView *)tableView;

- (void)startIndicatingRefreshWithTableView:(UITableView *)tableView;

@end
