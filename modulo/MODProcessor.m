//
//  MODProcessor.m
//  modulo
//
//  Created by Brandon Sneed on 9/29/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODProcessor.h"
#import "SDCommandLineParser.h"

@implementation MODProcessor
{
    BOOL _encounteredError;
    NSMutableArray *_modifiedDependencies;
}

+ (instancetype)processor
{
    MODProcessor *processor = [[MODProcessor alloc] init];
    return processor;
}

- (instancetype)init
{
    self = [super init];
    
    _modifiedDependencies = [[NSMutableArray alloc] init];
    
    return self;
}

- (NSArray *)modifiedDependencies
{
    return [NSArray arrayWithArray:_modifiedDependencies];
}

- (void)removeDependencyNamed:(NSString *)dependencyName
{
    NSArray *dependents = [[MODSpecModel sharedInstance] dependenciesThatDependOn:dependencyName];
    if (dependents.count > 0)
    {
        sdprintln(@"The following modules depend on %@:", dependencyName);
        for (MODSpecModel *item in dependents)
        {
            sdprintln(@"    %@", item.name);
        }
        sdprintln(@"");
        sderror(@"Unable to remove %@.", dependencyName);
    }
    else
    {
        NSString *dependencyPath = [MODSpecModel sharedInstance].dependenciesPath;
        MODSpecModel *itemToRemove = [[MODSpecModel sharedInstance] dependencyNamed:dependencyName];
        if (itemToRemove)
        {
            // look at this items sub-dependencies...
            
            NSArray *itemDependents = itemToRemove.dependencies;
            for (MODSpecModel *item in itemDependents)
            {
                NSArray *subDependents = [[MODSpecModel sharedInstance] dependenciesThatDependOn:item.name excluding:itemToRemove.name];
                if (subDependents.count == 0)
                {
                    // this one doesn't have any.  so nuke it.
                    NSString *localPath = [dependencyPath stringByAppendingPathComponent:item.name];
                    [self rewindDependencyNamed:item.name localPath:localPath];
                    sdprintln(@"Removed %@, used by %@.", item.name, itemToRemove.name);
                }
                else
                {
                    // this guy is in use, skip over it and report what's happening.
                    sdprintln(@"Skipping %@ since it's still in use by:", item.name);
                    for (MODSpecModel *useItem in subDependents)
                        sdprintln(@"    %@", useItem.name);
                    sdprintln(@"");
                }
            }
            
            NSString *localPath = [dependencyPath stringByAppendingPathComponent:itemToRemove.name];
            [self rewindDependencyNamed:itemToRemove.name localPath:localPath];
            sdprintln(@"Removed %@.", itemToRemove.name);
        }
        else
        {
            sderror(@"Unable to find dependency %@", dependencyName);
        }
    }
}

- (void)addDependencyNamed:(NSString *)dependencyName moduleURL:(NSString *)moduleURL branch:(NSString *)branch
{
    MODSpecModel *dependency = [self processDependencyNamed:dependencyName moduleURL:moduleURL branch:branch];
    [_modifiedDependencies addObject:dependency];
    
    [self iterateDependency:dependency];
}

- (NSInteger)runCommand:(NSString *)command parseBlock:(MODCommandParseBlock)parseBlock
{
    if (parseBlock)
        command = [command stringByAppendingString:@" 2> modulo_temp.txt"];
    
    if (self.verbose)
        sdprintln(@"Running: %@", command);
    
    NSInteger status = system([command UTF8String]);
    //NSInteger status = 0;
    
    if (parseBlock)
    {
        NSString *outputString = [NSString stringWithContentsOfFile:@"modulo_temp.txt" encoding:NSUTF8StringEncoding error:nil];
        status = parseBlock(status, outputString);
        if (status != 0)
            sdprintln(outputString);
    }
    
    return status;
}

- (NSInteger)runCommand:(NSString *)command
{
    return [self runCommand:command parseBlock:nil];
}

- (void)rewindDependencyNamed:(NSString *)dependencyName localPath:(NSString *)dependencyLocalPath
{
    BOOL isLibrary = [dependencyLocalPath rangeOfString:@"../"].location == 0;
    
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
    
    [[MODSpecModel sharedInstance] removeDependencyNamed:dependencyName];
}

- (void)checkErrorAgainstDependencies:(NSArray *)dependencies
{
    if (_encounteredError)
    {
        for (MODSpecModel *item in dependencies)
        {
            [self rewindDependencyNamed:item.name localPath:item.localPath];
        }
        
        sderror(@"There was an error adding the requested dependency.  See log for details.\n\nRewinding changes.");
    }
}

- (void)iterateDependency:(MODSpecModel *)dependency
{
    [self checkErrorAgainstDependencies:_modifiedDependencies];
    
    if (dependency.dependencies.count > 0)
    {
        for (MODSpecModel *item in dependency.dependencies)
        {
            MODSpecModel *newDependency = [self processDependencyNamed:item.name moduleURL:item.moduleURL branch:item.initialBranch];
            [_modifiedDependencies addObject:newDependency];
            
            [self iterateDependency:newDependency];
        }
    }
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
        dependencyModel.moduleURL = moduleURL;
    
    dependencyModel.library = YES;
    dependencyModel.localPath = dependencyLocalPath;
    
    return dependencyModel;
}


@end
