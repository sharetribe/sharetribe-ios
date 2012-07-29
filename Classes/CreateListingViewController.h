//
//  CreateListingViewController.h
//  Kassi
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Listing.h"
#import "FormItem.h"
#import "CreateListingHeaderView.h"
#import "LocationPickerViewController.h"

@interface CreateListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, ListingTypeSelectionDelegate, LocationPickerDelegate> {
    
    NSInteger rowSpacing;
}

@property (strong, nonatomic) Listing *listing;
@property (strong, nonatomic) NSArray *formItems;

@property (strong, nonatomic) UITableView *table;
@property (strong, nonatomic) CreateListingHeaderView *header;
@property (strong, nonatomic) UIView *footer;

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIView *uploadTitleView;
@property (strong, nonatomic) UILabel *uploadProgressLabel;
@property (strong, nonatomic) UIProgressView *uploadProgressView;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (strong, nonatomic) UIView *activeTextInput;
@property (strong, nonatomic) FormItem *formItemBeingEdited;

- (void)reloadFormItems;

@end
