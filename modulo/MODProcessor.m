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
    NSMutableArray *_addedDependencies;
    NSMutableArray *_removedDependencies;
    NSMutableArray *_updatedDependencies;
    NSMutableArray *_uncleanDependencies;
    
    NSFileManager *_fileManager;
}

#pragma mark - Public methods

+ (instancetype)processor
{
    MODProcessor *processor = [[MODProcessor alloc] init];
    return processor;
}

- (instancetype)init
{
    self = [super init];
    
    _startingDependencyName = nil;
    _addedDependencies = [NSMutableArray array];
    _removedDependencies = [NSMutableArray array];
    _updatedDependencies = [NSMutableArray array];
    _uncleanDependencies = [NSMutableArray array];
    
    _fileManager = [NSFileManager defaultManager];
    
    return self;
}

- (NSArray *)addedDependencies
{
    return [NSArray arrayWithArray:_addedDependencies];
}

- (NSArray *)removedDependencies
{
    return [NSArray arrayWithArray:_removedDependencies];
}

- (NSArray *)updatedDependencies
{
    return [NSArray arrayWithArray:_updatedDependencies];
}

- (NSArray *)uncleanDependencies
{
    return [NSArray arrayWithArray:_uncleanDependencies];
}

- (BOOL)addDependencyWithModuleURL:(NSString *)moduleURL branch:(NSString *)branch;
{
    BOOL result = YES;
    NSString *name = [moduleURL nameFromModuleURL];
    
    if (!_startingDependencyName)
        _startingDependencyName = [name copy];
    
    NSInteger status = 0;
    MODSpecModel *dependencyModel = nil;
    
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    BOOL isLibrary = [dependencyLocalPath isLibraryPath];
    
    BOOL isDirectory = NO;
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:dependencyLocalPath isDirectory:&isDirectory];
    if (pathExists && !isDirectory)
    {
        sdprintln(@"%@ exists already and isn't a directory.  Unable to add dependency.", dependencyLocalPath);
        result = NO;
        goto completionLabel;
    }
    
    // the path doesn't exist, we need to clone it.
    if (!pathExists)
    {
        if (isLibrary)
        {
            // this repo is a library, treat it special.
            
            // clone command
            
            NSString *cloneCommand = [NSString stringWithFormat:@"git clone -b %@ %@ %@", branch, moduleURL, dependencyLocalPath];
            status = [self runCommand:cloneCommand];
            if (status != 0)
            {
                // git submodule add failed.  Rewind changes.
                result = NO;
                goto completionLabel;
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
                result = NO;
                goto completionLabel;
            }
            
            // update command
            
            NSString *updateCommand = [NSString stringWithFormat:@"git submodule update --init --recursive %@", dependencyLocalPath];
            status = [self runCommand:updateCommand];
            if (status != 0)
            {
                // git submodule update/init failed.  Rewind changes.
                result = NO;
                goto completionLabel;
            }
            
            if (status != 0)
            {
                result = NO;
                goto completionLabel;
            }
        }
    }
    
completionLabel:
    
    dependencyModel = [MODSpecModel instanceFromPath:dependencyLocalPath];
    
    if (!dependencyModel)
        dependencyModel = [[MODSpecModel alloc] init];
    if (!dependencyModel.name)
        dependencyModel.name = name;
    if (!dependencyModel.moduleURL)
        dependencyModel.moduleURL = moduleURL;

    if (![_addedDependencies containsObject:dependencyModel])
        [_addedDependencies addObject:dependencyModel];
    
    if (result)
    {
        for (MODSpecModel *item in dependencyModel.dependencies)
        {
            result = [self addDependencyWithModuleURL:item.moduleURL branch:item.initialBranch];
            if (!result)
                break;
//            else
//            {
//                [[MODSpecModel sharedInstance] addDependency:item];
//            }
        }
    }
    
    return result;
}

- (BOOL)removeDependencyNamed:(NSString *)name
{
    if (!_startingDependencyName)
        _startingDependencyName = [name copy];
    
    BOOL result = YES;

    MODSpecModel *existing = [[MODSpecModel sharedInstance] topLevelDependencyNamed:name];
    if (!existing)
        result = NO;

    if (result)
    {
        NSArray<NSString> *names = [existing flatDependencyList];
        NSMutableArray *namesToProcess = [NSMutableArray array];
        
        // add the main one we're working on to the list.
        // we would have checked before getting here that no other top-levels depend on it.
        [namesToProcess addObject:name];
        
        if (names)
        {
            // if something else depends on this sub-dep we've been asked to remove
            // cycle through the other top level ones, and if they depend on it,
            // remove it from our list of things to process.
            for (NSString *item in names)
            {
                NSArray *otherDepNames = [[MODSpecModel sharedInstance] topLevelNamesThatDependOn:item];
                if (!otherDepNames)
                    [namesToProcess addObject:item];
            }
        }
        
        
        if (namesToProcess.count > 0)
        {
            for (NSString *item in namesToProcess)
            {
                [self _removeDependency:item];
            }
        }
    }
    
    return result;
}

- (BOOL)updateDependencNamed:(NSString *)name
{
    if (!_startingDependencyName)
        _startingDependencyName = [name copy];
    
    return NO;
}

#pragma mark - Running Commands

- (NSInteger)runCommand:(NSString *)command parseBlock:(MODCommandParseBlock)parseBlock
{
    if (parseBlock)
        command = [command stringByAppendingString:@" &> .modulo_temp.txt"];
    
    if (self.verbose)
        sdprintln(@"Running: %@", command);
    
    NSInteger status = system([command UTF8String]);
    //NSInteger status = 0;
    
    if (parseBlock)
    {
        NSString *outputString = [NSString stringWithContentsOfFile:@".modulo_temp.txt" encoding:NSUTF8StringEncoding error:nil];
        status = parseBlock(status, outputString);
        if (status != 0)
            sdprintln(outputString);
        [[NSFileManager defaultManager] removeItemAtPath:@".modulo_temp.txt" error:nil];
    }
    
    return status;
}

- (NSInteger)runCommand:(NSString *)command
{
    return [self runCommand:command parseBlock:nil];
}

#pragma mark - Git callouts

- (NSString *)currentBranchForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block NSString *branch = nil;
    NSInteger status = [self runCommand:@"git rev-parse --abbrev-ref HEAD" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        if (returnStatus == 0)
            branch = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        return returnStatus;
    }];
    
    // get back home.
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return branch;
}

- (BOOL)hasOutstandingPushesForName:(NSString *)name
{
    NSString *branch = [self currentBranchForName:name];
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dependencyLocalPath];
    
    NSString *command = [NSString stringWithFormat:@"git rev-list origin/%@...%@", branch, branch];
    __block BOOL hasPushesToDo = NO;
    NSInteger status = [self runCommand:command parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        hasPushesToDo = (outputString.length != 0);
        return returnStatus;
    }];
    
    // get back home.
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasPushesToDo;
}

- (BOOL)hasStashesForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block BOOL hasStashes = NO;
    NSInteger status = [self runCommand:@"git stash list" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        hasStashes = (outputString.length != 0);
        return returnStatus;
    }];
    
    // get back home.
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasStashes;
}

- (BOOL)hasOutstandingChangesForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block BOOL hasChanges = NO;
    NSInteger status = [self runCommand:@"git status" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        hasChanges = NO;
        if ([outputString rangeOfString:@"nothing to commit"].location == NSNotFound)
            hasChanges = YES;
        return returnStatus;
    }];
    
    // get back home.
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasChanges;
}

#pragma mark - Internal utlities

- (void)_removeDependency:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];

    BOOL isLibrary = [dependencyLocalPath isLibraryPath];
    
    BOOL hasStashes = [self hasStashesForName:name];
    BOOL hasCommitsToPush = [self hasOutstandingPushesForName:name];
    BOOL hasChangesToCommit = [self hasOutstandingChangesForName:name];
    
    if (!isLibrary)
    {
        // it failed, we need to rewind it.
        NSString *removeCommand = [NSString stringWithFormat:@"git submodule deinit -f %@", dependencyLocalPath];
        [self runCommand:removeCommand];
        
        NSString *cleanupCommand = [NSString stringWithFormat:@"git rm -f -r --cached %@", dependencyLocalPath];
        [self runCommand:cleanupCommand];
        
        NSString *rmGitCommand = [NSString stringWithFormat:@"rm -rf .git/modules/%@", dependencyLocalPath];
        [self runCommand:rmGitCommand];
    }
    
    if (hasStashes || hasCommitsToPush || hasChangesToCommit)
    {
        [_uncleanDependencies addObject:name];
    }
    else
    {
        // there's nothing pending, blow it away.
        NSString *rmCommand = [NSString stringWithFormat:@"rm -rf %@", dependencyLocalPath];
        [self runCommand:rmCommand];
        [_removedDependencies addObject:name];
    }
}

/*

- (void)updateDependencies:(NSArray *)dependencies
{
    NSString *dependenciesPath = [MODSpecModel sharedInstance].dependenciesPath;
    if (dependenciesPath.length == 0)
        sderror(@"The dependenciesPath value has not been set.\nUse: modulo set dependenciesPath <relative path>");

    NSString *dependenciesFullPath = [[SDCommandLineParser sharedInstance].currentWorkingPath stringByAppendingPathComponent:dependenciesPath];

    // do a plain jane update of the dependencies first..
    for (NSString *item in dependencies)
    {
        NSString *dependencyName = item;
        sdprintln(@"Updating %@...", dependencyName);
        
        NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];

        // get into our dependency dir
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:dependencyLocalPath];
        
        // update that mofo.
        NSInteger status = [self runCommand:@"git pull -u"];
        
        // get back home.
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
        
        if (status != 0)
            sderror(@"There was a problem updating %@.  See the log for details.  After correcting the issue, re-run this command.", dependencyName);
    }
    
    // cycle through the deps and open up their spec file and see if any new dependencies were added or removed.
    for (NSString *item in dependencies)
    {
        NSString *dependencyName = item;
        NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];

        MODSpecModel *startSpec = [[MODSpecModel sharedInstance] dependencyNamed:dependencyName];
        MODSpecModel *endSpec = [MODSpecModel instanceFromPath:dependencyLocalPath];
        
        NSMutableArray *addedDeps = [NSMutableArray array];
        NSMutableArray *removedDeps = [NSMutableArray array];
        
        // if we enum the startSpec, and find something that doesn't exist in endSpec, it means that dep has been REMOVED.
        for (MODSpecModel *dep in startSpec.dependencies)
        {
            BOOL existsInOtherSpec = [endSpec dependencyExistsNamed:dep.name];
            if (!existsInOtherSpec)
                [removedDeps addObject:dep];
        }
        
        // if we enum the endSpec, and find something that doesn't exist in startSpec, it means that dep has been ADDED.
        for (MODSpecModel *dep in endSpec.dependencies)
        {
            BOOL existsInOtherSpec = [startSpec dependencyExistsNamed:dep.name];
            if (!existsInOtherSpec)
                [addedDeps addObject:dep];
        }
        
        // ADD dependencies
        
        // add first, if it fails, it prevents us from removing other stuff since we exit.
        for (MODSpecModel *dep in addedDeps)
        {
            [self addDependencyNamed:dep.name moduleURL:dep.moduleURL branch:dep.initialBranch];
        }
        
        // REMOVE dependencies
        
        for (MODSpecModel *dep in removedDeps)
        {
            NSArray *dependents = [[MODSpecModel sharedInstance] dependenciesThatDependOn:dep.name];
            if (dependents.count > 0)
                continue;
            
            [self removeDependencyNamed:dep.name];
        }
        
        [[MODSpecModel sharedInstance] replaceDependency:startSpec withDependency:endSpec];
    }
}*/

@end
