//
//  NewListingViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 4/20/13.
//
//

#import "NewListingViewController.h"

#import "Listing.h"


@interface Category : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *choices;
@property (strong, nonatomic) NSString *mapsTo;

+ (Category *)categoryWithName:(NSString *)name choices:(NSArray *)choices;
+ (Category *)categoryWithName:(NSString *)name choices:(NSArray *)choices mapsTo:(NSString *)mapsTo;

@end


@interface HeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end


@interface ChoiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *container;
@end


@interface NewListingViewController ()

@property (strong, nonatomic) Listing *listing;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableArray *detailItems;
@property (assign, nonatomic) BOOL allCategoriesFilled;

@property (strong, nonatomic) NSDictionary *iconsByItem;

@end

@implementation NewListingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listing = [[Listing alloc] init];
    self.categories = [NSMutableArray array];
    self.categories[0] = [Category categoryWithName:@"listing_type" choices:self.categoriesTree.allKeys mapsTo:@"type"];
    
    NSData *iconsByItemData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icons-by-item" ofType:@"json"]];
    self.iconsByItem = [NSJSONSerialization JSONObjectWithData:iconsByItemData options:0 error:nil];
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.categories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == (self.categories.count - 1) && !self.allCategoriesFilled) {
        return [self.categories[section] choices].count + 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Category *category = self.categories[indexPath.section];
    
    if ([self isHeaderRowAtIndexPath:indexPath]) {
        
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        
        NSString *key;
        if ([category.name isEqualToString:@"listing_type"]) {
            key = @"listing.new.listing_type.intro";
        } else if ([category.name isEqualToString:@"category"]) {
            key = [NSString stringWithFormat:@"listing.new.%@_category.intro",  self.listing.type];
        } else if ([category.name isEqualToString:@"share_type"]) {
            key = [NSString stringWithFormat:@"listing.new.%@_share_type.intro",  self.listing.type];
        } else {
            key = [NSString stringWithFormat:@"listing.new.%@_subcategory.intro",  self.listing.category];
        }
        cell.titleLabel.text = NSLocalizedString(key, nil);
        
        return cell;
        
    } else {
        
        ChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"];
        
        NSString *value;
        if (indexPath.section == self.categories.count - 1 && !self.allCategoriesFilled) {
            value = category.choices[indexPath.row - 1];
            cell.titleLabel.text = self.classifications[value][@"description"];
            cell.container.backgroundColor = [UIColor whiteColor];
        } else {
            value = [self.listing valueForKey:category.mapsTo];
            NSString *categoryTitleKey = [NSString stringWithFormat:@"listing.new.%@.title", category.name];
            NSString *categoryTitle = NSLocalizedString(categoryTitleKey, nil);
            NSString *valueTitle = [self.classifications[value][@"translated_name"] capitalizedString];
            cell.titleLabel.text = [NSString stringWithFormat:@"%@: %@", categoryTitle, valueTitle];
            cell.container.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        }
        [cell.iconLabel setIconWithName:self.iconsByItem[value]];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)isHeaderRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ((indexPath.section == (self.categories.count - 1)) && (indexPath.row == 0) && !self.allCategoriesFilled);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHeaderRowAtIndexPath:indexPath]) {
        return 44;
    } else {
        return [[tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"] height];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHeaderRowAtIndexPath:indexPath]) {
        return;  // tap on the header of the active choice
    }
    
    Category *category = self.categories[indexPath.section];
    
    NSInteger selectedChoiceIndex = [category.choices indexOfObject:[self.listing valueForKey:category.mapsTo]];
    if (selectedChoiceIndex == NSNotFound) {
        selectedChoiceIndex = indexPath.row - 1;
    }
    
    NSMutableArray *otherRows = [NSMutableArray array];
    for (int i = 0; i < category.choices.count + 1; i++) {
        if (i != selectedChoiceIndex + 1) {
            [otherRows addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
        }
    }
    
    if (indexPath.row > 0) {  // so it is a new choice
        
        [self.listing setValue:category.choices[indexPath.row - 1] forKey:category.mapsTo];
        
        if (indexPath.section == 0) {
            self.categories[self.categories.count] = [Category categoryWithName:@"category" choices:[self.categoriesTree[self.listing.type] allKeys]];
        } else {
            NSDictionary *additionalCategories = self.categoriesTree[self.listing.type][self.listing.category];
            if (indexPath.section == 1 && additionalCategories[@"subcategory"]) {
                self.categories[self.categories.count] = [Category categoryWithName:@"subcategory" choices:additionalCategories[@"subcategory"]];
            } else if (additionalCategories[@"share_type"] && self.categories.count < additionalCategories.count + 2) {
                self.categories[self.categories.count] = [Category categoryWithName:@"share_type" choices:additionalCategories[@"share_type"] mapsTo:@"shareType"];
            } else {
                self.allCategoriesFilled = YES;
            }
        }
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView deleteRowsAtIndexPaths:otherRows withRowAnimation:UITableViewRowAnimationMiddle];
        if (!self.allCategoriesFilled) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.categories.count - 1] withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.categories.count - 1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } else {  // so it is reactivation of an old choice
        
        [self.listing setValue:nil forKey:category.mapsTo];
        
        NSIndexSet *sectionsToRemove = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.section + 1, self.categories.count - indexPath.section - 1)];
        for (int i = self.categories.count - 1; i > indexPath.section; i--) {
            Category *categoryToRemove = self.categories[i];
            [self.listing setValue:nil forKey:categoryToRemove.mapsTo];
            [self.categories removeObjectAtIndex:i];
        }
        
        self.allCategoriesFilled = NO;
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView deleteSections:sectionsToRemove withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView insertRowsAtIndexPaths:otherRows withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableView endUpdates];
    }
}

@end


@implementation Category

+ (Category *)categoryWithName:(NSString *)name choices:(NSArray *)choices
{
    return [Category categoryWithName:name choices:choices mapsTo:name];
}

+ (Category *)categoryWithName:(NSString *)name choices:(NSArray *)choices mapsTo:(NSString *)mapsTo
{
    Category *category = [[Category alloc] init];
    category.name = name;
    category.choices = choices;
    category.mapsTo = mapsTo;
    return category;
}

@end


@implementation HeaderCell
@end


@implementation ChoiceCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.textColor = kSharetribeDarkOrangeColor;
    self.iconLabel.textColor = kSharetribeDarkOrangeColor;
    [self.container setShadowWithOpacity:0.5 radius:1];
}
@end