//
//  NSObject+SDExtensions.m
//  billingworks
//
//  Created by brandon on 1/14/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "NSObject+SDExtensions.h"

#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (SDExtensions)

+ (NSString *)className
{
    return NSStringFromClass(self);
}

- (NSString *)className
{
    return [[self class] className];
}

+ (NSString *)nibName
{
    return [self className];
}

#if TARGET_OS_IPHONE
+ (id)loadFromNib
{
    return [self loadFromNibWithOwner:self];
}

+ (id)loadFromNibNamed:(NSString *)nibName
{
    return [self loadFromNibNamed:nibName withOwner:self];
}

+ (id)loadFromNibWithOwner:(id)owner
{
    return [self loadFromNibNamed:[self nibName] withOwner:self];
}

+ (id)loadFromNibNamed:(NSString *)nibName withOwner:(id)owner
{
    NSArray *objects = [[NSBundle bundleForClass:[self class]] loadNibNamed:nibName owner:owner options:nil];
	for (id object in objects)
    {
		if ([object isKindOfClass:self])
			return object;
	}

#ifdef DEBUG
	NSAssert(NO, @"Could not find object of class %@ in nib %@", [self class], [self nibName]);
#endif
	return nil;
}
#endif

- (BOOL)keyPathExists:(NSString *)keyPath
{
    id targetObject = self;
    BOOL exists = NO;
    
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    for (NSUInteger i = 0; i < components.count; i++)
    {
        NSString *key = [components objectAtIndex:i];
        if ([self respondsToSelector:NSSelectorFromString(key)])
        {
            targetObject = [targetObject valueForKey:key];
            if (i == components.count - 1)
                exists = YES;
        }
        else if ([self isKindOfClass:[NSDictionary class]])
        {
            exists = [self valueForKeyPath:keyPath] != nil;
        }
        else
            break;
    }
    
    return exists;
}

static dispatch_semaphore_t __asyncSemaphore = nil;

- (void)waitForAsynchronousTask
{
    if (!__asyncSemaphore)
        __asyncSemaphore = dispatch_semaphore_create(0);
    
    // we're waiting briefly so the runloop can run.
    // if wait returns 0, that means it was signaled so we can gtfo.
    while (0 != dispatch_semaphore_wait(__asyncSemaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
}

- (void)completeAsynchronousTask
{
    dispatch_semaphore_signal(__asyncSemaphore);
}

// This is tightly tied to the implementation found in NSArray+SDExtensions.m
// These is a reason that the implementation is duplicated and not called into NSObject's version.
// Please keep them duplicated otherwise the recursion bug that is being solved will happen again.

- (void)performSelector:(SEL)aSelector returnAddress:(void *)returnAddress argumentAddresses:(void *)arg1, ...
{
#define kMaximumCallSelectorArguments 20
    
    // if it doesn't respond to the selector we're about to send it, GTFO.
    if (![self respondsToSelector:aSelector])
        return;
    
    NSMethodSignature *methodSig = [[self class] instanceMethodSignatureForSelector:aSelector];
    NSUInteger numberOfArguments = [methodSig numberOfArguments] - 2;
    
    // it has more than 20 args???  Go smack the developer making methods w/ that many params.
    if (numberOfArguments >= kMaximumCallSelectorArguments)
        [NSException raise:@"SDException" format:@"performSelector:returnAddress:argumentAddresses: cannot take more than %zd arguments.", kMaximumCallSelectorArguments];
    
    // get our args in order and make sure we don't send bullshit parameters, so clear it out.
    void *arguments[kMaximumCallSelectorArguments];
    memset(arguments, 0, sizeof(void *) * kMaximumCallSelectorArguments);
    
    // get our args out of the va_list, get ourselves a parameter count y0!
    va_list args;
    va_start(args, arg1);
    
    arguments[0] = arg1;
    for (NSUInteger i = 1; i < numberOfArguments; i++)
        arguments[i] = va_arg(args, void *);
    
    va_end(args);
    
    // call that mofo.
    NSObject *object = self;
    if([object respondsToSelector:aSelector])
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSig];
        [invocation setTarget:object];
        [invocation setSelector:aSelector];
        
        void *theArg = nil;
        for (NSInteger i = 0; i < numberOfArguments; i++)
        {
            theArg = arguments[i];
            [invocation setArgument:theArg atIndex:i + 2];
        }
        
        [invocation invoke];

        if (returnAddress)
            [invocation getReturnValue:returnAddress];
    }
}

- (void)performBlockInBackground:(NSObjectPerformBlock)performBlock completion:(NSObjectPerformBlock)completionBlock
{
    if (performBlock)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            performBlock();
            if (completionBlock)
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
        });
}

- (void)__performBlockSelector:(NSObjectPerformBlock)block
{
    if (block)
        block();
}

- (void)performBlock:(NSObjectPerformBlock)performBlock afterDelay:(NSTimeInterval)delay
{
    /*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (performBlock)
            performBlock();
    });*/
    
    // ^^^ produces significant delay in just telling the block to execute.  when on the main queue, its less
    // performant to do this.
    
    if (performBlock)
        [self performSelector:@selector(__performBlockSelector:) withObject:[performBlock copy] afterDelay:delay];
}

- (void)performBlockOnMainThread:(NSObjectPerformBlock)performBlock waitUntilDone:(BOOL)waitUntilDone
{
    /*dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
     if (performBlock)
     performBlock();
     });*/

    // ^^^ produces significant delay in just telling the block to execute.  when on the main queue, its less
    // performant to do this.

    if (performBlock)
        [self performSelectorOnMainThread:@selector(__performBlockSelector:) withObject:[performBlock copy] waitUntilDone:waitUntilDone];
}

#pragma mark - JRSwizzle code adoption

//   Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/jrswizzle

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
    if (ERROR_VAR) {	\
        NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
        *ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
                                         code:-1	\
                                     userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
    }

#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)alternateSelector error:(NSError**)error
{
	Method origMethod = class_getInstanceMethod(self, originalSelector);
	if (!origMethod)
    {
		SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(originalSelector), [self class]);
		return NO;
	}

	Method altMethod = class_getInstanceMethod(self, alternateSelector);
	if (!altMethod)
    {
		SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(alternateSelector), [self class]);
		return NO;
	}

	class_addMethod(self, originalSelector, class_getMethodImplementation(self, originalSelector), method_getTypeEncoding(origMethod));
	class_addMethod(self, alternateSelector, class_getMethodImplementation(self, alternateSelector), method_getTypeEncoding(altMethod));

	method_exchangeImplementations(class_getInstanceMethod(self, originalSelector), class_getInstanceMethod(self, alternateSelector));

	return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)alternateSelector error:(NSError**)error
{
	return [object_getClass((id)self) swizzleMethod:originalSelector withMethod:alternateSelector error:error];
}

@end
