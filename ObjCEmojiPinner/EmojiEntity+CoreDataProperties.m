//
//  EmojiEntity+CoreDataProperties.m
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//
//

#import "EmojiEntity+CoreDataProperties.h"

@implementation EmojiEntity (CoreDataProperties)

+ (NSFetchRequest<EmojiEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"EmojiEntity"];
}

@dynamic emojiString;

@end
