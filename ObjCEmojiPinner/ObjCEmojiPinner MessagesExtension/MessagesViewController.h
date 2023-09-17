//
//  MessagesViewController.h
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//

#import <Messages/Messages.h>
#import "CDHelper.h"
#import "EmojiModel+CoreDataModel.h"
#import "UIButtonWrapper.h"
#import <UIKit/UIKit.h>

@interface MessagesViewController : MSMessagesAppViewController

@property (nonatomic, strong) NSMutableArray<EmojiEntity *> *emojis;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSMutableArray<UIButtonWrapper *> *emojiButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> * xButtons;
@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) UILabel * noEmojisLabel;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic, strong) UITextField * mainTextField;
@property (nonatomic, strong) NSLayoutConstraint * mainTextConstraint;
@property (nonatomic, strong) UIButton * addButton;
@property (nonatomic, strong) NSLayoutConstraint * addConstraint;
@property (nonatomic) int numColumns;
@property (nonatomic) CGFloat emojiFontSize;


@end
