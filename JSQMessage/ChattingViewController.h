//
//  ChattingViewController.h
//  JSQMessage
//
//  Created by MinYeh on 2017/4/12.
//  Copyright © 2017年 MINYEH. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "JSQMessages.h"
@interface ChattingViewController : JSQMessagesViewController

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubble;
@property (strong, nonatomic) JSQMessagesAvatarImage *incomingAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *outgoingAvatar;
@end
