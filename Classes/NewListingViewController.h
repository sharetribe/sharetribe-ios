//
//  NewListingViewController.h
//  Sharetribe
//
//  Created by Janne Käki on 4/20/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Listing.h"
#import "LocationPickerViewController.h"

@interface NewListingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, LocationPickerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) Listing *listing;

@property (strong, nonatomic) NSDictionary *categoriesTree;
@property (strong, nonatomic) NSDictionary *classifications;

- (void)reloadData;

@end

