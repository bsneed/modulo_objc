//
//  MODRemoveCommand.m
//  modulo
//
//  Created by Brandon Sneed on 9/27/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODRemoveCommand.h"
#import "MODProcessor.h"

@implementation MODRemoveCommand

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    // they just want help, bestow it upon them.
    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        if (self.arguments.count == 1)
            result = YES;
    }
    
    return result;
}

- (void)performCommand
{
    [super performCommand];
    
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
    
    NSString *dependencyName = [self argumentAtIndex:0];
    if ([[MODSpecModel sharedInstance] dependencyExistsNamed:dependencyName])
    {
        MODProcessor *processor = [MODProcessor processor];
        [processor removeDependencyNamed:dependencyName];
        
        [[MODSpecModel sharedInstance] saveSpecification];
    }
    else
    {
        sderror(@"No dependency exists named %@", dependencyName);
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
        sdprintln(@"usage: modulo add [--verbose] [--silent]");
        sdprintln(@"       modulo add --help");
    }
}

- (NSString *)helpDescription
{
    return @"Removes the specified module as a dependency.";
}


@end
