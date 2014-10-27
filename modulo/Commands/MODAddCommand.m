//
//  MODAddCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/18/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODAddCommand.h"
#import "MODProcessor.h"

/*
 modulo add git@github.com:setdirection/ios-shared.git --branch "master"
 
 // tests
 
 - add clean new dep.
 - add clean new dep w/ sub deps.
 - add new dep that exists already as a sub dep.
 - add clean new dep that fails.
 - add clean new dep w/ sub deps that fail.

 
 */

@implementation MODAddCommand

- (NSSet<NSString> *)supportedOptions
{
    NSSet *superSet = [super supportedOptions];
    NSMutableSet *newSet = [NSMutableSet setWithSet:superSet];
    [newSet addObjectsFromArray:@[@"branch"]];
    
    return (NSSet<NSString> *)[NSSet setWithSet:newSet];
}

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    // they just want help, bestow it upon them.
    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        if ([self hasOption:@"branch"] && self.arguments.count == 2)
            result = YES;
        else
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
    
    NSString *moduleURL = [self argumentAtIndex:0];

    NSString *branch = @"master";
    if ([self hasOption:@"branch"] && self.arguments.count == 2)
        branch = [self argumentAtIndex:1];

    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    
    BOOL success = NO;
    
    NSString *name = [moduleURL nameFromModuleURL];
    MODSpecModel *existing = [[MODSpecModel sharedInstance] dependencyNamed:name];
    if (existing)
    {
        sderror(@"A dependency named %@ already exists.", name);
    }
    
    success = [processor addDependencyWithModuleURL:moduleURL branch:branch];
    if (!success)
    {
        [processor removeDependencyNamed:name];
        sderror(@"\nThere was an error adding %@.  See log for details.\n\nAll pending changes were reversed.", name);
    }
    else
    {
        NSArray *added = processor.addedDependencies;
        
        if (added.count == 0)
        {
            sdprintln(@"The dependency list didn't actually change.");
        }
        else
        {
            sdprintln(@"");
            sdprintln(@"Add the following directories to your project or build paths:");
            
            for (MODSpecModel *item in added)
            {
                if (![item isKindOfClass:[MODSpecModel class]])
                    continue;
                
                NSString *localPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:item.name];

                if (item.sourcePath.length == 0)
                    sdprintln(@"    %@ (No source path specified, tell the author)", localPath);
                else
                {
                    NSString *sourcePath = [localPath stringByAppendingPathComponent:item.sourcePath];
                    sdprintln(@"    %@", sourcePath);
                }
            }
            
            sdprintln(@"");
        }
        
        [[MODSpecModel sharedInstance] saveSpecification];
    }

    sdprintln(@"");
}

- (void)printHelp
{
    sdprintln(@"usage: modulo add <git repo url> [--branch <branch>] [--verbose]");
    sdprintln(@"       modulo add --help");
}

- (NSString *)helpDescription
{
    return @"Adds the specified module as a dependency.";
}


@end
