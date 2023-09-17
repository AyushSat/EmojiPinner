//
//  MessagesViewController.m
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//

#import "MessagesViewController.h"
#import "CDHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation MessagesViewController

//COMPLETE
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeVariables];
    [self loadData:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    // Add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTap)];
    [self.view addGestureRecognizer:tapGesture];
}

//COMPLETE
- (void) handleTap {
    [self.view endEditing:YES];
}

//COMPLETE
- (void) initializeTextField {
    [self.view addSubview:self.addButton];
    self.addButton.configuration = UIButtonConfiguration.filledButtonConfiguration;
    self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
    if(self.addConstraint == nil){
        self.addConstraint = [self.addButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10];
    }
    [NSLayoutConstraint activateConstraints:@[[self.addButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10]]];
    self.addConstraint.active = YES;
    [self.addButton setTitle:@"Add" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addEmoji) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.mainTextField];
    if(self.mainTextConstraint == nil){
        self.mainTextConstraint = [self.mainTextField.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.mainTextField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
        [self.mainTextField.trailingAnchor constraintEqualToAnchor:self.addButton.leadingAnchor constant:-5],
        [self.mainTextField.topAnchor constraintEqualToAnchor:self.addButton.topAnchor]
    ]];
    
    self.mainTextConstraint.active = true;
    self.mainTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTextField.placeholder = @"Enter Emoji";
    self.mainTextField.font = [UIFont systemFontOfSize:15];
    self.mainTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.mainTextField.keyboardType = UIKeyboardTypeDefault;
    self.mainTextField.backgroundColor = UIColor.systemGray4Color;
}

//COMPLETED
- (void) keyboardWillShow:(NSNotification *) notification {
    NSDictionary * userInfo = notification.userInfo;
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat kbHeight = keyboardFrame.size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.mainTextConstraint.constant = -kbHeight + 30;
        self.addConstraint.constant = -kbHeight + 30;
        [self.view layoutIfNeeded];
    }];
}

//COMPLETED
- (void) keyboardWillHide:(NSNotification *) notification {
    [UIView animateWithDuration:0.2 animations:^{
        self.mainTextConstraint.constant = -10;
        self.addConstraint.constant = -10;
        [self.view layoutIfNeeded];
    }];
}

//COMPLETE
- (void) addEmoji {
    unichar insertChar = [self.mainTextField.text characterAtIndex:0];
    if(insertChar){
        [self writeData: [NSString stringWithCharacters:&insertChar length:1]];
        [self loadData:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTextField resignFirstResponder];
            self.mainTextField.text = @"";
            [self clearXButtons];
            [self addXButtons];
        });
    }else{
        [self.mainTextField resignFirstResponder];
    }
}

//COMPLETE
- (void) setupLabel {
    [self.view addSubview:self.label];
    self.label.text = @"F A V O R I T E D   E M O J I S";
    self.label.font = [UIFont systemFontOfSize:23 weight:UIFontWeightBold];
    self.label.textColor = UIColor.systemGray2Color;
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.label.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10.0],
        [self.label.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:5.0]
    ]];
}

//COMPLETE
- (void) writeData:(NSString *)newEmojiCharacter {
    EmojiEntity * newEmoji = [[EmojiEntity alloc] initWithContext:self.context];
    newEmoji.emojiString = newEmojiCharacter;
    NSError *saveError = nil;
    if(![self.context save:&saveError]){
        NSLog(@"Error saving context: %@", saveError);
    }
    [self loadData:NO];
}

//COMPLETE
- (CGPoint)getPosition:(NSInteger)index {
    NSInteger rowIndex = floor((float)index / (float)self.numColumns);
    NSInteger colIndex = index % self.numColumns;
    
    CGFloat xOffset = (colIndex + 1) * (self.view.frame.size.width - 30) / self.numColumns;
    CGFloat yOffset = rowIndex * 40 + 60;
    
    return CGPointMake(xOffset, yOffset);
}

//COMPLETE
- (void) setupButtons {
    if(self.emojis.count == 0){
        [self.view addSubview:self.noEmojisLabel];
        self.noEmojisLabel.text = @"No emojis favorited yet. Swipe up to add some!";
        self.noEmojisLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
        self.noEmojisLabel.textColor = UIColor.systemGray2Color;
        [NSLayoutConstraint activateConstraints:@[
            [self.noEmojisLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
            [self.noEmojisLabel.topAnchor constraintEqualToAnchor:self.label.bottomAnchor constant:10]
        ]];
        self.noEmojisLabel.translatesAutoresizingMaskIntoConstraints = NO;
        return;
    }
    NSUInteger count = self.emojis.count;
    for(int i = 0;i<count;i++){
        EmojiEntity * emoji = self.emojis[i];
        UIButton * currButton = [[UIButton alloc] init];
        [self.view addSubview:currButton];
        currButton.configuration = UIButtonConfiguration.plainButtonConfiguration;
        currButton.translatesAutoresizingMaskIntoConstraints = NO;
        CGPoint pt = [self getPosition:i];
        CGFloat xOffset = pt.x;
        CGFloat yOffset = pt.y;
        NSLayoutConstraint * newTrailingConstraint = [currButton.trailingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:xOffset];
        NSLayoutConstraint * newCenterConstraint = [currButton.centerYAnchor constraintEqualToAnchor:self.view.topAnchor constant:yOffset];
        [NSLayoutConstraint activateConstraints:@[newTrailingConstraint, newCenterConstraint]];
        [currButton setTitle:emoji.emojiString forState:UIControlStateNormal];
        currButton.titleLabel.font = [UIFont systemFontOfSize:self.emojiFontSize];
        [currButton addTarget:self action:@selector(enterEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [currButton addTarget:self action:@selector(onUp:) forControlEvents:UIControlEventTouchDown];
        [currButton.configuration setContentInsets: NSDirectionalEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
        [self.emojiButtons addObject: [[UIButtonWrapper alloc] initWith:currButton :newTrailingConstraint :newCenterConstraint]];
    }
}

//COMPLETE
- (void) updateUI {
    for(UIButtonWrapper * button in self.emojiButtons){
        [button.button removeFromSuperview];
    }
    [self.noEmojisLabel removeFromSuperview];
    [self.emojiButtons removeAllObjects];
    
    [self setupLabel];
    [self setupButtons];
}

//COMPLETE
- (void) loadData: (BOOL) updateUI{
    NSFetchRequest * fr = [EmojiEntity fetchRequest];
    NSError * fetchError = nil;
    self.emojis = [[self.context executeFetchRequest:fr error:&fetchError] mutableCopy];
    
    if(fetchError){
        NSLog(@"Error loading data");
        return;
    }
    
    if(updateUI){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    }
}

//COMPLETE
- (void) enterEmoji: (UIButton *) btn {
    if(self.isExpanded){
        return;
    }
    [UIView animateWithDuration:0.15 animations:^{
        btn.transform = CGAffineTransformIdentity;
    }];
    NSString * title = [btn titleForState:UIControlStateNormal];
    
    void (^myCompletionHandler)(NSError *error) = ^(NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"No error occurred.");
        }
    };
    
    if(title) {
        [self.activeConversation insertText:title completionHandler:myCompletionHandler];
    }
}

//COMPLETE
- (void) onUp: (UIButton *) btn {
    if(self.isExpanded){
        return;
    }
    [UIView animateWithDuration:0.15 animations:^{
        btn.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
    
}

//COMPLETE
- (void) initializeVariables {
    self.emojis = [[NSMutableArray<EmojiEntity*> array] init];
    self.context = CDHelper.persistentContainer.viewContext;
    self.emojiButtons = [[NSMutableArray<UIButtonWrapper*> array] init];
    self.xButtons = [[NSMutableArray<UIButton*> array] init];
    self.label = [[UILabel alloc] init];
    self.noEmojisLabel = [[UILabel alloc] init];
    self.isExpanded = NO;
    self.mainTextField = [[UITextField alloc] init];
    self.mainTextConstraint = nil;
    self.addButton = [[UIButton alloc] init];
    self.addConstraint = nil;
    self.numColumns = 7;
    self.emojiFontSize = 30;
}

//COMPLETE
- (void) removeEmoji:(UIButton *) sender{
    EmojiEntity * emojiToDelete = self.emojis[sender.tag];
    [self.context deleteObject:emojiToDelete];
    NSError *saveError = nil;
    if(![self.context save:&saveError]){
        NSLog(@"Error saving context: %@", saveError);
    }
    [self loadData:NO];
    UIButtonWrapper * emojiButtonToDelete = self.emojiButtons[sender.tag];
    UIButton * xButtonToDelete = self.xButtons[sender.tag];
    [self.emojiButtons removeObjectAtIndex:sender.tag];
    [self.xButtons removeObjectAtIndex:sender.tag];
    for(UIButton * xButton in self.xButtons){
        if(xButton.tag > sender.tag){
            xButton.tag = xButton.tag - 1;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        for(NSUInteger i = sender.tag; i<self.emojiButtons.count;i++){
            UIButtonWrapper * emojiButton = self.emojiButtons[i];
            CGPoint pt = [self getPosition:i];
            emojiButton.centerYConstraint.constant = pt.y;
            emojiButton.trailingConstraint.constant = pt.x;
        }
        [self.view layoutIfNeeded];
        emojiButtonToDelete.button.alpha = 0.0;
        xButtonToDelete.alpha = 0.0;
    } completion:^(BOOL completed){
        [emojiButtonToDelete.button removeFromSuperview];
        [xButtonToDelete removeFromSuperview];
    }];
    
}

//COMPLETE
- (void) addXButtons {
    NSUInteger count = [self.emojiButtons count];
    for(NSUInteger i = 0;i<count;i++){
        UIButtonWrapper * emojiButton = self.emojiButtons[i];
        [self shakeButton:emojiButton.button];
        UIButton * newX = [[UIButton alloc] init];
        [self.view addSubview:newX];
        newX.configuration = UIButtonConfiguration.grayButtonConfiguration;
        newX.tintColor = UIColor.whiteColor;
        newX.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [newX.centerXAnchor constraintEqualToAnchor:emojiButton.button.leadingAnchor constant:10.0],
            [newX.centerYAnchor constraintEqualToAnchor:emojiButton.button.topAnchor constant:10.0]
        ]];
        [newX setTitle:@"x" forState:UIControlStateNormal];
        newX.titleLabel.font = [UIFont systemFontOfSize:10];
        newX.tag = i;
        [newX addTarget:self action:@selector(removeEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [newX.configuration setContentInsets: NSDirectionalEdgeInsetsMake(0, 200.0, 200.0, 2.0)];
        [self.view bringSubviewToFront:newX];
        [self.xButtons addObject:newX];
        [self shakeButtonViolently:newX];
    }
}

//COMPLETE
- (void) clearXButtons {
    for(UIButton * btn in self.xButtons){
        [btn removeFromSuperview];
    }
    self.xButtons = [NSMutableArray<UIButton*> array];
}

//COMPLETE
- (void)shakeButton:(UIButton *) button {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.1;  // Adjust the duration as needed
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;  // Repeat indefinitely
    animation.fromValue = @(M_PI / -18.0); // Rotate slightly counterclockwise (about 0.05 radians)
    animation.toValue = @(M_PI / 18.0);   // Rotate slightly clockwise (about 0.05 radians)
    [button.layer addAnimation:animation forKey:@"rotation"];
}

//COMPLETE
- (void)shakeButtonViolently:(UIButton *) button {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.1;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    animation.fromValue = @(M_PI / -45.0);
    animation.toValue = @(M_PI / 45.0);
    [button.layer addAnimation:animation forKey:@"rotationViolent"];
}

//COMPLETE
-(void)willTransitionToPresentationStyle:(MSMessagesAppPresentationStyle)presentationStyle {
    // Called before the extension transitions to a new presentation style.
    if(presentationStyle == MSMessagesAppPresentationStyleExpanded){
        [self addXButtons];
        self.isExpanded = YES;
        [self initializeTextField];
        self.mainTextConstraint.constant = -10;
        self.addConstraint.constant = -10;
        [self.view layoutIfNeeded];
    }else if(presentationStyle == MSMessagesAppPresentationStyleCompact){
        for(UIButtonWrapper * emojiButton in self.emojiButtons){
            [emojiButton.button.layer removeAnimationForKey:@"rotation"];
        }
        [self clearXButtons];
        self.isExpanded = NO;
        [self loadData:YES];
        self.mainTextConstraint.constant = -10;
        self.addConstraint.constant = -10;
        [self.view layoutIfNeeded];
    }
}

@end
