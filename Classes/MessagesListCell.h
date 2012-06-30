//
//  MessagesListCell.h
//  Kassi
//
//  Created by Janne Käki on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageThread.h"

#define kMessagesListCellHeight 80

@interface MessagesListCell : UITableViewCell {

    MessageThread *messageThread;
}

@property (nonatomic, strong) IBOutlet UIImageView *avatarView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

+ (MessagesListCell *)instance;

- (MessageThread *)messageThread;
- (void)setMessageThread:(MessageThread *)thread;

@end
