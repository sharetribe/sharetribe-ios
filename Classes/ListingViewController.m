//
//  ListingViewController.m
//  Sharetribe
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingViewController.h"

#import "Message.h"
#import "ConversationViewController.h"
#import "LocationPickerViewController.h"
#import "ProfileViewController.h"
#import "SharetribeAPIClient.h"
#import "User.h"
#import "NSString+Sharetribe.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+Sharetribe.h"
#import <QuartzCore/QuartzCore.h>

@interface ListingViewController () {
    Listing *listing;
}
@end

@implementation ListingViewController

@dynamic listing;
@synthesize listingId;

@synthesize scrollView = _scrollView;
@synthesize imageView;
@synthesize backgroundView;
@synthesize topShadowBar;

@synthesize titleLabel;
@synthesize textLabel;
@synthesize tagTitleLabel;
@synthesize tagListLabel;

@synthesize mapView;

@synthesize authorView;
@synthesize authorImageView;
@synthesize authorIntroLabel;
@synthesize authorNameLabel;
@synthesize feedbackIntroLabel;
@synthesize feedbackPercentLabel;
@synthesize feedbackOutroLabel;

@synthesize respondButton;

@synthesize commentsView;

- (Listing *)listing
{
    return listing;
}

- (void)setListing:(Listing *)newListing
{
    listing = newListing;
    listingId = newListing.listingId;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kSharetribeLightBrownColor;
    
    // self.hidesBottomBarWhenPushed = YES;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.mapView = [[MKMapView alloc] init];
    mapView.mapType = MKMapTypeStandard;
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = NO;
    mapView.showsUserLocation = NO;
    mapView.layer.borderWidth = 1;
    mapView.layer.borderColor = [UIColor whiteColor].CGColor;
    mapView.layer.cornerRadius = 8;
    mapView.frame = CGRectMake(10, 0, 300, 87);
    [self.scrollView addSubview:mapView];
    
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapButton.frame = mapView.bounds;
    mapButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [mapButton addTarget:self action:@selector(showDetailedLocation) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:mapButton];
    
    self.commentsView = [[MessagesView alloc] init];
    commentsView.sendButtonTitle = NSLocalizedString(@"button.send.comment", @"");
    commentsView.composeFieldPlaceholder = NSLocalizedString(@"placeholder.comment", @"");
    commentsView.delegate = self;
    [self.scrollView addSubview:commentsView];
    
    [respondButton setImage:[UIImage imageNamed:@"icon-contact"] forState:UIControlStateNormal];
    [respondButton setBackgroundImage:[[UIImage imageNamed:@"dark-orange"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    respondButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    respondButton.layer.cornerRadius = 8;
    respondButton.clipsToBounds = YES;
    [respondButton addTarget:self action:@selector(respondButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *leftEdgeLine = [[UIView alloc] init];
    leftEdgeLine.frame = CGRectMake(-1, 0, 1, 460);
    leftEdgeLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:leftEdgeLine];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedToGoBack)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.scrollView addGestureRecognizer:swipeRecognizer];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefreshListing:) name:kNotificationForDidRefreshListing object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    
    if (listing == nil) {
        [[SharetribeAPIClient sharedClient] getListingWithId:listingId];
    }
}
    
- (void)reloadData
{
    NSString *respondTextKey;
    if ([listing.category isEqual:kListingCategoryFavor] || [listing.category isEqual:kListingCategoryRideshare]) {
        respondTextKey = [NSString stringWithFormat:@"listing.label_for_%@_%@", listing.category, listing.type];
    } else {
        respondTextKey = [NSString stringWithFormat:@"listing.label_for_%@_%@_%@", listing.category, listing.type, listing.shareType];
    }
    [respondButton setTitle:NSLocalizedString(respondTextKey, @"") forState:UIControlStateNormal];
        
    NSURL *imageURL = [listing.imageURLs objectOrNilAtIndex:0];
    if (imageURL != nil) {
        
        [imageView setImageWithURL:imageURL];
        titleLabel.y = backgroundView.y+12;
        
        CAGradientLayer *topShade = [[CAGradientLayer alloc] init];
        topShade.frame = CGRectMake(0, 20, 320, 70);
        topShade.colors = [NSArray arrayWithObjects:(id)([UIColor colorWithWhite:0 alpha:0.5].CGColor), (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
        topShade.startPoint = CGPointMake(0.5, 0.4);
        topShade.endPoint = CGPointMake(0.5, 1.0);
        [topShadowBar.layer insertSublayer:topShade atIndex:0];
        
        CAGradientLayer *midShade = [[CAGradientLayer alloc] init];
        midShade.frame = CGRectMake(0, -2, 320, 2);
        midShade.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0].CGColor, (id)([UIColor colorWithWhite:0 alpha:0.6].CGColor), nil];
        midShade.startPoint = CGPointMake(0.5, 0.2);
        midShade.endPoint = CGPointMake(0.5, 1.0);
        [backgroundView.layer insertSublayer:midShade atIndex:0];

    } else {
        
        imageView.image = nil;
        titleLabel.y = respondButton.y+respondButton.height+21;
        
        [[topShadowBar.layer.sublayers objectOrNilAtIndex:0] removeFromSuperlayer];
        [[backgroundView.layer.sublayers objectOrNilAtIndex:0] removeFromSuperlayer];
    }
    
    titleLabel.text = listing.fullTitle;
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    
    int yOffset = titleLabel.y+titleLabel.height+14;
    
    textLabel.text = listing.description;
    if (textLabel.text != nil) {
        textLabel.y = yOffset;
        textLabel.height = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(textLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
        yOffset = textLabel.y+textLabel.height+14;
    }
    
    if (listing.tags.count > 0) {
        tagTitleLabel.text = NSLocalizedString(@"listing.tags", @"");
        tagListLabel.text = [[tagTitleLabel.text equalWhitespaceWithFont:tagListLabel.font] stringByAppendingString:[listing.tags componentsJoinedByString:@", "]];
        tagTitleLabel.y = yOffset;
        tagListLabel.y = yOffset;
        [tagTitleLabel sizeToFit];
        tagListLabel.height = [tagListLabel.text sizeWithFont:tagListLabel.font constrainedToSize:CGSizeMake(tagListLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
        yOffset = tagListLabel.y+tagListLabel.height+14;
    } else {
        tagTitleLabel.text = nil;
        tagListLabel.text = nil;
    }
    
    if (listing.location != nil) {
        if (![mapView.annotations containsObject:listing]) {
            [mapView addAnnotation:listing];
        }
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(listing.coordinate, 2000, 4000) animated:NO];
        mapView.hidden = NO;
        mapView.y = yOffset+6;
        yOffset = mapView.y+mapView.height+14;
    } else {
        mapView.hidden = YES;
    }
    
    authorView.y = yOffset+6;
    [authorImageView setImageWithUser:listing.author];
    authorNameLabel.text = listing.author.name;
    yOffset = authorView.y+authorView.height+14;
    
    commentsView.x = 10;
    commentsView.y = yOffset+6;
    
    [self setComments:listing.comments];
    
    respondButton.hidden = listing.author.isCurrentUser;  // one cannot respond to oneself
        
    UILabel *titleViewLabel = [[UILabel alloc] init];
    titleViewLabel.font = [UIFont boldSystemFontOfSize:14];
    titleViewLabel.minimumFontSize = 13;
    titleViewLabel.numberOfLines = 3;
    titleViewLabel.lineBreakMode = UILineBreakModeWordWrap;
    titleViewLabel.adjustsFontSizeToFitWidth = YES;
    titleViewLabel.textAlignment = UITextAlignmentCenter;
    titleViewLabel.textColor = [UIColor whiteColor];
    titleViewLabel.backgroundColor = [UIColor clearColor];
    titleViewLabel.shadowColor = [UIColor blackColor];
    titleViewLabel.shadowOffset = CGSizeMake(0, 1);
    titleViewLabel.text = listing.title;
    [titleViewLabel sizeToFit];
    titleViewLabel.height = 20;
    self.navigationItem.titleView = titleViewLabel;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRefreshListing:(NSNotification *)notification
{
    Listing *refreshedListing = notification.object;
    if (refreshedListing.listingId == self.listingId) {
        self.listing = refreshedListing;
        [self reloadData];
    }
}

- (void)setComments:(NSArray *)comments
{
    commentsView.messages = comments;
    int contentHeight = commentsView.y+commentsView.height+10;
    self.scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (IBAction)swipedToGoBack
{
    if (commentsView.composeField.isFirstResponder) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)respondButtonPressed
{
    [self showComposerForDirectReplyToListing:YES];
}

- (IBAction)messageButtonPressed
{
    [self showComposerForDirectReplyToListing:NO];
}

- (void)showComposerForDirectReplyToListing:(BOOL)isDirectReply
{
    ConversationViewController *composer = [[ConversationViewController alloc] init];
    composer.recipient = listing.author;
    composer.listing = listing;
    composer.inModalComposerMode = YES;
    composer.isDirectReplyToListing = isDirectReply;
    
    UINavigationController *composerNavigationController = [[UINavigationController alloc] initWithRootViewController:composer];
    [self presentViewController:composerNavigationController animated:YES completion:nil];

}

- (IBAction)showAuthorProfile
{
    ProfileViewController *profileViewer = [[ProfileViewController alloc] init];
    profileViewer.user = listing.author;
    [self.navigationController pushViewController:profileViewer animated:YES];
}

- (IBAction)showDetailedLocation
{
    LocationPickerViewController *mapViewer = [[LocationPickerViewController alloc] init];
    mapViewer.mapType = MKMapTypeHybrid;
    mapViewer.coordinate = listing.coordinate;
    [self.navigationController pushViewController:mapViewer animated:YES];
}

#pragma mark - MessagesViewDelegate

- (void)messagesViewDidBeginEditing:(MessagesView *)theMessagesView
{
    int contentHeight = commentsView.y+commentsView.height+10;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.height = 416-216+8;
        respondButton.alpha = 0;
        topShadowBar.alpha = 0;
        backgroundView.height = contentHeight-backgroundView.y;
    }];
    
    self.scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    [self.scrollView setContentOffset:CGPointMake(0, commentsView.y+commentsView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidChange:(MessagesView *)theMessagesView
{
    [self.scrollView setContentOffset:CGPointMake(0, commentsView.y+commentsView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidEndEditing:(MessagesView *)theMessagesView
{
    int contentHeight = commentsView.y+commentsView.height+10;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.height = 460-2*44-5;
        respondButton.alpha = 1;
        topShadowBar.alpha = 1;
        backgroundView.height = contentHeight-backgroundView.y;
    }];
    
    self.scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (void)messagesView:(MessagesView *)theMessagesView didSaveMessageText:(NSString *)messageText
{
    [[SharetribeAPIClient sharedClient] postNewComment:messageText onListing:listing];
    
    Message *comment = [Message messageWithAuthor:[User currentUser] content:messageText createdAt:[NSDate date]];
    NSMutableArray *comments = [NSMutableArray arrayWithArray:listing.comments];
    [comments addObject:comment];
    listing.comments = comments;
    commentsView.messages = listing.comments;
}

- (void)messagesView:(MessagesView *)messagesView didSelectUser:(User *)user
{
    ProfileViewController *profileViewer = [[ProfileViewController alloc] init];
    profileViewer.user = user;
    [self.navigationController pushViewController:profileViewer animated:YES];
}

- (CGFloat)availableHeightForComposerInMessagesView:(MessagesView *)messagesView
{
    return 416-216;
}

#pragma mark -

- (void)postedNewComment:(NSNotification *)notification
{
    [[SharetribeAPIClient sharedClient] getListingWithId:listing.listingId];  // refresh to get the canonical state from server
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        CGFloat imageViewBaselineY = -(imageView.height-220)/2;
        CGFloat y = imageViewBaselineY - scrollView.contentOffset.y/2;
        imageView.frame = CGRectMake(0, y, imageView.width, imageView.height);
        
        int buttonY;
        if (scrollView.contentOffset.y > titleLabel.y-68) {
            buttonY = titleLabel.y-68-scrollView.contentOffset.y+10;
        } else {
            buttonY = 10;
        }
        respondButton.y = buttonY;
    }
}

@end
