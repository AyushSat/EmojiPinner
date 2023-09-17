//
//  UIButtonWrapper.h
//  ObjCEmojiPinner
//
//  Created by Ayush Satyavarpu on 9/16/23.
//


#ifndef UIButtonWrapper_h
#define UIButtonWrapper_h

#import <UIKit/UIKit.h>


@interface UIButtonWrapper : NSObject

@property (nonatomic, strong) UIButton * button;
@property (nonatomic, strong) NSLayoutConstraint * trailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint * centerYConstraint;

- (instancetype)initWith : (UIButton *)button : (NSLayoutConstraint*)trailingConstraint : (NSLayoutConstraint*)centerYConstraint;

@end

#endif /* UIButtonWrapper_h */
