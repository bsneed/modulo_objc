//
//  NSObject+SDExtensions.h
//
//  Created by brandon on 1/14/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A number of extensions to the base NSObject class. Most of these came into existence to make the loading of nibs much easier.
 */

typedef void (^NSObjectPerformBlock)();

@interface NSObject (SDExtensions)

/**
 A convenient wrapper for `NSStringFromClass`. Returns the name of the class.
 */
+ (NSString *)className;

/**
 A convenient wrapper for `NSStringFromClass`. Returns the name of the class of the receiver.
 */
- (NSString *)className;

/**
 A convenient wrapper for `NSStringFromClass`. Returns the name of the class of the receiver.
 */
+ (NSString *)nibName;

#if TARGET_OS_IPHONE
/**
 Creates and returns an object by calling loadFromNibWithOwner: with owner `self`.
 */
+ (id)loadFromNib;

/**
 Creates and returns an object by calling loadFromNibNamed:withOwner: with the given nibName and owner `self`.
 */
+ (id)loadFromNibNamed:(NSString *)nibName;

/**
 Creates and returns an object by calling loadFromNibNamed:withOwner: with the name `[self nibName]` and owner `self`.
 */
+ (id)loadFromNibWithOwner:(id)owner;

/**
 Creates and returns an object of type `self` by loads a nib with the name `nibName` and looking for and returning the first object of type `self`.
 */
+ (id)loadFromNibNamed:(NSString *)nibName withOwner:(id)owner;
#endif

/**
 Check to see if a given keypath exists.
 */
- (BOOL)keyPathExists:(NSString *)keyPath;

/**
 Waits for an asyc task to finish.
 */
- (void)waitForAsynchronousTask;

/**
 Signals that an async task has completed.
 */
- (void)completeAsynchronousTask;

/**
 Invoke arbitrary selectors on the receiver with arbitrary arguments and with a place to store the result of the invocation.
 @param aSelector The selector to invoke. It must exist on the receiver.
 @param returnAddress A pointer to the location where the result of the invocation can be stored. Optional.
 @param arg1,... The ordered list of arguments to pass to the selector being invoked.
 */
- (void)performSelector:(SEL)aSelector returnAddress:(void *)returnAddress argumentAddresses:(void *)arg1, ...;

/**
 Execute a block in the background.
 @param performBlock The block to execute in the background.
 @param completionBlock The block to execute on the main thread after the performBlock completes.
 */
- (void)performBlockInBackground:(NSObjectPerformBlock)performBlock completion:(NSObjectPerformBlock)completionBlock;

/**
 Execute a block after a delay.
 @param performBlock The block to execute in the background.
 @param delay The time in seconds after which to execute the block.
 */
- (void)performBlock:(NSObjectPerformBlock)performBlock afterDelay:(NSTimeInterval)delay;

/**
 Execute a block on the main thread.
 @param performBlock The block to execute on the main thread.
 @param waitUntilDone Specifies whether it should wait for the block to complete before returning.
 */
- (void)performBlockOnMainThread:(NSObjectPerformBlock)performBlock waitUntilDone:(BOOL)waitUntilDone;

/**
 Swizzle instances methods on an object.  Gratefully stolen from:
 
    Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
    Some rights reserved: http://opensource.org/licenses/MIT
 */
+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)alternateSelector error:(NSError**)error;

/**
 Swizzle class methods on an object.  Gratefully stolen from:

 Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
 Some rights reserved: http://opensource.org/licenses/MIT
 */
+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)alternateSelector error:(NSError**)error;


@end
