//
//  MODInitCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODInitCommand.h"

static NSString *DEPENDENCIES_FOLDER_NAME = @"modules";
static NSString *INITIAL_BRANCH_NAME      = @"master";
static NSString *COMMAND_HELP             = @"help"; // This should be an extern

@implementation MODInitCommand

- (NSSet<NSString> *)supportedOptions
{
    NSSet *superSet = [super supportedOptions];
    NSMutableSet *newSet = [NSMutableSet setWithSet:superSet];
    [newSet addObjectsFromArray:@[@"module"]];
    
    return (NSSet<NSString> *)[NSSet setWithSet:newSet];
}

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;

    // they just want help, bestow it upon them.
    if ([self hasOption:COMMAND_HELP])
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
    if ([self hasOption:COMMAND_HELP])
    {
        [self printHelp];
        return;
    }

    [MODSpecModel sharedInstance].name = [[SDCommandLineParser sharedInstance].startingWorkingPath lastPathComponent];
    if ([self hasOption:@"module"])
    {
        [MODSpecModel sharedInstance].dependenciesPath = @"../";
        [MODSpecModel sharedInstance].sourcePath = [MODSpecModel sharedInstance].name;
        [MODSpecModel sharedInstance].initialBranch = INITIAL_BRANCH_NAME;
    }
    else
    {
        [MODSpecModel sharedInstance].dependenciesPath = DEPENDENCIES_FOLDER_NAME;
    }
    
    if ([[MODSpecModel sharedInstance] saveSpecification])
        sdprintln(@"Initialized modulo spec in %@", [SDCommandLineParser sharedInstance].startingWorkingPath);
    else
    {
        // TODO: maybe check for other things here so we can be more specific in the error we report?
        sdprintln(@"Unable to initialize modulo spec in %@.  Please check that write permissions are enabled.", [SDCommandLineParser sharedInstance].startingWorkingPath);
        exit(1);
    }
}

- (void)printHelp
{
    if ([MODSpecModel sharedInstance].name && ![self hasOption:COMMAND_HELP])
    {
        sdprintln(@"This directory has already been initialized for use with modulo.");
    }
    else
    {
        sdprintln(@"usage: modulo init [--module] [--verbose]");
        sdprintln([NSString stringWithFormat:@"       modulo init --%@", COMMAND_HELP]);
    }
}

- (NSString *)helpDescription
{
    return @"Initializes modulo for use.";
}


@end
