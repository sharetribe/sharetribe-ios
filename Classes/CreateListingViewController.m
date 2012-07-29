//
//  CreateListingViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateListingViewController.h"

#import "Location.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateListingViewController () {
    BOOL convertingImage;
    BOOL submissionWaitingForImage;
}
- (void)dismissDatePicker;
@end

@interface CustomTextField : UITextField
@end

@implementation CreateListingViewController

@synthesize listing;
@synthesize formItems;

@synthesize table;
@synthesize header;
@synthesize footer;

@synthesize submitButton;
@synthesize cancelButton;
@synthesize uploadTitleView;
@synthesize uploadProgressLabel;
@synthesize uploadProgressView;

@synthesize datePicker;

@synthesize activeTextInput;
@synthesize formItemBeingEdited;

- (id)init
{
    self = [super init];
    if (self) {
                
        self.view.backgroundColor = kSharetribeBrownColor;
                
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStylePlain];
        table.dataSource = self;
        table.delegate = self;
        table.backgroundColor = [UIColor clearColor];
        table.separatorColor = kSharetribeBrownColor;
        
        self.header = [CreateListingHeaderView instance];
        header.delegate = self;
        table.tableHeaderView = header;
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame = CGRectMake(10, 24, 300, 40);
        submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [submitButton setTitle:@"Post" forState:UIControlStateNormal];
        [submitButton setBackgroundImage:[[UIImage imageNamed:@"dark-brown.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [submitButton addTarget:self action:@selector(postButtonPressed:) forControlEvents:UIControlEventTouchUpInside],
        
        self.footer = [[UIView alloc] init];
        footer.frame = CGRectMake(0, 0, 320, 110);
        footer.backgroundColor = kSharetribeBrownColor;
        [footer addSubview:submitButton];
        
        [self.view addSubview:table];
        
        self.datePicker = [[UIDatePicker alloc] init];
        datePicker.frame = CGRectMake(0, 416, 320, 216);
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:datePicker];
        
        rowSpacing = 18;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadDidProgress:) name:kNotificationForUploadDidProgress object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostListing:) name:kNotificationForDidPostListing object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (listing == nil) {
        
        self.listing = [[Listing alloc] init];
        listing.type = ListingTypeOffer;
        
        Location *currentLocation = [Location currentLocation];
        if (currentLocation != nil) {
            listing.location = [currentLocation copy];
            listing.destination = [currentLocation copy];
        } else {
            listing.location = [[Location alloc] initWithLatitude:60.156714 longitude:24.883003 address:@"Siellähän se"];
            listing.destination = [[Location alloc] initWithLatitude:60.156714 longitude:24.883003 address:@"Sinnehän mä"];
        }
        
        [table setContentOffset:CGPointZero animated:NO];
        
        [header setListingType:listing.type];
        [header setListingCategory:kNoListingCategory];
        
        self.navigationItem.titleView = nil;
        
        convertingImage = NO;
        submissionWaitingForImage = NO;
    }
        
    self.title = NSLocalizedString(@"Tabs.NewListing", @"");
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.navigationController.navigationBar.tintColor = kSharetribeDarkBrownColor;
    
    [table reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)uploadDidProgress:(NSNotification *)notification
{
    uploadProgressView.progress = [notification.object floatValue];
}

- (void)didPostListing:(NSNotification *)notification
{    
    self.listing = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Listing was posted successully" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)reloadFormItems
{
    NSString *typeName = [Listing stringFromType:listing.type];
    NSString *categoryName = [Listing stringFromCategory:listing.category];
    NSString *propertyListName = [NSString stringWithFormat:@"form-%@-%@", categoryName, typeName];
    self.formItems = [FormItem formItemsFromDataArray:[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:propertyListName ofType:@"plist"]]];
    
    [table reloadData];
    
    table.tableFooterView = footer;
}

- (void)cancel
{
    self.listing = nil;
    self.formItems = nil;
    table.tableFooterView = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

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

#define kMaxAlternativeCount    10

#define kCellMapViewTag         1500

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return formItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormItem *formItem = [formItems objectAtIndex:indexPath.row];
    NSInteger rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:formItem.typeAsString];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:formItem.typeAsString];
        cell.contentView.backgroundColor = kSharetribeBrownColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(10, 0, 300, 20);
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = kCellTitleLabelTag;
        [cell addSubview:titleLabel];

        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.frame = CGRectMake(10, 3, 300, 16);
        subtitleLabel.font = [UIFont boldSystemFontOfSize:12];
        subtitleLabel.textAlignment = UITextAlignmentLeft;
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.tag = kCellSubtitleLabelTag;
        [cell addSubview:subtitleLabel];
        
        UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *helpButtonTitle = @"What's this?";
        [helpButton setTitle:helpButtonTitle forState:UIControlStateNormal];
        [helpButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [helpButton setTitleShadowColor:kSharetribeLightBrownColor forState:UIControlStateNormal];
        helpButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        helpButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        helpButton.width = [helpButtonTitle sizeWithFont:helpButton.titleLabel.font].width;
        helpButton.x = 320 - 10 - helpButton.width;
        helpButton.y = 0;
        helpButton.height = 24;
        helpButton.tag = kCellHelpButtonTag;
        [helpButton addTarget:self action:@selector(showItemHelp:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:helpButton];
        
        if (formItem.type == FormItemTypeTextField) {
            
            UITextField *textField = [[CustomTextField alloc] init];
            textField.font = [UIFont systemFontOfSize:15];
            textField.tag = kCellTextFieldTag;
            textField.backgroundColor = kSharetribeLightBrownColor;
            textField.keyboardAppearance = UIKeyboardAppearanceAlert;
            textField.returnKeyType = UIReturnKeyDone;
            textField.autocapitalizationType = formItem.autocapitalizationType;
            textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            textField.delegate = self;
            [cell addSubview:textField];
            
        } else if (formItem.type == FormItemTypeTextArea) {
            
            UITextView *textView = [[UITextView alloc] init];
            textView.font = [UIFont systemFontOfSize:15];
            textView.tag = kCellTextViewTag;
            textView.backgroundColor = kSharetribeLightBrownColor;
            textView.keyboardAppearance = UIKeyboardAppearanceAlert;
            textView.autocapitalizationType = formItem.autocapitalizationType;
            textView.delegate = self;
            [cell addSubview:textView];
            
        } else if (formItem.type == FormItemTypePhoto) {
            
            UIImageView *photoView = [[UIImageView alloc] init];
            photoView.tag = kCellPhotoViewTag;
            [cell addSubview:photoView];
            
            UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [photoButton setTitleColor:kSharetribeDarkBrownColor forState:UIControlStateNormal];
            [photoButton setTitleColor:kSharetribeBrownColor forState:UIControlStateHighlighted];
            [photoButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            photoButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            photoButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
            photoButton.tag = kCellPhotoButtonTag;
            [photoButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:photoButton];
            
        } else if (formItem.type == FormItemTypeLocation) {
            
            MKMapView *mapView = [[MKMapView alloc] init];
            mapView.mapType = MKMapTypeStandard;
            mapView.delegate = self;
            mapView.userInteractionEnabled = NO;
            mapView.showsUserLocation = NO;
            mapView.layer.borderWidth = 1;
            mapView.layer.borderColor = kSharetribeLightBrownColor.CGColor;
            mapView.layer.cornerRadius = 8;
            mapView.alpha = 1;
            mapView.tag = kCellMapViewTag;
            mapView.frame = CGRectMake(10, 30, 300, rowHeight-30-rowSpacing);
            [cell addSubview:mapView];
            
            UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
            mapButton.frame = mapView.frame;
            [mapButton addTarget:self action:@selector(mapPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:mapButton];
            
            Location *location = [listing valueForKey:formItem.mapsTo];
            if (location != nil) {
                [mapView addAnnotation:location];
            }
        }
    }
    
    UILabel *titleLabel = (UILabel *) [cell viewWithTag:kCellTitleLabelTag];
    titleLabel.text = formItem.title;
    if (formItem.mandatory) {
        titleLabel.text = [NSString stringWithFormat:@"%@*", titleLabel.text];
    }
    
    UILabel *subtitleLabel = (UILabel *) [cell viewWithTag:kCellSubtitleLabelTag];
    subtitleLabel.text = formItem.subtitle;
    subtitleLabel.x = titleLabel.x + [titleLabel.text sizeWithFont:titleLabel.font].width + 5;
    
    UIButton *helpButton = (UIButton *) [cell viewWithTag:kCellHelpButtonTag];
    helpButton.hidden = (formItem.whatIsThis == nil);

    if (formItem.type == FormItemTypeTextField) {
        
        UITextField *textField = (UITextField *) [cell viewWithTag:kCellTextFieldTag];
        textField.frame = CGRectMake(10, 30, 300, 36);
        textField.text = [listing valueForKey:formItem.mapsTo];
        
    } else if (formItem.type == FormItemTypeTextArea) {
        
        UITextView *textView = (UITextView *) [cell viewWithTag:kCellTextViewTag];
        textView.frame = CGRectMake(10, 30, 300, rowHeight-32-rowSpacing);
        textView.text = [listing valueForKey:formItem.mapsTo];
        
    } else if (formItem.type == FormItemTypeChoice || formItem.type == FormItemTypeDate) {
        
        id chosenAlternative = [listing valueForKey:formItem.mapsTo];
        
        if (formItem.type == FormItemTypeChoice) {
            
            if (chosenAlternative == nil) {
                chosenAlternative = [formItem.alternatives objectAtIndex:0];
                [listing setValue:chosenAlternative forKey:formItem.mapsTo];
            }
            
        } else if (formItem.type == FormItemTypeDate) {
            
            NSString *datestamp = [listing valueForKey:formItem.mapsTo];
            if (datestamp == nil || [datestamp isEqualToString:formItem.defaultAlternative]) {
                chosenAlternative = formItem.defaultAlternative;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat =  (formItem.includeTime) ? kDateAndTimeFormat : kDateFormat;
                datestamp = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:formItem.defaultTimeIntervalInDays*24*60*60]];
                [listing setValue:datestamp forKey:formItem.mapsTo];
            } else {
                chosenAlternative = datestamp;
            }
            
            if (formItem.defaultAlternative != nil) {
                if (formItem.alternatives == nil) {
                    formItem.alternatives = [NSArray arrayWithObjects:formItem.defaultAlternative, datestamp, nil];
                }
            } else {
                formItem.alternatives = [NSArray arrayWithObject:datestamp];
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
                    choiceView.frame = CGRectMake(10, 30+45*i, 300, 40);
                    choiceView.layer.cornerRadius = 8;
                    choiceView.tag = kCellChoiceViewTagBase+i;
                    [cell addSubview:choiceView];
                    
                    UILabel *choiceLabel = [[UILabel alloc] init];
                    choiceLabel.frame = CGRectMake(42, 0, 220, 40);
                    choiceLabel.font = [UIFont boldSystemFontOfSize:15];
                    choiceLabel.backgroundColor = [UIColor clearColor];
                    choiceLabel.tag = kChoiceCellLabelTag;
                    [choiceView addSubview:choiceLabel];
                    
                    UIImageView *choiceCheckmark = [[UIImageView alloc] init];
                    choiceCheckmark.frame = CGRectMake(15, 14, 15, 12);
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
                choiceLabel.text = alternative;
                choiceLabel.textColor = [UIColor blackColor];
                if (formItem.type == FormItemTypeDate && ![alternative isEqualToString:formItem.defaultAlternative]) {
                    choiceLabel.textColor = kSharetribeDarkBrownColor;
                }
                
                UIImageView *choiceCheckmark = (UIImageView *) [choiceView viewWithTag:kChoiceCellCheckmarkTag];
                
                if (formItem.type == FormItemTypeDate && formItem.alternatives.count == 1) {
                    choiceCheckmark.image = nil;
                    choiceLabel.x = 16; 
                } else {
                    choiceCheckmark.image = [UIImage imageNamed:@"checkmark"];
                    choiceLabel.x = 42;
                }
                
                [UIView beginAnimations:nil context:NULL];
                if ([chosenAlternative isEqual:choiceLabel.text] || choiceCheckmark.image == nil) {
                    choiceView.backgroundColor = kSharetribeLightBrownColor;
                    choiceCheckmark.alpha = 1;
                } else {
                    choiceView.backgroundColor = kSharetribeLightishBrownColor;
                    choiceCheckmark.alpha = 0;
                }
                
                [UIView commitAnimations];
            }
        }
    
    } else if (formItem.type == FormItemTypePhoto) {
        
        UIImageView *photoView = (UIImageView *) [cell viewWithTag:kCellPhotoViewTag];
        UIButton *photoButton = (UIButton *) [cell viewWithTag:kCellPhotoButtonTag];
        
        if (listing.image != nil) {
            
            if (photoView.image != listing.image) {
                photoView.image = listing.image;
                photoView.backgroundColor = [UIColor clearColor];
                CGFloat photoWidth = photoView.image.size.width;
                CGFloat photoHeight = photoView.image.size.height;
                if (photoWidth >= photoHeight) {
                    photoView.x = 10;
                    photoView.width = 300;
                } else {
                    photoView.x = 50;
                    photoView.width = 220;
                }
                photoView.y = 30;
                photoView.height = photoView.width * (photoHeight/photoWidth);
            }
            [photoButton setTitle:nil forState:UIControlStateNormal];
            
            photoView.layer.cornerRadius = 0;
            photoView.layer.borderColor = kSharetribeDarkBrownColor.CGColor;
            photoView.layer.borderWidth = 1;
            
        } else {
            
            photoView.image = nil;
            photoView.backgroundColor = kSharetribeLightBrownColor;
            photoView.frame = CGRectMake(10, 30, 300, rowHeight-30-rowSpacing);
            [photoButton setTitle:@"Add an image..." forState:UIControlStateNormal];
            
            photoView.layer.cornerRadius = 8;            
            photoView.layer.borderColor = [UIColor clearColor].CGColor;
            photoView.layer.borderWidth = 0;
        }
        
        photoButton.frame = photoView.frame;
        
    } else if (formItem.type == FormItemTypeLocation) {
        
        MKMapView *mapView = (MKMapView *) [cell viewWithTag:kCellMapViewTag];
        
        [mapView removeAnnotations:mapView.annotations];
        
        Location *location = [listing valueForKey:formItem.mapsTo];
        if (location != nil) {
            [mapView addAnnotation:location];
        }
        
        if (mapView.centerCoordinate.latitude != location.coordinate.latitude ||
            mapView.centerCoordinate.longitude != location.coordinate.longitude) {
            
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 4000) animated:NO];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormItem *formItem = [formItems objectAtIndex:indexPath.row];
    NSInteger rowHeight = 0;
    
    if (formItem.type == FormItemTypeTextField) {
        
        rowHeight = 70;
        
    } else if (formItem.type == FormItemTypeTextArea) {
    
        rowHeight = 175;
        
    } else if (formItem.type == FormItemTypePhoto) {
        
        if (listing.image != nil) {
            CGFloat photoWidth = listing.image.size.width;
            CGFloat photoHeight = listing.image.size.height;
            int photoViewWidth = (photoWidth >= photoHeight) ? 300 : 220;
            rowHeight = 30 + photoViewWidth * (photoHeight/photoWidth);
        } else {
            rowHeight = 100;
        }
        
    } else if (formItem.type == FormItemTypeChoice) {
        
        rowHeight = 30 + formItem.alternatives.count*45;
    
    } else if (formItem.type == FormItemTypeLocation) {
        
        rowHeight = 175;
    
    } else if (formItem.type == FormItemTypeDate) {
        
        rowHeight = 30 + 45;
        if (formItem.defaultAlternative != nil) {
            rowHeight += 45;
        }
    }
    
    return rowHeight + rowSpacing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (activeTextInput != nil) {
        [activeTextInput resignFirstResponder];
    }
    
    if (datePicker.y < 416) {
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
    table.height = 416-216;
    [UIView commitAnimations];
    
    NSIndexPath *path = [table indexPathForRowAtPoint:[table convertPoint:CGPointZero fromView:textInputView]];
    [table scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:textInputView action:@selector(resignFirstResponder)];
}

- (void)textInputViewDidEndEditing:(UIView *)textInputView
{
    if (textInputView == activeTextInput) {
        self.activeTextInput = nil;
        table.height = 416;
        
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    NSIndexPath *path = [table indexPathForRowAtPoint:[table convertPoint:CGPointZero fromView:textInputView]];
    FormItem *formItem = [formItems objectAtIndex:path.row];
    [listing setValue:[(id) textInputView text] forKey:formItem.mapsTo];
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
            imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    listing.image = image;
    [table reloadData];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
    }
    
    [self performSelectorInBackground:@selector(convertImageToData) withObject:nil];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)convertImageToData
{
    convertingImage = YES;
    listing.imageData = UIImageJPEGRepresentation(listing.image, 0.9);
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

#pragma mark - ListingTypeSelectionDelegate

- (void)listingTypeSelected:(ListingType)type
{
    listing.type = type;
    [self reloadFormItems];
}

- (void)listingCategorySelected:(ListingCategory)category
{
    listing.category = category;
    [self reloadFormItems];
}

#pragma mark - LocationPickerDelegate

- (void)locationPicker:(LocationPickerViewController *)picker pickedCoordinate:(CLLocationCoordinate2D)coordinate
{
    Location *location = [[Location alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude address:@""];
    [listing setValue:location forKey:formItemBeingEdited.mapsTo];
    [table reloadData];
}

- (void)locationPickedDidCancel:(LocationPickerViewController *)picker
{
}

#pragma mark -

- (IBAction)showItemHelp:(UIButton *)sender
{
    NSIndexPath *path = [table indexPathForRowAtPoint:[table convertPoint:CGPointZero fromView:sender]];    
    FormItem *formItem = [formItems objectAtIndex:path.row];
    NSString *itemHelp = formItem.whatIsThis;
    itemHelp = [itemHelp stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:formItem.title message:itemHelp delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)photoButtonPressed:(UIButton *)sender
{
    UIActionSheet *actionSheetForAddingPhoto = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a New Photo...", @"Choose from Library...", nil];
    actionSheetForAddingPhoto.tag = kActionSheetTagForAddingPhoto;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheetForAddingPhoto showInView:self.view];
    } else {
        [self actionSheet:actionSheetForAddingPhoto clickedButtonAtIndex:1];
    }
}

- (IBAction)choiceButtonPressed:(UIButton *)sender
{
    NSIndexPath *path = [table indexPathForRowAtPoint:[table convertPoint:CGPointZero fromView:sender]];    
    FormItem *formItem = [formItems objectAtIndex:path.row];
    id value = [formItem.alternatives objectAtIndex:sender.tag];
    
    if (formItem.type == FormItemTypeDate && ![value isEqual:formItem.defaultAlternative]) {
        
        datePicker.minimumDate = [NSDate date];
        datePicker.datePickerMode = (formItem.includeTime) ? UIDatePickerModeDateAndTime : UIDatePickerModeDate;
        datePicker.minuteInterval = 10;
        NSString *currentChoice = [listing valueForKey:formItem.mapsTo];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = (formItem.includeTime) ? kDateAndTimeFormat : kDateFormat;
        if (currentChoice == nil) {
            currentChoice = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:formItem.defaultTimeIntervalInDays*24*60*60]];
        } else if ([currentChoice isEqualToString:formItem.defaultAlternative]) {
            currentChoice = [formItem.alternatives objectAtIndex:formItem.alternatives.count-1];
        }
        datePicker.date = [formatter dateFromString:currentChoice];
        
        [UIView beginAnimations:nil context:NULL];
        datePicker.frame = CGRectMake(0, 416-datePicker.height, datePicker.width, datePicker.height);
        table.frame = CGRectMake(0, 0, table.width, 416-datePicker.height);
        [UIView commitAnimations];
        
        [table scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissDatePicker)];
        
        self.formItemBeingEdited = formItem;
        
    } else {
        
        if (datePicker.y < 416) {
            [self dismissDatePicker];
        }
    }
    
    [listing setValue:value forKey:formItem.mapsTo];
    [table reloadData];
}

- (IBAction)postButtonPressed:(UIButton *)sender
{
    if (uploadTitleView == nil) {
        self.uploadTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
        self.uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
        uploadProgressLabel.font = [UIFont boldSystemFontOfSize:13];
        uploadProgressLabel.textColor = [UIColor whiteColor];
        uploadProgressLabel.shadowColor = [UIColor darkTextColor];
        uploadProgressLabel.shadowOffset = CGSizeMake(0, 1);
        uploadProgressLabel.backgroundColor = [UIColor clearColor];
        uploadProgressLabel.textAlignment = UITextAlignmentCenter;
        self.uploadProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 22, 160, 9)];
        [uploadTitleView addSubview:uploadProgressLabel];
        [uploadTitleView addSubview:uploadProgressView];
    }
    uploadProgressLabel.text = @"Posting...";
    uploadProgressView.progress = 0;
    self.navigationItem.titleView = uploadTitleView;
    
    if (convertingImage) {
        submissionWaitingForImage = YES;
        return;
    }
    
    listing.author = [User currentUser];
    listing.createdAt = [NSDate date];
    
    [[SharetribeAPIClient sharedClient] postNewListing:listing];    
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender
{
    if (listing.title != nil || listing.description != nil || listing.image != nil) {
        
        UIAlertView *alertViewForCanceling = [[UIAlertView alloc] initWithTitle:@"Cancel" message:@"Are you sure you want to cancel?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertViewForCanceling.tag = kAlertViewTagForCanceling;
        [alertViewForCanceling show];
        
    } else {
        
        [self cancel];
    }
}

- (IBAction)mapPressed:(UIButton *)sender
{
    NSIndexPath *path = [table indexPathForRowAtPoint:[table convertPoint:CGPointZero fromView:sender]];    
    FormItem *formItem = [formItems objectAtIndex:path.row];
    CLLocation *location = [listing valueForKey:formItem.mapsTo];
    
    self.formItemBeingEdited = formItem;
    
    LocationPickerViewController *locationPicker = [[LocationPickerViewController alloc] init];
    locationPicker.delegate = self;
    locationPicker.coordinate = location.coordinate;
    [self.navigationController pushViewController:locationPicker animated:YES];
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)picker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = (formItemBeingEdited.includeTime) ? kDateAndTimeFormat : kDateFormat;
    NSString *datestamp = [formatter stringFromDate:picker.date];
    [listing setValue:datestamp forKey:formItemBeingEdited.mapsTo];
    if (formItemBeingEdited.defaultAlternative != nil) {
        formItemBeingEdited.alternatives = [NSArray arrayWithObjects:formItemBeingEdited.defaultAlternative, datestamp, nil];
    }
    [table reloadData];
}

- (void)dismissDatePicker
{
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    [UIView beginAnimations:nil context:NULL];
    datePicker.frame = CGRectMake(0, 416, datePicker.width, datePicker.height);
    table.frame = CGRectMake(0, 0, table.width, 416);
    [UIView commitAnimations];
}

@end

@implementation CustomTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 8, 6);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 8, 6);
}

@end
