//
//  MODUpdateCommand.m
//  modulo
//
//  Created by Brandon Sneed on 9/30/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODUpdateCommand.h"
#import "MODProcessor.h"

@implementation MODUpdateCommand

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    // they just want help, bestow it upon them.
    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        // if they didn't specify a branch, they mean 'all'.
        if (self.arguments.count == 0)
            result = YES;
        else
        // if they did, they mean to just update the one named.
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
    
    NSMutableArray *names = [NSMutableArray array];
    
    NSString *name = [self argumentAtIndex:0];
    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    
    if (name)
    {
        MODSpecModel *existing = [[MODSpecModel sharedInstance] dependencyNamed:name];
        if (!existing)
        {
            sderror(@"No module exists named %@.", name);
        }
        
        [names addObject:name];
    }
    else
    {
        [names addObjectsFromArray:[[MODSpecModel sharedInstance] dependencyNames]];
    }
    
    NSArray *unclean = nil;
    if (name)
        unclean = [processor uncleanDependenciesForName:name];
    else
        unclean = [processor uncleanDependencies];
    
    if (unclean && ![self hasOption:@"force"])
    {
        sdprintln(@"Unable to proceed.  The following modules have unpushed commits, stashes, or changes:");
        for (NSString *item in unclean)
            sdprintln(@"    %@", item);
        sderror(@"");
    }
    
    BOOL success = [processor updateDependencyNames:nil];
    if (!success)
    {
        sderror(@"An unknown error occurred attempting to remove %@.  See log for details.", name);
    }
    else
    {
        NSArray *added = processor.addedDependencies;
        NSArray *removed = processor.removedDependencies;
        
        if (added.count)
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
    sdprintln(@"usage: modulo update [<dependency name>] [--force] [--verbose]");
    sdprintln(@"       module update");
    sdprintln(@"       modulo update --help");
    sdprintln(@"");
    sdprintln(@"--force");
    sdprintln(@"    Ignores status of commits, changes, and stashes.  Removes anyway.");
}

- (NSString *)helpDescription
{
    return @"Updates the specified module, or all modules.";
}

@end
