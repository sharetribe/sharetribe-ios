//
//  ConversationListCell.h
//  Sharetribe
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Conversation;

#define kConversationListCellHeight 88

@interface ConversationListCell : UITableViewCell

@property (nonatomic, strong) Conversation *conversation;

@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

+ (ConversationListCell *)instance;

@end
