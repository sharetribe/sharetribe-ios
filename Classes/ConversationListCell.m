//
//  ConversationListCell.m
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationListCell.h"

#import "Conversation.h"
#import "Participation.h"
#import "User.h"
#import "NSDate+Sharetribe.h"
#import "UIImageView+Sharetribe.h"
#import <QuartzCore/QuartzCore.h>

@interface ConversationListCell () {
    Conversation *conversation;
}
@end

@implementation ConversationListCell

@dynamic conversation;

@synthesize avatarView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize usernameLabel;
@synthesize timeLabel;

+ (ConversationListCell *)instance
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"ConversationListCell" owner:self options:nil];
    if (nibContents.count > 0) {
        ConversationListCell *cell = [nibContents objectAtIndex:0];
        cell.backgroundColor = kSharetribeLightBrownColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.layer.borderWidth = 1;
        cell.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        return cell;
    }
    return nil;
}

- (Conversation *)conversation
{
    return conversation;
}

- (void)setConversation:(Conversation *)newConversation
{
    conversation = newConversation;
    
    User *recipient = [conversation recipient];
    usernameLabel.text = recipient.name;
    [avatarView setImageWithUser:recipient];
    
    titleLabel.text = conversation.title;
    subtitleLabel.text = [conversation.messages.lastObject text];
    timeLabel.text = [conversation.updatedAt agestamp];    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.backgroundColor = kSharetribeLightOrangeColor;
    } else {
        self.backgroundColor = kSharetribeLightBrownColor;
    }
}

@end
