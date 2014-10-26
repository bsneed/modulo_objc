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
    
    NSString *name = [self argumentAtIndex:0];
    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    
    MODSpecModel *existing = [[MODSpecModel sharedInstance] topLevelDependencyNamed:name];
    NSArray *topLevelNames = [[MODSpecModel sharedInstance] topLevelNamesThatDependOn:name];
    if (!existing)
    {
        sderror(@"No top-level module exists named %@.", name);
    }
    
    if (topLevelNames)
    {
        sdprintln(@"Unable to remove %@.\n\nThe following top-level modules still depend on it:", name);
        for (NSString *item in topLevelNames)
        {
            sdprintln(@"    %@", item);
        }
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
        NSArray *unclean = processor.uncleanDependencies;
        
        if (removed.count)
        {
            sdprintln(@"The following modules were removed:");
            for (NSString *item in removed)
                sdprintln(@"    %@", item);
            sdprintln(@"");
        }
        
        if (unclean.count)
        {
            sdprintln(@"The following modules were removed but not deleted because they have stashes, changes, or commits that have not been pushed:");
            for (NSString *item in unclean)
                sdprintln(@"    %@", item);
            sdprintln(@"");
        }
        
        [[MODSpecModel sharedInstance] removeTopLevelDependencyNamed:name];
        [[MODSpecModel sharedInstance] saveSpecification];
    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo remove <module name> [--verbose]");
    sdprintln(@"       modulo remove --help");
}

- (NSString *)helpDescription
{
    return @"Removes the specified module as a dependency.";
}


@end
