//
//  MODAddCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/18/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODAddCommand.h"

/*
 modulo add git@github.com:setdirection/ios-shared.git --branch "master"
 */

@implementation MODAddCommand

- (NSSet<NSString> *)supportedOptions
{
    NSSet *superSet = [super supportedOptions];
    NSMutableSet *newSet = [NSMutableSet setWithSet:superSet];
    [newSet addObjectsFromArray:@[@"tag", @"commit", @"head", @"branch"]];
    
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

- (void)rewindDependency:(NSString *)dependencyName localPath:(NSString *)dependencyLocalPath error:(NSString *)error
{
    // it failed, we need to rewind it.
    NSString *removeCommand = [NSString stringWithFormat:@"git submodule deinit -f %@", dependencyLocalPath];
    [self runCommand:removeCommand];
    
    NSString *cleanupCommand = [NSString stringWithFormat:@"git rm -f -r --cached %@", dependencyLocalPath];
    [self runCommand:cleanupCommand];
    
    NSString *rmCommand = [NSString stringWithFormat:@"rm -rf %@", dependencyLocalPath];
    [self runCommand:rmCommand];
    
    NSString *rmGitCommand = [NSString stringWithFormat:@"rm -rf .git/modules/%@", dependencyLocalPath];
    [self runCommand:rmGitCommand];
    
    if (error)
        sdprintln(@"error: %@", error);
    sderror(@"There was an error adding %@.  Rewinding changes.", dependencyName);
}

- (void)performCommand
{
    [super performCommand];
    
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
    
    NSInteger status = 0;
    
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
    NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    // add command
    
    NSString *branch = @"master";
    if ([self hasOption:@"branch"] && self.arguments.count == 2)
        branch = [self argumentAtIndex:1];
    NSString *addCommand = [NSString stringWithFormat:@"git submodule add -b %@ %@ %@", branch, [self argumentAtIndex:0], dependencyLocalPath];
    status = [self runCommand:addCommand];
    if (status != 0)
    {
        // git submodule add failed.  Rewind changes.
        [self rewindDependency:dependencyName localPath:dependencyLocalPath error:nil];
    }

    // update command
    
    NSString *updateCommand = [NSString stringWithFormat:@"git submodule update --init --recursive %@", dependencyLocalPath];
    status = [self runCommand:updateCommand];
    if (status != 0)
    {
        // git submodule update/init failed.  Rewind changes.
        [self rewindDependency:dependencyName localPath:dependencyLocalPath error:nil];
    }
    
    // gotta get back to our home directory before processing status.
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
    {
        [self rewindDependency:dependencyName localPath:dependencyLocalPath error:@"There is a problem with the checkout specified."];
    }
    
    // look at sub-dependencies now.
    
    
    
    // save spec file and add our module.
    MODSpecDependencyModel *dependency = [[MODSpecDependencyModel alloc] init];
    dependency.name = dependencyName;
    dependency.moduleURL = [self argumentAtIndex:0];
    dependency.localPath = dependencyLocalPath;
    [[MODSpecModel sharedInstance] addDependency:dependency];
    [[MODSpecModel sharedInstance] saveSpecification];
    
    sdprintln(@"");
    sdprintln(@"Add the following directories to your project or build paths:");
    for (MODSpecDependencyModel *item in [MODSpecModel sharedInstance].dependencies)
    {
        if (item.sourcePath.length == 0)
            sdprintln(@"    %@ (No source path specified, tell the author)", item.localPath);
        else
        {
            NSString *sourcePath = [item.localPath stringByAppendingPathComponent:item.sourcePath];
            sdprintln(@"    %@", sourcePath);
        }
    }
    
    if ([MODSpecModel sharedInstance].otherDependencies.count > 0)
    {
        sdprintln(@"");
        sdprintln(@"The following additional dependencies must be added as well:");
        for (MODSpecOtherDependencyModel *item in [MODSpecModel sharedInstance].otherDependencies)
        {
            sdprintln(@"    %@ (usually at %@)", item.name, item.defaultPath);
        }
    }
    
    sdprintln(@"");
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


@end
