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
{
    BOOL _encounteredError;
    NSMutableArray *_addedDependencies;
}

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

- (void)rewindDependency:(NSString *)dependencyName localPath:(NSString *)dependencyLocalPath error:(NSString *)error
{
    BOOL isLibrary = [MODSpecModel sharedInstance].library;

    if (isLibrary)
    {
        // this is a library, a simple rm -rf will do.
        NSString *rmCommand = [NSString stringWithFormat:@"rm -rf %@", dependencyLocalPath];
        [self runCommand:rmCommand];
    }
    else
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
    }
}

- (void)checkErrorAgainstDependencies:(NSArray *)dependencies
{
    if (_encounteredError)
    {
        for (MODSpecModel *item in dependencies)
        {
            [self rewindDependency:item.name localPath:item.localPath error:nil];
        }
        
        sderror(@"There was an error adding the requested dependency.  See log for details.\n\nRewinding changes.");
    }
}

- (void)iterateDependency:(MODSpecModel *)dependency
{
    [self checkErrorAgainstDependencies:_addedDependencies];
    
    if (dependency.dependencies.count > 0)
    {
        for (MODSpecModel *item in dependency.dependencies)
        {
            MODSpecModel *newDependency = [self processDependencyNamed:item.name moduleURL:item.moduleURL branch:item.initialBranch];
            [_addedDependencies addObject:newDependency];
            
            [self iterateDependency:newDependency];
        }
    }
}

- (void)performCommand
{
    [super performCommand];
    
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
    
    NSString *dependencyName = [self argumentAtIndex:0].lastPathComponent;
    NSString *moduleURL = [self argumentAtIndex:0];

    NSString *branch = @"master";
    if ([self hasOption:@"branch"] && self.arguments.count == 2)
        branch = [self argumentAtIndex:1];

    _addedDependencies = [NSMutableArray array];
    
    MODSpecModel *dependency = [self processDependencyNamed:dependencyName moduleURL:moduleURL branch:branch];
    [_addedDependencies addObject:dependency];
    
    [self iterateDependency:dependency];
    
    // filter out existing deps.
    NSMutableArray *filteredDependencies = [NSMutableArray array];
    for (MODSpecModel *item in _addedDependencies)
    {
        if (![[MODSpecModel sharedInstance] dependencyExistsNamed:item.name])
        {
            [filteredDependencies addObject:item];
            [[MODSpecModel sharedInstance] addDependency:item];
        }
    }
    
    // save our file, if we got here, we're good.
    [[MODSpecModel sharedInstance] saveSpecification];

    if (filteredDependencies.count == 0)
    {
        sdprintln(@"The dependency list didn't actually change.");
    }
    else
    {
        sdprintln(@"");
        sdprintln(@"Add the following directories to your project or build paths:");
        for (MODSpecModel *item in filteredDependencies)
        {
            if (![item isKindOfClass:[MODSpecModel class]])
                continue;
            
            if (item.sourcePath.length == 0)
                sdprintln(@"    %@ (No source path specified, tell the author)", item.localPath);
            else
            {
                NSString *sourcePath = [item.localPath stringByAppendingPathComponent:item.sourcePath];
                sdprintln(@"    %@", sourcePath);
            }
        }
    }
    
    /*if ([MODSpecModel sharedInstance].otherDependencies.count > 0)
    {
        sdprintln(@"");
        sdprintln(@"The following additional dependencies must be added as well:");
        for (MODSpecOtherDependencyModel *item in [MODSpecModel sharedInstance].otherDependencies)
        {
            sdprintln(@"    %@ (usually at %@)", item.name, item.defaultPath);
        }
    }*/
    
    sdprintln(@"");

}

- (MODSpecModel *)processDependencyNamed:(NSString *)name moduleURL:(NSString *)moduleURL branch:(NSString *)branch
{
    if (branch.length == 0)
        branch = @"master";
    
    BOOL isLibrary = [MODSpecModel sharedInstance].library;
    MODSpecModel *dependencyModel = nil;
    
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
    
    NSString *dependencyName = name;
    dependencyName = [dependencyName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", dependencyName.pathExtension] withString:@""];
    NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (isLibrary)
    {
        // this repo is a library, treat it special.
        
        isDirectory = NO;
        pathExists = [[NSFileManager defaultManager] fileExistsAtPath:dependencyLocalPath isDirectory:&isDirectory];
        if (pathExists && !isDirectory)
            sderror(@"%@ exists already and isn't a directory.  Unable to add dependency.", dependencyLocalPath);
        
        // the path doesn't exist, we need to clone it.
        if (!pathExists)
        {
            // clone command
            
            NSString *cloneCommand = [NSString stringWithFormat:@"git clone -b %@ %@ %@", branch, moduleURL, dependencyLocalPath];
            status = [self runCommand:cloneCommand];
            if (status != 0)
            {
                // git submodule add failed.  Rewind changes.
                //[self rewindDependency:dependencyName localPath:dependencyLocalPath error:nil];
                _encounteredError = YES;
                goto completionLabel;
            }
        }
    }
    else
    {
        // it's not a library, so do the normal consumer stuff.
        
        // add command
        
        NSString *addCommand = [NSString stringWithFormat:@"git submodule add -b %@ %@ %@", branch, moduleURL, dependencyLocalPath];
        status = [self runCommand:addCommand];
        if (status != 0)
        {
            // git submodule add failed.  Rewind changes.
            //[self rewindDependency:dependencyName localPath:dependencyLocalPath error:nil];
            _encounteredError = YES;
            goto completionLabel;
        }

        // update command
        
        NSString *updateCommand = [NSString stringWithFormat:@"git submodule update --init --recursive %@", dependencyLocalPath];
        status = [self runCommand:updateCommand];
        if (status != 0)
        {
            // git submodule update/init failed.  Rewind changes.
            //[self rewindDependency:dependencyName localPath:dependencyLocalPath error:nil];
            _encounteredError = YES;
            goto completionLabel;
        }
        
        // gotta get back to our home directory before processing status.
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
        
        if (status != 0)
        {
            //[self rewindDependency:dependencyName localPath:dependencyLocalPath error:@"There is a problem with the checkout specified."];
            _encounteredError = YES;
            goto completionLabel;
        }
    }
    
completionLabel:
    
    dependencyModel = [MODSpecModel instanceFromPath:dependencyLocalPath];

    if (!dependencyModel)
        dependencyModel = [[MODSpecModel alloc] init];
    if (!dependencyModel.name)
        dependencyModel.name = dependencyName;
    if (!dependencyModel.moduleURL)
        dependencyModel.moduleURL = [self argumentAtIndex:0];

    dependencyModel.library = YES;
    dependencyModel.localPath = dependencyLocalPath;

    return dependencyModel;
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
    return @"Adds the specified module as a dependency.";
}


@end
