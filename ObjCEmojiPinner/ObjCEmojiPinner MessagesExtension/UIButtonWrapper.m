//
//  UIButtonWrapper.m
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//

#import <Foundation/Foundation.h>
#import "UIButtonWrapper.h"

@implementation UIButtonWrapper

-(instancetype)initWith:(UIButton *)button :(NSLayoutConstraint *)trailingConstraint :(NSLayoutConstraint *)centerYConstraint{
    self.button = button;
    self.trailingConstraint = trailingConstraint;
    self.centerYConstraint = centerYConstraint;
    return self;
}

@end
