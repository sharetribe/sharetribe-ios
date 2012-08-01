//
//  PullDownToRefreshHeaderView.m
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import "PullDownToRefreshHeaderView.h"

@interface PullDownToRefreshHeaderView ()
@end

@implementation PullDownToRefreshHeaderView

@synthesize updateIntroLabel;
@synthesize updateTimeLabel;
@synthesize updateSpinner;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 0)];
    if (self) {
        self.updateIntroLabel = [[UILabel alloc] init];
        updateIntroLabel.frame = CGRectMake(20, -54, 280, 30);
        updateIntroLabel.font = [UIFont boldSystemFontOfSize:13];
        updateIntroLabel.text = @"Pull down to update...";
        updateIntroLabel.textColor = [UIColor whiteColor];
        updateIntroLabel.backgroundColor = [UIColor clearColor];
        updateIntroLabel.textAlignment = UITextAlignmentCenter;
        updateIntroLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        updateIntroLabel.alpha = 0.8;
        
        self.updateTimeLabel = [[UILabel alloc] init];
        updateTimeLabel.frame = CGRectMake(20, -36, 280, 30);
        updateTimeLabel.font = [UIFont systemFontOfSize:12];
        updateTimeLabel.textColor = [UIColor whiteColor];
        updateTimeLabel.backgroundColor = [UIColor clearColor];
        updateTimeLabel.textAlignment = UITextAlignmentCenter;
        updateTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        updateTimeLabel.alpha = 0.8;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd.MM.yyyy  HH:mm";
        updateTimeLabel.text = [NSString stringWithFormat:@"Last updated:  %@", [formatter stringFromDate:[NSDate date]]];
        
        self.updateSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        updateSpinner.frame = CGRectMake(26, -40, 20, 20);
        updateSpinner.hidesWhenStopped = NO;
        updateSpinner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        UIView *headerBackground = [[UIView alloc] init];
        headerBackground.frame = CGRectMake(0, -460, 320, 460);
        headerBackground.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        headerBackground.backgroundColor = kSharetribeDarkOrangeColor;
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:headerBackground];
        [self addSubview:updateIntroLabel];
        [self addSubview:updateTimeLabel];
        [self addSubview:updateSpinner];
    }
    return self;
}

- (void)tableViewDidScroll:(UITableView *)tableView
{
    if (!updateSpinner.isAnimating) {
        if (tableView.contentOffset.y < -60) {
            updateIntroLabel.text = @"Release to update...";
            updateSpinner.alpha = 1;
        } else if (tableView.contentOffset.y < 0) {
            updateIntroLabel.text = @"Pull down to update...";
            updateSpinner.alpha = 0.3;
        }
    }
}
    
- (BOOL)triggersRefreshAsTableViewEndsDragging:(UITableView *)tableView
{
    if (tableView.contentOffset.y < -60) {
        
        [self startIndicatingRefreshWithTableView:tableView];
        
        return YES;
    } else {
        return NO;
    }
}

- (void)startIndicatingRefreshWithTableView:(UITableView *)tableView
{
    updateIntroLabel.text = @"Updating...";
    updateSpinner.alpha = 1;
    [updateSpinner startAnimating];
        
    [UIView beginAnimations:nil context:NULL];
    tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    [UIView commitAnimations];
}

- (void)updateFinishedWithTableView:(UITableView *)tableView
{
    updateIntroLabel.text = @"Updated!";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy  HH:mm";
    updateTimeLabel.text = [NSString stringWithFormat:@"Last updated:  %@", [formatter stringFromDate:[NSDate date]]];
    
    [updateSpinner stopAnimating];
    
    [UIView beginAnimations:nil context:NULL];
    updateSpinner.alpha = 0;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.5];
    [UIView setAnimationDuration:0.3];
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [UIView commitAnimations];
}

@end
