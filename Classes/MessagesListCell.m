//
//  MessagesListCell.m
//  Kassi
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessagesListCell.h"

#import "User.h"
#import "NSDate+Extras.h"
#import <QuartzCore/QuartzCore.h>

@implementation MessagesListCell

@synthesize avatarView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize usernameLabel;
@synthesize timeLabel;

+ (MessagesListCell *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"MessagesListCell" owner:self options:nil];
    if (nibContents.count > 0) {
        MessagesListCell *cell = [nibContents objectAtIndex:0];
        cell.backgroundColor = kKassiLightBrownColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        return cell;
    }
    return nil;
}

- (MessageThread *)messageThread
{
    return messageThread;
}

- (void)setMessageThread:(MessageThread *)thread
{
    messageThread = thread;
    
    titleLabel.text = messageThread.subject;
    subtitleLabel.text = [messageThread.messages.lastObject text];
    usernameLabel.text = messageThread.recipient.name;
    timeLabel.text = [messageThread.date agestamp];
    avatarView.image = messageThread.recipient.avatar;
    
    titleLabel.height = [titleLabel.text sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.width, usernameLabel.y) lineBreakMode:UILineBreakModeWordWrap].height;
    
    subtitleLabel.y = titleLabel.y + titleLabel.height+2;
    subtitleLabel.height = [subtitleLabel.text sizeWithFont:subtitleLabel.font constrainedToSize:CGSizeMake(subtitleLabel.width, (kMessagesListCellHeight-subtitleLabel.y-5)) lineBreakMode:UILineBreakModeWordWrap].height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = kKassiLightOrangeColor;
    } else {
        self.backgroundColor = kKassiLightBrownColor;
    }
}

@end
