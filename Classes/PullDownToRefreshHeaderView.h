//
//  PullDownToRefreshHeaderView.h
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import <UIKit/UIKit.h>

@interface PullDownToRefreshHeaderView : UIView

@property (strong) UILabel *updateIntroLabel;
@property (strong) UILabel *updateTimeLabel;
@property (strong) UIActivityIndicatorView *updateSpinner;

- (void)tableViewDidScroll:(UITableView *)tableView;
- (BOOL)triggersRefreshAsTableViewEndsDragging:(UITableView *)tableView;
- (void)updateFinishedWithTableView:(UITableView *)tableView;

@end
