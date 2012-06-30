//
//  ListingViewController.m
//  Kassi
//
//  Created by Janne Käki on 2/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListingViewController.h"

#import "Message.h"
#import "MessageThreadViewController.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListingViewController

@synthesize listing;

@synthesize scrollView;
@synthesize imageView;
@synthesize titleLabel;
@synthesize textLabel;
@synthesize commentsView;
@synthesize followButton;
@synthesize messageButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kKassiLightBrownColor;
    
    // self.hidesBottomBarWhenPushed = YES;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-back"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    
    self.scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, 320, 460-2*44-5);
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.layer.borderColor = kKassiDarkBrownColor.CGColor;
    imageView.layer.borderWidth = 1;
    [scrollView addSubview:imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    titleLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:titleLabel];
    
    self.textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = UILineBreakModeWordWrap;
    textLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:textLabel];
    
    self.commentsView = [[MessagesView alloc] init];
    commentsView.sendButtonTitle = @"Send comment";
    commentsView.composeFieldPlaceholder = @"Write a new comment";
    commentsView.delegate = self;
    [scrollView addSubview:commentsView];
    
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followButton.frame = CGRectMake(10, 20, 145, 40);
    followButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:@"icon-eye"] forState:UIControlStateNormal];
    [followButton setBackgroundImage:[[UIImage imageNamed:@"dark-orange"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    followButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    followButton.layer.cornerRadius = 8;
    followButton.clipsToBounds = YES;
    [followButton addTarget:self action:@selector(followButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:followButton];
    
    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageButton.frame = CGRectMake(165, 20, 145, 40);
    messageButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [messageButton setTitle:@"Contact" forState:UIControlStateNormal];
    [messageButton setImage:[UIImage imageNamed:@"icon-contact"] forState:UIControlStateNormal];
    [messageButton setBackgroundImage:[[UIImage imageNamed:@"dark-orange"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    messageButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    messageButton.layer.cornerRadius = 8;
    messageButton.clipsToBounds = YES;
    [messageButton addTarget:self action:@selector(messageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:messageButton];
    
    UIView *leftEdgeLine = [[UIView alloc] init];
    leftEdgeLine.frame = CGRectMake(-1, 0, 1, 460);
    leftEdgeLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:leftEdgeLine];
    
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goBack)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.scrollView addGestureRecognizer:swipeRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    imageView.image = listing.image;
    titleLabel.text = [NSString stringWithFormat:@"%@: %@", listing.shareType.capitalizedString, listing.title];
    textLabel.text = listing.description;
    commentsView.messages = listing.comments;
    
    if (imageView.image != nil) {
        CGFloat imageWidth = listing.image.size.width;
        CGFloat imageHeight = listing.image.size.height;
        if (imageWidth > imageHeight) {
            imageView.width = MIN(imageWidth, 300);
            imageView.height = imageView.width * (imageHeight/imageWidth);
        } else {
            imageView.height = MIN(imageHeight, 300);
            imageView.width = imageView.height * (imageWidth/imageHeight);
        }
        imageView.x = 10+(300-imageView.width)/2;
        imageView.hidden = NO;
    } else {
        imageView.hidden = YES;
    }
    imageView.y = 80;
    
    titleLabel.x = 10;
    if (imageView.image != nil) {
        titleLabel.y = imageView.y+imageView.height+16;
    } else {
        titleLabel.y = imageView.y+6;
    }
    titleLabel.width = 300;
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    
    textLabel.x = 10;
    textLabel.y = titleLabel.y+titleLabel.height+14;
    textLabel.width = 300;
    textLabel.height = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(textLabel.width, 10000) lineBreakMode:UILineBreakModeWordWrap].height;
    
    commentsView.x = 10;
    commentsView.y = textLabel.y+textLabel.height+20;
    
    int contentHeight = commentsView.y+commentsView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
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
    titleViewLabel.frame = CGRectMake(0, 0, 260, 44);
    titleViewLabel.text = listing.title;
    self.navigationItem.titleView = titleViewLabel;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)followButtonPressed
{
}

- (IBAction)messageButtonPressed
{
    MessageThread *newThread = [[MessageThread alloc] init];
    newThread.recipient = listing.author;
    newThread.subject = listing.title;
    
    MessageThreadViewController *composer = [[MessageThreadViewController alloc] init];
    composer.messageThread = newThread;
    composer.inModalComposerMode = YES;
    
    UINavigationController *composerNavigationController = [[UINavigationController alloc] initWithRootViewController:composer];
    [self presentViewController:composerNavigationController animated:YES completion:nil];
}

#pragma mark - MessagesViewDelegate

- (void)messagesViewDidBeginEditing:(MessagesView *)theMessagesView
{
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 416-216;
    // self.view.backgroundColor = kKassiBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = commentsView.y+commentsView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
    
    [scrollView setContentOffset:CGPointMake(0, commentsView.y+commentsView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidChange:(MessagesView *)theMessagesView
{
    [scrollView setContentOffset:CGPointMake(0, commentsView.y+commentsView.composeField.y-10) animated:YES];
}

- (void)messagesViewDidEndEditing:(MessagesView *)theMessagesView
{    
    [UIView beginAnimations:nil context:NULL];
    scrollView.height = 460-2*44-5;
    // self.view.backgroundColor = kKassiLightBrownColor;
    [UIView commitAnimations];
    
    int contentHeight = commentsView.y+commentsView.height+10;
    scrollView.contentSize = CGSizeMake(320, contentHeight);
}

- (void)messagesView:(MessagesView *)theMessagesView didSaveMessageText:(NSString *)messageText
{
    Message *comment = [[Message alloc] init];
    
    comment.authorId = [[User currentUser] userId];
    comment.content = messageText;
    comment.createdAt = [NSDate date];
    
    NSMutableArray *comments = [NSMutableArray arrayWithArray:listing.comments];
    [comments addObject:comment];
    listing.comments = comments;
    commentsView.messages = listing.comments;
}

@end
