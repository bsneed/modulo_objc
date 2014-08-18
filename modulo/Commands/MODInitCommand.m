//
//  MODInitCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODInitCommand.h"

@implementation MODInitCommand

- (NSSet<NSString> *)supportedOptions
{
    return [super supportedOptions];
}

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;

    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        // a spec file doesn't already exist, we're good to go.
        if (![MODSpecModel sharedInstance].name)
            result = YES;
    }
    
    return result;
}

- (void)performCommand
{
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }

    [MODSpecModel sharedInstance].name = [[SDCommandLineParser sharedInstance].startingWorkingPath lastPathComponent];
    if ([[MODSpecModel sharedInstance] saveSpecification])
        sdprintln(@"Initialized modulo spec in %@", [SDCommandLineParser sharedInstance].startingWorkingPath);
    else
    {
        sdprintln(@"Unable to initialize modulo spec in %@.  Please check that write permissions are enabled.", [SDCommandLineParser sharedInstance].startingWorkingPath);
        exit(1);
    }
}

- (void)printHelp
{
    if ([MODSpecModel sharedInstance].name && ![self hasOption:@"help"])
    {
        sdprintln(@"This directory has already been initialized for use with modulo.");
    }
    else
    {
        sdprintln(@"usage: modulo init [--verbose] [--silent]");
        sdprintln(@"       modulo init --help");
    }
}

@end
