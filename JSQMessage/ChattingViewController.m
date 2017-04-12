//
//  ChattingViewController.m
//  JSQMessage
//
//  Created by MinYeh on 2017/4/12.
//  Copyright © 2017年 MINYEH. All rights reserved.
//

#import "ChattingViewController.h"

@interface ChattingViewController ()<JSQMessagesCollectionViewDataSource,JSQMessagesCollectionViewDelegateFlowLayout,UITextViewDelegate,UIActionSheetDelegate>

@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.showLoadEarlierMessagesHeader = true;
    //self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.senderId = @"AP102"; //給予自己一組唯一的識別碼
    self.senderDisplayName = @"MinYeh"; //給予自己要顯示的名稱
    
    //設定收、發訊息的泡泡框顏色
    JSQMessagesBubbleImageFactory * bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    self.incomingBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    self.outgoingBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    //給予對方一個頭像
    self.incomingAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"設定.png"] diameter:64];
    
    
    self.messages = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark JSQMessagesViewController Delegate

//點擊發送訊息鈕時，會觸發該方法
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    
    //發送訊息時使用預設音(選用)
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    //將必要資訊包裝成一個訊息物件
    JSQMessage * message = [[JSQMessage alloc]initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:text];
    
    [self.messages addObject:message];
    
    //處理完發送訊息後必須呼叫該方法，該方法會做一些畫面處理及更新資料，填入的參數是用來決定將畫面移動到最下面是否要動畫
    [self finishSendingMessageAnimated:true];
    
    //以下方法跟上面相同，差別是將畫面移動到最下面是有動畫的
    //[self finishSendingMessage];
    
    //模擬收到訊息用
    [self receiveAutoMessage];
}

//下方功能鍵
- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Send photo", nil), NSLocalizedString(@"Send location", nil), NSLocalizedString(@"Send video", nil), NSLocalizedString(@"Send video thumbnail", nil), NSLocalizedString(@"Send audio", nil), nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

//功能鍵各功能實作
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    /*
     *  這實作方向是將多媒體檔案跟必要資訊包好一個訊息物件並加入到要顯示的array中，最後別忘了執行
     *  [self finishSendingMessageAnimated:YES];
     */
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"請自行實作發送照片功能");
            break;
            
        case 1:
        {
            NSLog(@"請自行實作發送位置功能");
//            __weak UICollectionView *weakView = self.collectionView;
//            
//            [self.demoData addLocationMediaMessageCompletion:^{
//                [weakView reloadData];
//            }];
        }
            break;
            
        case 2:
            NSLog(@"請自行實作發送影片功能");
            break;
            
        case 3:
            //[self.demoData addVideoMediaMessageWithThumbnail];
            break;
            
        case 4:
            NSLog(@"請自行實作發送語音功能");
            break;
    }
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return  [self.messages objectAtIndex:indexPath.item];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage * message = [self.messages objectAtIndex:indexPath.item];
    
    //判斷是我方的訊息還是對方的訊息，並給予正確的泡泡框
    //注意：假如不想使用泡泡框，回傳nil
    if([message.senderId isEqualToString:self.senderId]){
        return self.outgoingBubble;
    }
    
    return self.incomingBubble;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage * message = [self.messages objectAtIndex:indexPath.item];
    if([message.senderId isEqualToString:self.senderId]){
        return self.outgoingAvatar;
    }
    return self.outgoingAvatar;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return  self.messages.count;
}

/**
 *  顯示時間戳
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  設定條件顯示時間戳，此例是以每三次就顯示一條時間戳
     *  不想顯示則return nil
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

/**
 *  顯示名字
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  判斷是不是對方發送的訊息來決定是否要顯示名字，不想顯示填nil
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
        //return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
            //return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     *  請使用預設的屬性
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

/**
 *  泡泡框下面還有一塊空間，這個方法是決定那塊空間UILabel要顯示什麼
 */
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - 計算各個Label的高度

/**
 *  決定時間戳這個UILabel的高度
 */
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
        
    }
    
    return 0.0f;
}

/**
 *  決定名字這個UILabel的高度
 */
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  不想顯示高度填0
     */

    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
        //return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
            //return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}
/**
 *  泡泡框下面還有一塊空間，這個方法是決定那塊空間UILabel要多高
 */
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark 模擬接收訊息

- (void)receiveAutoMessage
{
    //觸發一秒後發送訊息模擬是對方發送
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(didFinishMessageTimer:)
                                   userInfo:nil
                                    repeats:NO];
}


//收訊息的方法(該範例是自訂的)，實際上應以開發時所接收訊息的方法內做處理
- (void)didFinishMessageTimer:(NSTimer*)timer
{
    //接收訊息的預設音
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    //將必要資訊封裝成訊息物件
    JSQMessage *message = [JSQMessage messageWithSenderId:@"user2"
                                              displayName:@"MinYeh"
                                                     text:@"Hello"];
    [self.messages addObject:message];
    //處理完接收訊息後必須呼叫該方法，該方法會做一些畫面處理及更新資料，填入的參數是用來決定將畫面移動到最下面是否要動畫
    [self finishReceivingMessageAnimated:true];
}

#pragma mark - 使用者點擊畫面中的元件時會觸發的方法

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"點擊頭像!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"點擊對話框!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}
@end
