//
//  NewListingViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 4/20/13.
//
//

#import "NewListingViewController.h"

#import "AppDelegate.h"
#import "ChoicesViewController.h"
#import "FormItem.h"
#import "Location.h"
#import "User.h"

#import "SharetribeAPIClient.h"


#define kCellTitleLabelTag      1000
#define kCellSubtitleLabelTag   1001
#define kCellHelpButtonTag      1002

#define kCellTextFieldTag       1101
#define kCellTextViewTag        1102

#define kCellPhotoViewTag       1200
#define kCellPhotoButtonTag     1201

#define kCellChoiceViewTagBase  1300
#define kChoiceCellLabelTag     3000
#define kChoiceCellCheckmarkTag 3001

#define kCellPriceFieldTag      4000
#define kCellCurrencyButtonTag  4001
#define kCellQuantityLabelTag   4002
#define kCellQuantityFieldTag   4003

#define kMaxAlternativeCount    10

#define kCellMapViewTag         1500


@interface ListingCategory : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *choices;
@property (strong, nonatomic) NSString *mapsTo;

+ (ListingCategory *)categoryWithName:(NSString *)name choices:(NSArray *)choices;
+ (ListingCategory *)categoryWithName:(NSString *)name choices:(NSArray *)choices mapsTo:(NSString *)mapsTo;

@end


@interface HeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end


@interface ChoiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *container;
@end


@interface SpinnerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end


@interface NewListingViewController () {
    BOOL convertingImage;
    BOOL submissionWaitingForImage;
    BOOL preserveFormItemsOnNextAppearance;
    NSInteger rowSpacing;
    BOOL readyToShowNewestCategory;
}

@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSArray *formItems;
@property (assign, nonatomic) BOOL allCategoriesFilled;

@property (strong, nonatomic) UIView *footer;

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIView *uploadTitleView;
@property (strong, nonatomic) UILabel *uploadProgressLabel;
@property (strong, nonatomic) UIProgressView *uploadProgressView;
@property (strong, nonatomic) UIActivityIndicatorView *uploadSpinner;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) ChoicesViewController *currencyChooser;

@property (strong, nonatomic) UIView *activeTextInput;
@property (strong, nonatomic) FormItem *formItemBeingEdited;

- (void)reloadFormItems;


@end

@implementation NewListingViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20)];
    
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.frame = CGRectMake(20, 24, 280, 40);
    self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.submitButton setTitle:NSLocalizedString(@"button.post", @"") forState:UIControlStateNormal];
    [self.submitButton setBackgroundImage:[[UIImage imageWithColor:kSharetribeSecondaryThemeColor] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    [self.submitButton setShadowWithOpacity:0.5 radius:1];
    [self.submitButton addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside],
    
    self.uploadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.uploadSpinner.frame = CGRectMake((self.submitButton.width - self.uploadSpinner.width) / 2, 10, self.uploadSpinner.width, self.uploadSpinner.height);
    self.uploadSpinner.hidesWhenStopped = YES;
    [self.submitButton addSubview:self.uploadSpinner];
    
    self.footer = [[UIView alloc] init];
    self.footer.frame = CGRectMake(0, 0, 320, 110);
    [self.footer addSubview:self.submitButton];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.frame = CGRectMake(0, self.view.height, 320, 216);
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    
    rowSpacing = 18;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDidProgress:) name:kNotificationForUploadDidProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostListing:) name:kNotificationForDidPostListing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailToPostListing:) name:kNotificationForFailedToPostListing object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    readyToShowNewestCategory = YES;
    
    [self reloadData];
    
    self.tableView.scrollsToTop = YES;
    
    if (!preserveFormItemsOnNextAppearance) {
        
        self.categories = [NSMutableArray array];
        self.categories[0] = [ListingCategory categoryWithName:@"listing_type" choices:self.categoriesTree.allKeys mapsTo:@"type"];
        
        if (self.listing == nil) {
            
            // So, creating a brand new listing:
            self.listing = [[Listing alloc] init];
            self.listing.type = kListingTypeOffer;
            
            User *currentUser = [User currentUser];
            Location *location;
            
            if (currentUser.location != nil) {
                location = currentUser.location;
            } else if ([Location currentLocation] != nil) {
                location = [Location currentLocation];
            } else {
                location = [[Location alloc] initWithLatitude:60.156714 longitude:24.883003 address:nil];  // OBS! maybe the community's default location instead?
            }
            
            self.listing.location = [location copy];
            self.listing.destination = [location copy];
            
            [self.tableView setContentOffset:CGPointZero animated:NO];
            
            self.navigationItem.titleView = nil;
            
            convertingImage = NO;
            submissionWaitingForImage = NO;
            
            self.submitButton.enabled = YES;
            [self.submitButton setTitle:NSLocalizedString(@"button.post", @"") forState:UIControlStateNormal];
            [self.uploadSpinner stopAnimating];
            
            self.title = NSLocalizedString(@"tabs.new_listing", @"");
                        
        } else {
            
            // So, editing an existing listing:
            
            self.categories[1] = [ListingCategory categoryWithName:@"category" choices:[self.categoriesTree[self.listing.type] allKeys]];
            NSDictionary *additionalCategories = self.categoriesTree[self.listing.type][self.listing.category];
            if (additionalCategories[@"subcategory"]) {
                self.categories[self.categories.count] = [ListingCategory categoryWithName:@"subcategory" choices:additionalCategories[@"subcategory"]];
            }
            if (additionalCategories[@"share_type"]) {
                self.categories[self.categories.count] = [ListingCategory categoryWithName:@"share_type" choices:additionalCategories[@"share_type"] mapsTo:@"shareType"];
            }
            self.allCategoriesFilled = YES;
            self.tableView.tableFooterView = self.footer;
            
            [self reloadFormItems];
            
            self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 30)];
            
            self.title = NSLocalizedString(@"title.edit_listing", @"");
        }
        
        [self.tableView reloadData];
        
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        
        self.navigationController.navigationBar.tintColor = [AppDelegate sharedAppDelegate].community.color1;
    }
    
    preserveFormItemsOnNextAppearance = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tableView.scrollsToTop = NO;
    
    [super viewWillDisappear:animated];
}

- (void)reloadData
{
    Community *community = [AppDelegate sharedAppDelegate].community;
    self.categoriesTree = community.categoriesTree;
    self.classifications = community.classifications;
    [self.tableView reloadData];
}

- (void)uploadDidProgress:(NSNotification *)notification
{
    id progress = notification.object;
    if ([progress respondsToSelector:@selector(floatValue)]) {
        self.uploadProgressView.progress = [progress floatValue];
    }
}

- (void)didPostListing:(NSNotification *)notification
{
    [self cancel];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.listing.posted", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"button.ok", @"") otherButtonTitles:nil];
    [alert show];
}

- (void)didFailToPostListing:(NSNotification *)notification
{
    self.submitButton.enabled = YES;
    [self.submitButton setTitle:NSLocalizedString(@"button.post", @"") forState:UIControlStateNormal];
    [self.uploadSpinner stopAnimating];
    
    self.navigationItem.titleView = nil;
    
    NSMutableString *message = [NSMutableString stringWithString:NSLocalizedString(@"alert.listing.failed_to_post", @"")];
    if ([notification.object isKindOfClass:NSArray.class]) {
        for (id object in notification.object) {
            [message appendFormat:@"\n\n%@", object];
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.error", @"") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"button.ok", @"") otherButtonTitles:nil];
    [alert show];
}

- (void)reloadFormItems
{
    NSString *category = self.listing.category;
    if ([category isEqual:@"accommodation"] || [category isEqual:@"space"]) {
        category = @"housing";
    } else if ([category isEqual:@"mealsharing"] || [category isEqual:@"activities"] || [category isEqual:@"service"]) {
        category = @"favor";
    }
    NSString *propertyListName = [NSString stringWithFormat:@"form-%@-%@", category, self.listing.type];
    propertyListName = [propertyListName stringByReplacingOccurrencesOfString:@"other" withString:@"item"];
    NSMutableArray *formItems = [[FormItem formItemsFromDataArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:propertyListName ofType:@"plist"]]] mutableCopy];
    if ([self.classifications[self.listing.shareType][@"price"] boolValue]) {
        FormItem *priceItem = [[FormItem alloc] init];
        priceItem.type = FormItemTypePrice;
        priceItem.typeAsString = @"price";
        priceItem.formItemId = @"price";
        priceItem.mapsTo = @"priceDict";
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        values[@"priceInCents"] = @(0);
        values[@"priceCurrency"] = @"EUR";
        if ([NSString cast:self.classifications[self.listing.shareType][@"price_quantity_placeholder"]]) {
            values[@"priceQuantity"] = @"";
        }
        [self.listing setValue:values forKey:priceItem.mapsTo];
        [formItems insertObject:priceItem atIndex:1];
    }
    self.formItems = formItems;
    
    self.submitButton.hidden = (self.listing.category == nil);
}

- (void)cancel
{
    self.listing = nil;
    self.categories = nil;
    self.formItems = nil;
    self.allCategoriesFilled = NO;
    self.tableView.tableFooterView = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.categoriesTree == nil || self.classifications == nil) {
        return 1;
    } else if (self.allCategoriesFilled && readyToShowNewestCategory) {
        return self.categories.count + 1;
    } else if (self.allCategoriesFilled || readyToShowNewestCategory) {
        return self.categories.count;
    } else {
        return (self.categories.count > 0) ? (self.categories.count - 1) : 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.categoriesTree == nil || self.classifications == nil) {
        return 1;
    } else if (section == (self.categories.count - 1) && !self.allCategoriesFilled) {
        return [self.categories[section] choices].count + 1;
    } else if (section < self.categories.count) {
        return 1;
    } else {
        return self.formItems.count;
    }
}

- (NSString *)localizedTitleForCategoryInSection:(NSInteger)section
{
    ListingCategory *category = self.categories[section];
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
    return NSLocalizedString(key, nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.categoriesTree == nil || self.classifications == nil) {
        
        SpinnerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SpinnerCell"];
        [cell.spinner startAnimating];
        return cell;
        
    } else if ([self isHeaderRowAtIndexPath:indexPath]) {
        
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        cell.titleLabel.text = [self localizedTitleForCategoryInSection:indexPath.section];
        cell.titleLabel.height = [cell.titleLabel.text sizeWithFont:cell.titleLabel.font constrainedToSize:CGSizeMake(cell.titleLabel.width, 1000) lineBreakMode:NSLineBreakByWordWrapping].height;
        
        return cell;
        
    } else if (indexPath.section < self.categories.count) {
        
        ChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"];
        ListingCategory *category = self.categories[indexPath.section];
        
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
            cell.titleLabel.text = [NSString stringWithFormat:@"%@: %@", categoryTitle, (value) ? valueTitle : @"—"];
            cell.container.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        }
        [cell.iconLabel setIconWithName:[Listing iconNameForItem:value]];
        
        return cell;
        
    } else {
        
        FormItem *formItem = self.formItems[indexPath.row];
        NSInteger rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:formItem.typeAsString];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:formItem.typeAsString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.frame = CGRectMake(20, 0, 280, 20);
            titleLabel.font = [UIFont boldSystemFontOfSize:15];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.tag = kCellTitleLabelTag;
            [cell addSubview:titleLabel];
            
            UILabel *subtitleLabel = [[UILabel alloc] init];
            subtitleLabel.frame = CGRectMake(20, 3, 280, 16);
            subtitleLabel.font = [UIFont boldSystemFontOfSize:12];
            subtitleLabel.textAlignment = NSTextAlignmentLeft;
            subtitleLabel.backgroundColor = [UIColor clearColor];
            subtitleLabel.tag = kCellSubtitleLabelTag;
            [cell addSubview:subtitleLabel];
                        
            UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
            NSString *helpButtonTitle = NSLocalizedString(@"listing.explanation", @"");
            [helpButton setTitle:helpButtonTitle forState:UIControlStateNormal];
            [helpButton setTitleColor:kSharetribeThemeColor forState:UIControlStateNormal];
            [helpButton setTitleShadowColor:kSharetribeBackgroundColor forState:UIControlStateNormal];
            helpButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            helpButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
            helpButton.width = [helpButtonTitle sizeWithFont:helpButton.titleLabel.font].width;
            helpButton.x = 320 - 20 - helpButton.width;
            helpButton.y = 0;
            helpButton.height = 24;
            helpButton.tag = kCellHelpButtonTag;
            [helpButton addTarget:self action:@selector(showItemHelp:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:helpButton];
            
            if (formItem.type == FormItemTypeTextField) {
                
                UITextField *textField = [[UITextField alloc] init];
                textField.font = [UIFont systemFontOfSize:15];
                textField.tag = kCellTextFieldTag;
                textField.backgroundColor = kSharetribeBackgroundColor;
                textField.keyboardAppearance = UIKeyboardAppearanceAlert;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.returnKeyType = UIReturnKeyDone;
                textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textField.delegate = self;
                [cell addSubview:textField];
                
            } else if (formItem.type == FormItemTypeTextArea) {
                
                UITextField *textFieldForTheLooks = [[UITextField alloc] init];
                textFieldForTheLooks.tag = kCellTextFieldTag;
                textFieldForTheLooks.borderStyle = UITextBorderStyleRoundedRect;
                textFieldForTheLooks.userInteractionEnabled = NO;
                [cell addSubview:textFieldForTheLooks];
                
                UITextView *textView = [[UITextView alloc] init];
                textView.font = [UIFont systemFontOfSize:15];
                textView.backgroundColor = [UIColor clearColor];
                textView.tag = kCellTextViewTag;
                textView.keyboardAppearance = UIKeyboardAppearanceAlert;
                [textView setShadowWithOpacity:0.5 radius:1];
                textView.delegate = self;
                [cell addSubview:textView];
                
            } else if (formItem.type == FormItemTypePhoto) {
                
                UIImageView *photoView = [[UIImageView alloc] init];
                photoView.tag = kCellPhotoViewTag;
                [cell addSubview:photoView];
                
                UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [photoButton setTitleColor:kSharetribeThemeColor forState:UIControlStateNormal];
                [photoButton setTitleColor:[kSharetribeThemeColor colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
                [photoButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                // [photoButton setShadowWithOpacity:0.5 radius:1];
                photoButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                photoButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
                photoButton.tag = kCellPhotoButtonTag;
                [photoButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:photoButton];
                
            } else if (formItem.type == FormItemTypeLocation) {
                
                UITextField *textField = [[UITextField alloc] init];
                textField.placeholder = NSLocalizedString(@"placeholder.address", @"");
                textField.frame = CGRectMake(20, 30, 280, 40);
                textField.font = [UIFont systemFontOfSize:15];
                textField.tag = kCellTextFieldTag;
                textField.backgroundColor = kSharetribeBackgroundColor;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.keyboardAppearance = UIKeyboardAppearanceAlert;
                textField.returnKeyType = UIReturnKeyDone;
                textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                textField.delegate = self;
                [cell addSubview:textField];
                
                MKMapView *mapView = [[MKMapView alloc] init];
                mapView.mapType = MKMapTypeStandard;
                mapView.delegate = self;
                mapView.userInteractionEnabled = NO;
                mapView.showsUserLocation = NO;
                mapView.layer.borderWidth = 1;
                mapView.layer.borderColor = kSharetribeBackgroundColor.CGColor;
                mapView.layer.cornerRadius = 8;
                mapView.alpha = 1;
                mapView.tag = kCellMapViewTag;
                mapView.frame = CGRectMake(20, 80, 280, rowHeight-80-rowSpacing);
                [cell addSubview:mapView];
                
                UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
                mapButton.frame = mapView.frame;
                [mapButton addTarget:self action:@selector(mapPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:mapButton];
                
                //            Location *location = [self.listing valueForKey:formItem.mapsTo];
                //            if (location != nil) {
                //                textField.text = location.address;
                //                [mapView addAnnotation:location];
                //            }
                
            } else if (formItem.type == FormItemTypePrice) {
                
                UITextField *priceField = [[UITextField alloc] init];
                priceField.placeholder = @"0";
                priceField.frame = CGRectMake(20, 30, 60, 40);
                priceField.font = [UIFont systemFontOfSize:15];
                priceField.tag = kCellPriceFieldTag;
                priceField.borderStyle = UITextBorderStyleRoundedRect;
                priceField.keyboardType = UIKeyboardTypeDecimalPad;
                priceField.keyboardAppearance = UIKeyboardAppearanceAlert;
                priceField.returnKeyType = UIReturnKeyDone;
                priceField.textAlignment = NSTextAlignmentRight;
                priceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                priceField.delegate = self;
                [cell addSubview:priceField];
                
                // NSArray *currencies = [AppDelegate sharedAppDelegate].community.availableCurrencies;
                UIButton *currencyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                currencyButton.frame = CGRectMake(priceField.right + 10, priceField.y, 60, priceField.height);
                [currencyButton setTitle:@"EUR" forState:UIControlStateNormal];
                [currencyButton addTarget:self action:@selector(currencyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:currencyButton];
                
                UILabel *quantityLabel = [[UILabel alloc] init];
                quantityLabel.font = [UIFont systemFontOfSize:13];
                quantityLabel.text = NSLocalizedString(@"listing.price.quantity.label", nil);
                [quantityLabel sizeToFit];
                quantityLabel.frame = CGRectMake(currencyButton.right + 10, priceField.y, quantityLabel.width, priceField.height);
                quantityLabel.tag = kCellQuantityLabelTag;
                [cell addSubview:quantityLabel];
                
                UITextField *quantityField = [[UITextField alloc] init];
                quantityField.frame = CGRectMake(quantityLabel.right + 10, quantityLabel.y, 0, quantityLabel.height);
                quantityField.width = cell.width - quantityField.x - 20;
                quantityField.font = [UIFont systemFontOfSize:15];
                quantityField.tag = kCellQuantityFieldTag;
                quantityField.borderStyle = UITextBorderStyleRoundedRect;
                quantityField.keyboardType = UIKeyboardTypeAlphabet;
                quantityField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                quantityField.keyboardAppearance = UIKeyboardAppearanceAlert;
                quantityField.returnKeyType = UIReturnKeyDone;
                quantityField.textAlignment = NSTextAlignmentLeft;
                quantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                quantityField.delegate = self;
                [cell addSubview:quantityField];
            }
        }
        
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:kCellTitleLabelTag];
        titleLabel.text = formItem.localizedTitle;
        if (formItem.mandatory) {
            titleLabel.text = [NSString stringWithFormat:@"%@*", titleLabel.text];
        }
        
        UILabel *subtitleLabel = (UILabel *) [cell viewWithTag:kCellSubtitleLabelTag];
        subtitleLabel.text = (formItem.subtitleKey != nil) ? formItem.localizedSubtitle : nil;
        subtitleLabel.x = titleLabel.x + [titleLabel.text sizeWithFont:titleLabel.font].width + 5;
        
        UIButton *helpButton = (UIButton *) [cell viewWithTag:kCellHelpButtonTag];
        helpButton.hidden = !(formItem.providesExplanation);
        
        if (formItem.type == FormItemTypeTextField) {
            
            UITextField *textField = (UITextField *) [cell viewWithTag:kCellTextFieldTag];
            textField.frame = CGRectMake(20, 30, 280, 40);
            id value = [self.listing valueForKey:formItem.mapsTo];
            if ([value isKindOfClass:NSArray.class] && formItem.listSeparator != nil) {
                value = [value componentsJoinedByString:formItem.listSeparator];
            }
            textField.text = value;
            textField.autocapitalizationType = formItem.autocapitalizationType;
            
        } else if (formItem.type == FormItemTypeTextArea) {
            
            UITextView *textView = (UITextView *) [cell viewWithTag:kCellTextViewTag];
            textView.frame = CGRectMake(20, 30, 280, rowHeight-32-rowSpacing);
            textView.text = [self.listing valueForKey:formItem.mapsTo];
            textView.autocapitalizationType = formItem.autocapitalizationType;
            
            UITextField *textFieldForLooks = (UITextField *) [cell viewWithTag:kCellTextFieldTag];
            textFieldForLooks.frame = textView.frame;
            
        } else if (formItem.type == FormItemTypeChoice || formItem.type == FormItemTypeDate) {
            
            id chosenAlternative = [self.listing valueForKey:formItem.mapsTo];
            
            if (formItem.type == FormItemTypeChoice) {
                if (chosenAlternative == nil) {
                    chosenAlternative = formItem.alternatives[0];
                    [self.listing setValue:chosenAlternative forKey:formItem.mapsTo];
                }
            }
            
            for (int i = 0; i < kMaxAlternativeCount; i++) {
                UIView *choiceView = [cell viewWithTag:kCellChoiceViewTagBase+i];
                if (i >= formItem.alternatives.count) {
                    if (choiceView != nil) {
                        choiceView.hidden = YES;
                    }
                } else {
                    if (choiceView == nil) {
                        choiceView = [[UIView alloc] init];
                        choiceView.frame = CGRectMake(20, 30 + 45 * i, 280, 40);
                        choiceView.tag = kCellChoiceViewTagBase+i;
                        [cell addSubview:choiceView];
                        
                        UILabel *choiceLabel = [[UILabel alloc] init];
                        choiceLabel.frame = CGRectMake(42, 0, 236, 40);
                        choiceLabel.font = [UIFont boldSystemFontOfSize:15];
                        choiceLabel.backgroundColor = [UIColor clearColor];
                        choiceLabel.tag = kChoiceCellLabelTag;
                        [choiceView addSubview:choiceLabel];
                        
                        UIImageView *choiceCheckmark = [[UIImageView alloc] init];
                        choiceCheckmark.frame = CGRectMake(15, 14, 15, 12);
                        choiceCheckmark.contentMode = UIViewContentModeCenter;
                        choiceCheckmark.tag = kChoiceCellCheckmarkTag;
                        [choiceView addSubview:choiceCheckmark];
                        
                        UIButton *choiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        choiceButton.frame = CGRectMake(0, 0, choiceView.width, choiceView.height);
                        [choiceButton addTarget:self action:@selector(choiceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        choiceButton.tag = i;
                        [choiceView addSubview:choiceButton];
                    }
                    choiceView.hidden = NO;
                    
                    UILabel *choiceLabel = (UILabel *) [choiceView viewWithTag:kChoiceCellLabelTag];
                    id alternative = [formItem.alternatives objectAtIndex:i];
                    if (formItem.type == FormItemTypeDate && [alternative isKindOfClass:NSDate.class]) {
                        if (formItem.includeTime) {
                            choiceLabel.text = [alternative dateAndTimeString];
                        } else {
                            choiceLabel.text = [alternative dateString];
                        }
                        // we don't localize timestamps the crude way, no
                    } else {
                        choiceLabel.text = [formItem localizedTitleForAlternative:alternative];
                    }
                    choiceLabel.textColor = [UIColor blackColor];
                    if (formItem.type == FormItemTypeDate && [alternative isKindOfClass:NSDate.class]) {
                        choiceLabel.textColor = [UIColor blackColor];
                    }
                    
                    UIImageView *choiceCheckmark = (UIImageView *) [choiceView viewWithTag:kChoiceCellCheckmarkTag];
                    
                    if (formItem.type == FormItemTypeDate && formItem.alternatives.count == 1) {
                        choiceCheckmark.image = nil;
                        choiceLabel.x = 16;
                    } else {
                        choiceCheckmark.image = [UIImage imageWithIconNamed:@"check" pointSize:16 color:[UIColor whiteColor] insets:UIEdgeInsetsMake(4, 0, 0, 0)];
                        choiceLabel.x = 42;
                    }
                    
                    [UIView beginAnimations:nil context:NULL];
                    if ([chosenAlternative isEqual:alternative] ||
                        (chosenAlternative == nil && [alternative isEqual:kValidForTheTimeBeing]) ||
                        choiceCheckmark.image == nil) {
                        choiceView.backgroundColor = kSharetribeLightThemeColor;
                        choiceCheckmark.alpha = 1;
                        [choiceView setShadowWithOpacity:0 radius:0];
                    } else {
                        choiceView.backgroundColor = kSharetribeBackgroundColor;
                        choiceCheckmark.alpha = 0;
                        [choiceView setShadowWithOpacity:0.5 radius:1];
                    }
                    
                    [UIView commitAnimations];
                }
            }
            
        } else if (formItem.type == FormItemTypePhoto) {
            
            UIImageView *photoView = (UIImageView *) [cell viewWithTag:kCellPhotoViewTag];
            UIButton *photoButton = (UIButton *) [cell viewWithTag:kCellPhotoButtonTag];
            
            photoView.backgroundColor = kSharetribeBackgroundColor;
            // [photoView setShadowWithOpacity:0.7 radius:2];
            
            if (self.listing.image != nil) {
                
                if (photoView.image != self.listing.image) {
                    photoView.image = self.listing.image;
                    photoView.backgroundColor = [UIColor clearColor];
                    CGFloat photoWidth = photoView.image.size.width;
                    CGFloat photoHeight = photoView.image.size.height;
                    if (photoWidth >= photoHeight) {
                        photoView.x = 20;
                        photoView.width = 280;
                    } else {
                        photoView.x = 50;
                        photoView.width = 220;
                    }
                    photoView.y = 30;
                    photoView.height = photoView.width * (photoHeight/photoWidth);
                }
                [photoButton setTitle:nil forState:UIControlStateNormal];
                
                photoView.layer.cornerRadius = 0;
                photoView.layer.borderColor = kSharetribeThemeColor.CGColor;
                photoView.layer.borderWidth = 1;
                
            } else {
                
                photoView.image = nil;
                photoView.backgroundColor = kSharetribeBackgroundColor;
                photoView.frame = CGRectMake(20, 30, 280, rowHeight - 30 - rowSpacing);
                [photoButton setTitle:NSLocalizedString(@"listing.image.add", @"") forState:UIControlStateNormal];
                
                photoView.layer.cornerRadius = 8;
                photoView.layer.borderColor = [UIColor clearColor].CGColor;
                photoView.layer.borderWidth = 0;
            }
            
            photoButton.frame = photoView.frame;
            
        } else if (formItem.type == FormItemTypeLocation) {
            
            UITextField *textField = (UITextField *) [cell viewWithTag:kCellTextFieldTag];
            MKMapView *mapView = (MKMapView *) [cell viewWithTag:kCellMapViewTag];
            
            [mapView removeAnnotations:mapView.annotations];
            
            Location *location = [self.listing valueForKey:formItem.mapsTo];
            if (location != nil) {
                
                NSLog(@"textfield: %@, address: %@", textField, location.address);
                
                textField.text = location.address;
                
                [mapView addAnnotation:location];
                
                if (mapView.centerCoordinate.latitude != location.coordinate.latitude ||
                    mapView.centerCoordinate.longitude != location.coordinate.longitude) {
                    
                    [mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 4000) animated:NO];
                }
            }
            
        } else if (formItem.type == FormItemTypePrice) {
            
            UITextField *priceField = (UITextField *) [cell viewWithTag:kCellPriceFieldTag];
            UIButton *currencyButton = (UIButton *) [cell viewWithTag:kCellCurrencyButtonTag];
            UILabel *quantityLabel = (UILabel *) [cell viewWithTag:kCellQuantityLabelTag];
            UITextField *quantityField = (UITextField *) [cell viewWithTag:kCellQuantityFieldTag];
            
            NSDictionary *priceValues = [self.listing valueForKey:formItem.mapsTo];
            priceField.text = ([priceValues[@"priceInCents"] integerValue] > 0) ? [NSString stringWithFormat:@"%d", [priceValues[@"priceInCents"] integerValue]] : nil;
            [currencyButton setTitle:priceValues[@"priceCurrency"] forState:UIControlStateNormal];
            if (priceValues[@"priceQuantity"]) {
                quantityField.text = ([priceValues[@"priceQuantity"] length] > 0) ? priceValues[@"priceQuantity"] : nil;
                quantityLabel.hidden = NO;
                quantityField.hidden = NO;
            } else {
                quantityLabel.hidden = YES;
                quantityField.hidden = YES;
            }
            
            quantityField.placeholder = [NSString cast:self.classifications[self.listing.shareType][@"price_quantity_placeholder"]];
        }
        
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
    if (self.categoriesTree == nil || self.classifications == nil) {
        
        return [[tableView dequeueReusableCellWithIdentifier:@"SpinnerCell"] height];
        
    } else if ([self isHeaderRowAtIndexPath:indexPath]) {
        
        HeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"];
        NSString *title = [self localizedTitleForCategoryInSection:indexPath.section];
        return cell.titleLabel.y + [title sizeWithFont:cell.titleLabel.font constrainedToSize:CGSizeMake(cell.titleLabel.width, 1000) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
        
    } else if (indexPath.section < self.categories.count) {
        
        return [[tableView dequeueReusableCellWithIdentifier:@"ChoiceCell"] height];
        
    } else {
        
        FormItem *formItem = [self.formItems objectAtIndex:indexPath.row];
        NSInteger rowHeight = 0;
        
        if (formItem.type == FormItemTypeTextField) {
            
            rowHeight = 74;
            
        } else if (formItem.type == FormItemTypeTextArea) {
            
            rowHeight = 175;
            
        } else if (formItem.type == FormItemTypePhoto) {
            
            if (self.listing.image != nil && [self.listing.image isKindOfClass:UIImage.class]) {
                CGFloat photoWidth = self.listing.image.size.width;
                CGFloat photoHeight = self.listing.image.size.height;
                int photoViewWidth = (photoWidth >= photoHeight) ? 300 : 220;
                rowHeight = 30 + photoViewWidth * (photoHeight / photoWidth);
            } else {
                rowHeight = 100;
            }
            
        } else if (formItem.type == FormItemTypeChoice) {
            
            rowHeight = 30 + formItem.alternatives.count * 45;
            
        } else if (formItem.type == FormItemTypeLocation) {
            
            rowHeight = 50 + 175;
            
        } else if (formItem.type == FormItemTypeDate) {
            
            rowHeight = 30 + 45;
            if (formItem.allowsUndefined) {
                rowHeight += 45;
            }
            
        } else if (formItem.type == FormItemTypePrice) {
            
            rowHeight = 74;
        }
        
        return rowHeight + rowSpacing;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == self.categories.count) ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = NO;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHeaderRowAtIndexPath:indexPath]) {
        return;  // tap on the header of the active choice
    }
    
    if (indexPath.section >= self.categories.count) {
        return;  // tap on any of the legacy form items
    }
    
    ListingCategory *category = self.categories[indexPath.section];
    
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
            self.categories[self.categories.count] = [ListingCategory categoryWithName:@"category" choices:[self.categoriesTree[self.listing.type] allKeys]];
        } else {
            NSDictionary *additionalCategories = self.categoriesTree[self.listing.type][self.listing.category];
            if (indexPath.section == 1 && additionalCategories[@"subcategory"]) {
                self.categories[self.categories.count] = [ListingCategory categoryWithName:@"subcategory" choices:additionalCategories[@"subcategory"]];
            } else if (additionalCategories[@"share_type"] && self.categories.count < additionalCategories.count + 2) {
                self.categories[self.categories.count] = [ListingCategory categoryWithName:@"share_type" choices:additionalCategories[@"share_type"] mapsTo:@"shareType"];
            } else {
                self.allCategoriesFilled = YES;
                self.tableView.tableFooterView = self.footer;
                [self reloadFormItems];
            }
        }
        
        NSIndexSet *sectionsToInsert = [NSIndexSet indexSetWithIndex:(self.allCategoriesFilled) ? self.categories.count : (self.categories.count - 1)];
        NSLog(@"tapped: %@, sectionsToInsert: %@", indexPath, sectionsToInsert);
        
        readyToShowNewestCategory = NO;
        [CATransaction begin];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:otherRows withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [CATransaction setCompletionBlock:^{
            readyToShowNewestCategory = YES;
            [self.tableView beginUpdates];
            [self.tableView insertSections:sectionsToInsert withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }];
        [CATransaction commit];
        
        // [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(self.allCategoriesFilled) ? self.categories.count : (self.categories.count - 1)] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    } else {  // so it is reactivation of an old choice
        
        [self.listing setValue:nil forKey:category.mapsTo];
        
        NSIndexSet *sectionsToRemove = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.section + 1, self.categories.count - indexPath.section - ((self.allCategoriesFilled) ? 0 : 1))];
        for (int i = self.categories.count - 1; i > indexPath.section; i--) {
            ListingCategory *categoryToRemove = self.categories[i];
            [self.listing setValue:nil forKey:categoryToRemove.mapsTo];
            [self.categories removeObjectAtIndex:i];
        }
        
        self.allCategoriesFilled = NO;
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 20)];
        
        NSLog(@"tapped: %@, sectionsToRemove: %@", indexPath, sectionsToRemove);
        
        [CATransaction begin];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView deleteSections:sectionsToRemove withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:otherRows withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [CATransaction setCompletionBlock:^{
        }];
        [CATransaction commit];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.activeTextInput != nil) {
        [self.activeTextInput resignFirstResponder];
    }
    
    if (self.datePicker.y < self.view.height) {
        [self dismissDatePicker];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

#pragma mark - UITextFieldDelegate and UITextViewDelegate

- (void)textInputViewDidBeginEditing:(UIView *)textInputView
{
    self.activeTextInput = textInputView;
    
    [UIView beginAnimations:nil context:NULL];
    self.tableView.height = self.view.height - 216;
    [UIView commitAnimations];
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textInputView]];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.ok", @"") style:UIBarButtonItemStyleBordered target:textInputView action:@selector(resignFirstResponder)];
}

- (void)textInputViewDidEndEditing:(UIView *)textInputView
{
    if (textInputView == self.activeTextInput) {
        self.activeTextInput = nil;
        self.tableView.height = self.view.height;
        
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textInputView]];
    FormItem *formItem = [self.formItems objectAtIndex:path.row];
    if (formItem.type == FormItemTypeLocation) {
        Location *location = [self.listing valueForKey:formItem.mapsTo];
        location.address = [(id) textInputView text];
        location.addressIsAutomatic = NO;
    } else {
        id value = [(id) textInputView text];
        if (formItem.type == FormItemTypePrice) {
            NSMutableDictionary *priceValues = [self.listing valueForKey:formItem.mapsTo];
            if (textInputView.tag == kCellPriceFieldTag) {
                NSInteger priceInCents = [value doubleValue] * 100;
                priceValues[@"priceInCents"] = @(priceInCents);
            } else if (textInputView.tag == kCellQuantityFieldTag) {
                priceValues[@"priceQuantity"] = value ?: @"";
            }
            [self.listing setValue:priceValues forKey:formItem.mapsTo];
        } else {
            [self.listing setValue:value forKey:formItem.mapsTo];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self textInputViewDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self textInputViewDidEndEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self textInputViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self textInputViewDidEndEditing:textView];
}

#pragma mark - UIAlertViewDelegate

#define kAlertViewTagForCanceling      1000

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTagForCanceling) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self cancel];
        }
    }
}

#pragma mark - UIActionSheetDelegate

#define kActionSheetTagForAddingPhoto  1000

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetTagForAddingPhoto) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            if (buttonIndex == 0) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            } else {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            imagePicker.allowsEditing = NO;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
            preserveFormItemsOnNextAppearance = YES;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.listing.image = image;
    [self.tableView reloadData];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
    }
    
    [self performSelectorInBackground:@selector(convertImageToData) withObject:nil];
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)convertImageToData
{
    convertingImage = YES;
    self.listing.imageData = UIImageJPEGRepresentation(self.listing.image, 0.9);
    convertingImage = NO;
    [self performSelectorOnMainThread:@selector(imageConversionFinished) withObject:nil waitUntilDone:NO];
}

- (void)imageConversionFinished
{
    if (submissionWaitingForImage) {
        submissionWaitingForImage = NO;
        [self postButtonPressed:nil];
    }
}

#pragma mark - LocationPickerDelegate

- (void)locationPicker:(LocationPickerViewController *)picker pickedCoordinate:(CLLocationCoordinate2D)coordinate withAddress:(NSString *)address
{
    Location *location = [[Location alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude address:nil];
    
    Location *oldLocation = [self.listing valueForKey:self.formItemBeingEdited.mapsTo];
    if (oldLocation.address.length > 0 && !oldLocation.addressIsAutomatic) {
        NSLog(@"kept old address: %@", oldLocation.address);
        location.address = oldLocation.address;
    } else {
        location.address = address;
        location.addressIsAutomatic = YES;
    }
    
    [self.listing setValue:location forKey:self.formItemBeingEdited.mapsTo];
    [self.tableView reloadData];
}

- (void)locationPickedDidCancel:(LocationPickerViewController *)picker
{
}

#pragma mark -

- (IBAction)showItemHelp:(UIButton *)sender
{
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:sender]];
    FormItem *formItem = [self.formItems objectAtIndex:path.row];
    NSString *itemHelp = formItem.localizedExplanation;
    itemHelp = [itemHelp stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    itemHelp = [itemHelp gtm_stringByUnescapingFromHTML];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:formItem.localizedTitle message:itemHelp delegate:self cancelButtonTitle:NSLocalizedString(@"button.ok", @"") otherButtonTitles:nil];
    [alert show];
}

- (IBAction)photoButtonPressed:(UIButton *)sender
{
    UIActionSheet *actionSheetForAddingPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"button.cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"button.take_new_photo", @""), NSLocalizedString(@"button.choose_photo_from_library", @""), nil];
    actionSheetForAddingPhoto.tag = kActionSheetTagForAddingPhoto;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheetForAddingPhoto showInView:self.view];
    } else {
        [self actionSheet:actionSheetForAddingPhoto clickedButtonAtIndex:1];
    }
}

- (IBAction)choiceButtonPressed:(UIButton *)sender
{
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:sender]];
    FormItem *formItem = self.formItems[path.row];
    id value = formItem.alternatives[sender.tag];
    
    if (formItem.type == FormItemTypeDate) {
        
        if ([value isKindOfClass:NSDate.class]) {
            
            self.datePicker.minimumDate = [NSDate date];
            self.datePicker.datePickerMode = (formItem.includeTime) ? UIDatePickerModeDateAndTime : UIDatePickerModeDate;
            self.datePicker.minuteInterval = 10;
            self.datePicker.date = value;
            
            [UIView beginAnimations:nil context:NULL];
            self.datePicker.frame = CGRectMake(0, self.view.height - self.datePicker.height, self.datePicker.width, self.datePicker.height);
            self.tableView.frame = CGRectMake(0, 0, self.tableView.width, self.view.height - self.datePicker.height);
            [UIView commitAnimations];
            
            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"button.ok", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(dismissDatePicker)];
            
            self.formItemBeingEdited = formItem;
            
        } else {
            
            value = nil;
            if (self.datePicker.y < self.view.height) {
                [self dismissDatePicker];
            }
        }
        
    } else {
        
        if (self.datePicker.y < self.view.height) {
            [self dismissDatePicker];
        }
    }
    
    [self.listing setValue:value forKey:formItem.mapsTo];
    [self.tableView reloadData];
}

- (IBAction)currencyButtonPressed:(UIButton *)sender
{
    NSArray *currencies = [AppDelegate sharedAppDelegate].community.availableCurrencies;
    if (currencies.count > 1) {
        self.currencyChooser = [[ChoicesViewController alloc] initWithChoices:currencies];
        [self.currencyChooser presentAsPopoverFromButton:sender onChoice:^(id choice) {
            [sender setTitle:choice forState:UIControlStateNormal];
            NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:sender]];
            FormItem *formItem = self.formItems[path.row];
            NSMutableDictionary *priceValues = [self.listing valueForKey:formItem.mapsTo];
            priceValues[@"priceCurrency"] = choice;
            [self.listing setValue:priceValues forKey:formItem.mapsTo];
        }];
    }
}

- (IBAction)postButtonPressed:(UIButton *)sender
{
    if (![[SharetribeAPIClient sharedClient] hasInternetConnectivity]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.title.no_internet", @"") message:NSLocalizedString(@"alert.message.no_internet", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"button.ok", @"") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.uploadTitleView == nil) {
        self.uploadTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        self.uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
        self.uploadProgressLabel.font = [UIFont boldSystemFontOfSize:13];
        self.uploadProgressLabel.textColor = [UIColor whiteColor];
        self.uploadProgressLabel.shadowColor = [UIColor darkTextColor];
        self.uploadProgressLabel.shadowOffset = CGSizeMake(0, 1);
        self.uploadProgressLabel.backgroundColor = [UIColor clearColor];
        self.uploadProgressLabel.textAlignment = NSTextAlignmentCenter;
        self.uploadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 22, 160, 9)];
        [self.uploadTitleView addSubview:self.uploadProgressLabel];
        [self.uploadTitleView addSubview:self.uploadProgressView];
    }
    self.uploadProgressLabel.text = NSLocalizedString(@"composer.listing.posting", @"");
    self.uploadProgressView.progress = 0;
    self.navigationItem.titleView = self.uploadTitleView;
    
    if (convertingImage) {
        submissionWaitingForImage = YES;
        return;
    }
    
    self.listing.author = [User currentUser];
    self.listing.createdAt = [NSDate date];
    
    self.submitButton.enabled = NO;
    [self.submitButton setTitle:nil forState:UIControlStateNormal];
    [self.uploadSpinner startAnimating];
    
    [[SharetribeAPIClient sharedClient] postNewListing:self.listing];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender
{
    if (self.listing.title != nil || self.listing.description != nil || self.listing.image != nil) {
        
        UIAlertView *alertViewForCanceling = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"button.cancel", @"") message:NSLocalizedString(@"alert.confirm_cancel_composing_listing", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"button.no", @"") otherButtonTitles:NSLocalizedString(@"button.yes", @""), nil];
        alertViewForCanceling.tag = kAlertViewTagForCanceling;
        [alertViewForCanceling show];
        
    } else {
        
        [self cancel];
    }
}

- (IBAction)mapPressed:(UIButton *)sender
{
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:sender]];
    FormItem *formItem = [self.formItems objectAtIndex:path.row];
    CLLocation *location = [self.listing valueForKey:formItem.mapsTo];
    
    self.formItemBeingEdited = formItem;
    
    LocationPickerViewController *locationPicker = [[LocationPickerViewController alloc] init];
    locationPicker.delegate = self;
    locationPicker.coordinate = location.coordinate;
    [self.navigationController pushViewController:locationPicker animated:YES];
    preserveFormItemsOnNextAppearance = YES;
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)picker
{
    [self.listing setValue:picker.date forKey:self.formItemBeingEdited.mapsTo];
    [self.formItemBeingEdited.alternatives replaceObjectAtIndex:0 withObject:picker.date];
    [self.tableView reloadData];
}

- (void)dismissDatePicker
{
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:nil context:NULL];
    self.datePicker.frame = CGRectMake(0, self.view.height, self.datePicker.width, self.datePicker.height);
    self.tableView.frame = CGRectMake(0, 0, self.tableView.width, self.view.height);
    [UIView commitAnimations];
}

@end


@implementation ListingCategory

+ (ListingCategory *)categoryWithName:(NSString *)name choices:(NSArray *)choices
{
    return [ListingCategory categoryWithName:name choices:choices mapsTo:name];
}

+ (ListingCategory *)categoryWithName:(NSString *)name choices:(NSArray *)choices mapsTo:(NSString *)mapsTo
{
    ListingCategory *category = [[ListingCategory alloc] init];
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
    self.titleLabel.textColor = kSharetribeThemeColor;
    self.iconLabel.textColor = kSharetribeThemeColor;
    [self.container setShadowWithOpacity:0.5 radius:1];
}
@end

@implementation SpinnerCell
@end