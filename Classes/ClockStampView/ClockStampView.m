//
//  ClockStampView.m
//
//  Created by Janne Käki on 6/19/12.
//

#import "ClockStampView.h"

@interface ClockStampView () <TouchEventForwardingViewDelegate> {
    
    CGFloat initialHeightOfScrollIndicator;
    BOOL isDragging;
}

@end

@implementation ClockStampView

@synthesize delegate;

@synthesize backgroundView;
@synthesize dateLabel;
@synthesize yearLabel;

@dynamic time;

- (id)initWithDelegate:(id<ClockStampViewDelegate>)theDelegate
{
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pointer-arrow"]];
    
    self = [super initWithFrame:CGRectMake(0, 0, bgView.width, bgView.height)];
    if (self == nil) {
        return nil;
    }
    
    self.delegate = theDelegate;
    self.touchDelegate = self;  // it listens its own touches
    
    self.backgroundView = bgView;
    backgroundView.alpha = 0.6;
    
    self.dateLabel = [[UILabel alloc] init];
    dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    dateLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
    dateLabel.shadowColor = [UIColor clearColor];
    dateLabel.shadowOffset = CGSizeMake(0, -1);
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.x = 5;
    dateLabel.y = 3;
    dateLabel.width = self.width-self.dateLabel.x;
    dateLabel.height = 14;
    
    self.yearLabel = [[UILabel alloc] init];
    yearLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    yearLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    yearLabel.shadowColor = [UIColor clearColor];
    yearLabel.shadowOffset = CGSizeMake(0, -1);
    yearLabel.backgroundColor = [UIColor clearColor];
    yearLabel.x = 5;
    yearLabel.y = 14;
    yearLabel.width = self.width-self.yearLabel.x;
    yearLabel.height = 14;
    
    [self addSubview:backgroundView];
    [self addSubview:dateLabel];
    [self addSubview:yearLabel];
    
    self.x = [self activeRightX];
    self.alpha = 0;
    
    [[[delegate tableView] superview] addSubview:self];
    
    return self;
}

- (NSDate *)time
{
    return time;
}

- (void)setTime:(NSDate *)newTime
{
    if (newTime == nil || [time isEqual:newTime]) {
        return;
    }
    time = [newTime copy];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    yearLabel.text = [formatter stringFromDate:time];
    formatter.dateFormat = @"MMM dd";
    dateLabel.text = [formatter stringFromDate:time];
}

- (void)setTimeWithY:(CGFloat)y
{
    UITableView *tableView = [delegate tableView];
    NSIndexPath *indexPath = [[delegate tableView] indexPathForRowAtPoint:CGPointMake(0, tableView.contentOffset.y + y - tableView.y)];
    if (indexPath == nil) {
        if (tableView.contentOffset.y <= 0) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else if (tableView.contentOffset.y >= tableView.contentSize.height-tableView.height) {
            int lastSection = [tableView numberOfSections]-1;
            int lastRow = [tableView numberOfRowsInSection:lastSection]-1;
            indexPath = [NSIndexPath indexPathForRow:lastRow inSection:lastSection];
        }
    }
    self.time = [delegate timeForIndexPath:indexPath];
}

- (void)showForIndexPath:(NSIndexPath *)indexPath
{
    UITableView *tableView = [delegate tableView];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL clockStampShouldShow = [delegate clockStampViewShouldShow];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.x = [self activeRightX];
        self.y = cell.center.y+tableView.y-tableView.contentOffset.y-self.height/2;
        self.alpha = (clockStampShouldShow) ? 1 : 0;
    }];
    
    self.time = [delegate timeForIndexPath:indexPath];
    
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}

#pragma mark - Table view scroll events

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    UIView *scrollIndicator = [[scrollView subviews] lastObject];
    initialHeightOfScrollIndicator = scrollIndicator.height;
    
    BOOL clockStampShouldShow = [delegate clockStampViewShouldShow];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.x = [self activeRightX];
        self.alpha = (clockStampShouldShow) ? 1 : 0;
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    UIView *scrollIndicator = [[scrollView subviews] lastObject];
        
    int scrollY = scrollView.contentOffset.y / (scrollView.contentSize.height - scrollView.height) * (scrollView.height - scrollIndicator.height);
    int stampY = scrollView.y + scrollY + scrollIndicator.height / 2 - self.height / 2;
    
    self.y = stampY;
    
    [self setTimeWithY:scrollY+scrollIndicator.height/2];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!isDragging) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:1];
    }
}

#pragma mark - Clock stamp touch detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view
{
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    isDragging = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.x = [self activeLeftX];
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view
{
    UITableView *tableView = [delegate tableView];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    
    CGFloat touchY = point.y-tableView.y;
    int contentOffsetY = ((touchY - self.height/2) / tableView.height) * tableView.contentSize.height;
    if (contentOffsetY < 0) {
        contentOffsetY = 0;
        if (point.y < tableView.y) {
            point.y = tableView.y;
        }
    } else if (contentOffsetY > tableView.contentSize.height-tableView.height) {
        contentOffsetY = tableView.contentSize.height-tableView.height;
        if (point.y > tableView.y+tableView.height) {
            point.y = tableView.y+tableView.height;
        }
    }
    [tableView setContentOffset:CGPointMake(0, contentOffsetY) animated:NO];
    self.y = point.y - self.height / 2;
    [self setTimeWithY:point.y];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (point.x < (self.x + self.width) &&
            point.x < [self activeRightX]) {
            self.x = [self activeRightX];
        } else {
            self.x = [self activeLeftX];
        }
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:1];
    isDragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.x = [self activeRightX];
    }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event inView:(TouchEventForwardingView *)view
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:1];
    isDragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.x = [self activeRightX];
    }];
}

#pragma mark -

- (CGFloat)activeLeftX
{
    UITableView *tableView = [delegate tableView];
    return tableView.x + tableView.width - 2*self.width - 12;
}

- (CGFloat)activeRightX
{
    UITableView *tableView = [delegate tableView];
    return tableView.x + tableView.width - self.width - 12;
}

- (CGFloat)passiveX
{
    UITableView *tableView = [delegate tableView];
    return tableView.x + tableView.width - self.width;
}

- (void)hide
{
    [UIView animateWithDuration:0.3 animations:^{
        self.x = [self passiveX];
        self.alpha = 0;
    }];
}

@end
