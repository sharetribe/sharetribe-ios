//
//  ClockStampView.h
//
//  Created by Janne Käki on 6/19/12.
//

//  How do I use this thing?
//  1. Init it with a delegate which implements the three required methods.
//     - The first method will simply return the tableview. This thing will automatically be added to the tableview's superview (make sure it has one).
//     - The second method will return the time for a given index path.
//     - The third method will simply determine whether the clockstamp should be shown at all. For instance, you can hide it when the number of rows is low.
//  2. Forward all calls to the tableview's three scrollview delegate methods (listed below) to it:
//     - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
//     - (void)scrollViewDidScroll:(UIScrollView *)scrollView;
//     - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
//  3. Add the pointer-arrow images to your project (or replace them with more awesome ones).
//
//  Note: The thing assumes that you are using this epic UIView category that adds mutable properties x, y, width, and height. And they better be floats.

#import <UIKit/UIKit.h>
#import "TouchEventForwardingView.h"

@protocol ClockStampViewDelegate <NSObject>
- (UITableView *)tableView;
- (NSDate *)timeForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)clockStampViewShouldShow;
@end

@interface ClockStampView : TouchEventForwardingView {

    NSDate *time;
}

@property (unsafe_unretained, nonatomic) id<ClockStampViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (copy, nonatomic) NSDate *time;

- (id)initWithDelegate:(id<ClockStampViewDelegate>)delegate;

- (void)showForIndexPath:(NSIndexPath *)indexPath;
- (void)hide;

// Call these with the corresponding tableview scroll events:
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end
