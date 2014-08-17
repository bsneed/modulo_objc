//
//  MODVersionCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODVersionCommand.h"
#import "version.h"

@implementation MODVersionCommand

- (NSSet<NSString> *)supportedOptions
{
    return nil;
}

- (BOOL)checkValidityOfCommand
{
    return YES;
}

- (void)performCommand
{
    sdprintln(@"%@ version %@", [SDCommandLineParser sharedInstance].processName, VERSION_STRING);
}

- (void)printHelp
{
    [self performCommand];
}

@end
