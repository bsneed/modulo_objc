//
//  MODRemoveCommand.m
//  modulo
//
//  Created by Brandon Sneed on 9/27/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODRemoveCommand.h"

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
    
    // do they have a dependency path set?
    NSString *dependenciesPath = [MODSpecModel sharedInstance].dependenciesPath;
    if (dependenciesPath.length == 0)
        sderror(@"The dependenciesPath value has not been set.\nUse: modulo set dependenciesPath <relative path>");
    
    // is that dependency path actually valid?
    NSString *dependenciesFullPath = [[SDCommandLineParser sharedInstance].currentWorkingPath stringByAppendingPathComponent:dependenciesPath];
    BOOL isDirectory = NO;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:dependenciesFullPath isDirectory:&isDirectory];
    
    if (pathExists && !isDirectory)
        sderror(@"The path %@ exists and isn't a directory.");
    
    if (!pathExists || !isDirectory)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dependenciesFullPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            sderror(@"There was a problem creating %@", dependenciesPath);
    }
    
    // setup path and name
    
    NSString *dependencyName = [self argumentAtIndex:0].lastPathComponent;
    dependencyName = [dependencyName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", dependencyName.pathExtension] withString:@""];
    
    if (![[MODSpecModel sharedInstance] dependencyExistsNamed:dependencyName])
        sderror(@"No dependency found named %@.");
    
    NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];

    // remove all teh tings!
    
    NSInteger status = 0;
    
    NSString *removeCommand = [NSString stringWithFormat:@"git submodule deinit -f %@", dependencyLocalPath];
    status = [self runCommand:removeCommand];
    if (status != 0)
        sderror(@"No dependency found named %@ in git.", dependencyName);
    
    // remove from spec model
    [[MODSpecModel sharedInstance] removeDependencyNamed:dependencyName];
    [[MODSpecModel sharedInstance] saveSpecification];

    NSString *cleanupCommand = [NSString stringWithFormat:@"git rm -f -r --cached %@ 2> /dev/null", dependencyLocalPath];
    [self runCommand:cleanupCommand];
    
    NSString *rmCommand = [NSString stringWithFormat:@"rm -rf %@ 2> /dev/null", dependencyLocalPath];
    [self runCommand:rmCommand];
    
    NSString *rmGitCommand = [NSString stringWithFormat:@"rm -rf .git/modules/%@ 2> /dev/null", dependencyLocalPath];
    [self runCommand:rmGitCommand];
    
    // enumerate sub dependencies
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
