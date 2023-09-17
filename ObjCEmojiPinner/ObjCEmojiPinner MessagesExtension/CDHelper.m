//
//  CDHelper.m
//  ObjCEmojiPinner MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/16/23.
//

#import "CDHelper.h"

@implementation CDHelper

static NSPersistentContainer *_persistentContainer = nil;

+ (NSPersistentContainer *)persistentContainer {
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"EmojiModel"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

+ (void)saveContext {
    NSManagedObjectContext *context = [self.persistentContainer viewContext];
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}



@end


