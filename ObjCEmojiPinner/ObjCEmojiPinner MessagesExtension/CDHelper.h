//
//  CDHelper.h
//  ObjCEmojiPinner
//
//  Created by Ayush Satyavarpu on 9/16/23.
//

#ifndef CDHelper_h
#define CDHelper_h

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface CDHelper : NSObject

+ (NSPersistentContainer *) persistentContainer;

+ (void)saveContext;

@end
#endif /* CDHelper_h */
