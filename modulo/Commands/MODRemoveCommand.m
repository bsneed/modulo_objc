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

- (NSSet<NSString> *)supportedOptions
{
    NSSet *superSet = [super supportedOptions];
    NSMutableSet *newSet = [NSMutableSet setWithSet:superSet];
    [newSet addObjectsFromArray:@[@"force"]];
    
    return (NSSet<NSString> *)[NSSet setWithSet:newSet];
}

- (void)performCommand
{
    [super performCommand];
    
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
    
    NSString *name = [self argumentAtIndex:0];
    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    
    MODSpecModel *existing = [[MODSpecModel sharedInstance] dependencyNamed:name];
    NSArray *topLevelNames = [[MODSpecModel sharedInstance] namesThatDependOn:name];
    if (!existing)
    {
        sderror(@"No module exists named %@.", name);
    }
    
    if (topLevelNames)
    {
        sdprintln(@"Unable to remove %@.\n\nThe following modules still depend on it:", name);
        for (NSString *item in topLevelNames)
        {
            sdprintln(@"    %@", item);
        }
        sderror(@"");
    }
    
    NSArray *unclean = [processor uncleanDependenciesForName:name];
    if (unclean && ![self hasOption:@"force"])
    {
        sdprintln(@"Unable to proceed.  The following modules have unpushed commits, stashes, or changes:");
        for (NSString *item in unclean)
            sdprintln(@"    %@", item);
        sderror(@"");
    }

    BOOL success = [processor removeDependencyNamed:name];
    if (!success)
    {
        sderror(@"An unknown error occurred attempting to remove %@.  See log for details.", name);
    }
    else
    {
        NSArray *removed = processor.removedDependencies;
        if (removed.count)
        {
            sdprintln(@"The following modules were removed:");
            for (NSString *item in removed)
                sdprintln(@"    %@", item);
            sdprintln(@"");
        }
        
        [[MODSpecModel sharedInstance] removeDependencyNamed:name];
        [[MODSpecModel sharedInstance] saveSpecification];
    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo remove <module name> [--force] [--verbose]");
    sdprintln(@"       modulo remove --help");
    sdprintln(@"");
    sdprintln(@"--force");
    sdprintln(@"    Ignores status of commits, changes, and stashes.  Removes anyway.");
    
    sdprintln(@"");
}

- (NSString *)helpDescription
{
    return @"Removes the specified module as a dependency.";
}


@end
