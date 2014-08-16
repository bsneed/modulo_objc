//
//  MODCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODCommand.h"

@implementation MODCommand

//@property (nonatomic, readonly) NSUInteger supportArgumentCount;

- (BOOL)verbose
{
    if ([self hasFlag:@"v"])
        return YES;
    return NO;
}

- (NSSet<NSString> *)supportedFlags
{
    return (NSSet<NSString> *)[NSSet setWithObjects:@"help", @"v", nil];
}

- (BOOL)checkValidityOfCommand
{
    return NO;
}

- (void)performCommand
{
}

@end
