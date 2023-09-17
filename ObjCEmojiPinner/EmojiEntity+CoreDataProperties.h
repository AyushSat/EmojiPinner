//
//  EmojiEntity+CoreDataProperties.h
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//
//

#import "EmojiEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface EmojiEntity (CoreDataProperties)

+ (NSFetchRequest<EmojiEntity *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nullable, nonatomic, copy) NSString *emojiString;

@end

NS_ASSUME_NONNULL_END
