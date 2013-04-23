//
//  PullDownToRefreshHeaderView.m
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import "PullDownToRefreshHeaderView.h"

#define kHeight 60

@interface PullDownToRefreshHeaderView ()
@end

@implementation PullDownToRefreshHeaderView

@synthesize updateIntroLabel;
@synthesize updateTimeLabel;
@synthesize updateSpinner;
@synthesize updateProgressView;
@synthesize searchBar;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 0)];
    if (self) {
        self.updateIntroLabel = [[UILabel alloc] init];
        updateIntroLabel.frame = CGRectMake(20, -54, 280, 30);
        updateIntroLabel.font = [UIFont boldSystemFontOfSize:13];
        updateIntroLabel.text = NSLocalizedString(@"header.pull_down_to_update", @"");
        updateIntroLabel.textColor = [UIColor whiteColor];
        updateIntroLabel.backgroundColor = [UIColor clearColor];
        updateIntroLabel.textAlignment = NSTextAlignmentCenter;
        // updateIntroLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        updateIntroLabel.alpha = 0.8;
        
        self.updateTimeLabel = [[UILabel alloc] init];
        updateTimeLabel.frame = CGRectMake(20, -36, 280, 30);
        updateTimeLabel.font = [UIFont systemFontOfSize:12];
        updateTimeLabel.textColor = [UIColor whiteColor];
        updateTimeLabel.backgroundColor = [UIColor clearColor];
        updateTimeLabel.textAlignment = NSTextAlignmentCenter;
        // updateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        updateTimeLabel.alpha = 0.8;
        
        self.updateSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        updateSpinner.frame = CGRectMake(26, -40, 20, 20);
        updateSpinner.hidesWhenStopped = NO;
        // updateSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        self.updateProgressView = [[UIProgressView alloc] init];
        updateProgressView.frame = CGRectMake(60, -24, 200, 9);
        updateProgressView.alpha = 0;
        
        UIView *headerBackground = [[UIView alloc] init];
        headerBackground.frame = CGRectMake(0, -460, 320, 460);
        headerBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        headerBackground.backgroundColor = kSharetribeThemeColor;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:headerBackground];
        [self addSubview:updateIntroLabel];
        [self addSubview:updateTimeLabel];
        [self addSubview:updateSpinner];
        [self addSubview:updateProgressView];
    }
    return self;
}

- (void)setSearchBar:(UISearchBar *)theSearchBar
{
    searchBar = theSearchBar;
    
    [self addSubview:searchBar];
    self.height = searchBar.height;
}

- (void)tableViewDidScroll:(UITableView *)tableView
{
    if (!updateSpinner.isAnimating) {
        if (tableView.contentOffset.y < -kHeight) {
            updateIntroLabel.text = NSLocalizedString(@"header.release_to_update", @"");
            updateSpinner.alpha = 1;
        } else if (tableView.contentOffset.y < 0) {
            updateIntroLabel.text = NSLocalizedString(@"header.pull_down_to_update", @"");
            updateSpinner.alpha = 0.3;
        }
    }
}

- (BOOL)triggersRefreshAsTableViewEndsDragging:(UITableView *)tableView
{
    if (tableView.contentOffset.y < -kHeight) {
        
        [self startIndicatingRefreshWithTableView:tableView];
        
        return YES;
    } else {
        return NO;
    }
}

- (void)startIndicatingRefreshWithTableView:(UITableView *)tableView
{
    updateIntroLabel.text = NSLocalizedString(@"header.updating", @"");
    updateProgressView.progress = 0;
    updateSpinner.alpha = 1;
    [updateSpinner startAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    tableView.contentInset = UIEdgeInsetsMake(kHeight, 0, 0, 0);
    updateTimeLabel.alpha = 0;
    updateProgressView.alpha = 0.7;
    [UIView commitAnimations];
}

- (void)updateFinishedWithTableView:(UITableView *)tableView
{
    updateIntroLabel.text = NSLocalizedString(@"header.updated", @"");
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy  HH:mm";
    updateTimeLabel.text = [NSString stringWithFormat:@"%@:  %@", NSLocalizedString(@"header.last_updated", @""),  [formatter stringFromDate:[NSDate date]]];
    
    [updateSpinner stopAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    updateSpinner.alpha = 0;
    updateTimeLabel.alpha = 1;
    updateProgressView.alpha = 0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDuration:0.3];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

@end
