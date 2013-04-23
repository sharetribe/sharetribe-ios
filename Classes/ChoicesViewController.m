//
//  ChoicesViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/24/13.
//  Copyright (c) 2013 Janne Käki. All rights reserved.
//

#import "ChoicesViewController.h"

#import "PopoverView.h"

@interface ChoicesViewController () <UIPopoverControllerDelegate, PopoverViewDelegate>

@property (copy, nonatomic) void (^onChoice)(id);

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) PopoverView *popoverView;

@end

@implementation ChoicesViewController

- (id)initWithChoices:(NSArray *)choices
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.choices = choices;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.isMultipleChoice && self.selectedValues == nil) {
        self.selectedValues = [NSMutableArray array];
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)presentAsPopoverFromButton:(UIButton *)button onChoice:(void (^)(id choice))onChoice
{
    [self presentAsPopoverFromRect:button.frame inView:button.superview permittedArrowDirections:(UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown) onChoice:onChoice];
}

- (void)presentAsPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections onChoice:(void (^)(id))onChoice
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        self.contentSizeForViewInPopover = CGSizeMake([self popoverWidth], 44 * self.choices.count);
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:YES];
        
    } else {
        
        self.view.frame = (CGRect) { { 0, 0 }, { 120, 44 * self.choices.count - 1 } };
        self.popoverView = [PopoverView showPopoverAtPoint:CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height - 44) inView:view withContentView:self.view delegate:self];
    }
        
    self.onChoice = onChoice;
}

- (CGFloat)popoverWidth
{
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    int maxChoiceWidth = 0;
    for (id choice in self.choices) {
        NSLog(@"%@", [choice description]);
        int width = [[choice description] sizeWithFont:font].width;
        if (width > maxChoiceWidth) {
            maxChoiceWidth = width;
        }
    }
    return maxChoiceWidth + 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.choices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    id choice = self.choices[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", choice];
    
    if (self.isMultipleChoice) {
        cell.accessoryType = ([self.selectedValues containsObject:choice] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMultipleChoice) {
        
        id choice = self.choices[indexPath.row];
        if ([self.selectedValues containsObject:choice]) {
            [self.selectedValues removeObject:choice];
        } else {
            [self.selectedValues addObject:choice];
        }
        [self.tableView reloadData];
        self.onChoice(self.selectedValues);
        
    } else {
        
        self.onChoice(self.choices[indexPath.row]);
        [self.popover dismissPopoverAnimated:YES];
        [self.popoverView dismiss:YES];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (self.isMultipleChoice) {
        self.onChoice(self.selectedValues);
    } else {
        self.onChoice(nil);  // meant to signal: nothing changed
    }
}

@end
