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
    if ([self hasOption:@"verbose"])
        return YES;
    return NO;
}

- (NSSet<NSString> *)supportedOptions
{
    return (NSSet<NSString> *)[NSSet setWithObjects:@"help", @"verbose", @"silent", nil];
}

- (BOOL)checkValidityOfCommand
{
    return NO;
}

- (void)performCommand
{
    if (![MODSpecModel sharedInstance].isInitialized)
        sderror(@"This directory has not been initialized for modulo.");
}

@end
