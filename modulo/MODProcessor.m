//
//  MODProcessor.m
//  modulo
//
//  Created by Brandon Sneed on 9/29/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODProcessor.h"
#import "SDCommandLineParser.h"
#import "NSFileManager+MODExtensions.h"

@implementation MODProcessor
{
    NSMutableArray *_addedDependencies;
    NSMutableArray *_removedDependencies;
    NSMutableArray *_possiblyUnusedDependencies;
    NSMutableArray *_updatedDependencies;
    NSMutableArray *_unpushableBranches;
    
    NSMutableArray *_itemsToBeRemoved;
    
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
    
    _addedDependencies = [NSMutableArray array];
    _removedDependencies = [NSMutableArray array];
    _possiblyUnusedDependencies = [NSMutableArray array];
    _updatedDependencies = [NSMutableArray array];
    _itemsToBeRemoved = [NSMutableArray array];
    _unpushableBranches = [NSMutableArray array];
    
    _fileManager = [NSFileManager defaultManager];
    
    return self;
}

#pragma mark - Public Properties

- (NSArray *)addedDependencies
{
    return [NSArray arrayWithArray:_addedDependencies];
}

- (NSArray *)removedDependencies
{
    return [NSArray arrayWithArray:_removedDependencies];
}

- (NSArray *)possiblyUnusedDependencies
{
    return [NSArray arrayWithArray:_possiblyUnusedDependencies];
}

- (NSArray *)updatedDependencies
{
    return [NSArray arrayWithArray:_updatedDependencies];
}

- (NSArray *)unpushableBranches
{
    return [NSArray arrayWithArray:_unpushableBranches];
}

#pragma mark - Public Methods

- (BOOL)addDependencyWithModuleURL:(NSString *)moduleURL branch:(NSString *)branch;
{
    BOOL result = YES;
    NSString *name = [moduleURL nameFromModuleURL];
    
    NSInteger status = 0;
    MODSpecModel *dependencyModel = nil;
    
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    BOOL isLibrary = [dependencyLocalPath isLibraryPath];
    
    BOOL isDirectory = NO;
    BOOL pathExists = [_fileManager fileExistsAtPath:dependencyLocalPath isDirectory:&isDirectory];
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
    
    if (result)
    {
        for (MODSpecModel *item in dependencyModel.dependencies)
        {
            result = [self addDependencyWithModuleURL:item.moduleURL branch:item.initialBranch];
            if (!result)
                break;
        }
    }
    
    if ([[MODSpecModel sharedInstance] addDependency:dependencyModel])
    {
        if (![_addedDependencies containsObject:dependencyModel])
            [_addedDependencies addObject:dependencyModel];
    }
    else
    {
        // it exists already, just update it.
        [[MODSpecModel sharedInstance] updateDependency:dependencyModel];
    }
    
    return result;
}

- (BOOL)removeDependencyNamed:(NSString *)name
{
    BOOL result = YES;
    
    MODSpecModel *existing = [[MODSpecModel sharedInstance] dependencyNamed:name];
    if (!existing)
        result = NO;
    
    if (result)
    {
        // get our depNames before we remove it.
        NSArray<NSString> *names = [existing dependencyNames];
        for (NSString *item in names)
        {
            if ([item isEqualToString:name])
                continue;
            
            NSMutableArray *otherDeps = [[[MODSpecModel sharedInstance] namesThatDependOn:item] mutableCopy];
            if (otherDeps)
            {
                [otherDeps removeObjectsInArray:names];
                [otherDeps removeObject:name];
                if (otherDeps.count)
                    [_possiblyUnusedDependencies addObjectsFromArray:otherDeps];
                else
                    [_possiblyUnusedDependencies addObject:item];
            }
            else
                [_possiblyUnusedDependencies addObject:item];
            
        }

        [self _removeDependency:name];
    }
    
    return result;
}

- (BOOL)updateDependencyNames:(NSArray<NSString> *)names
{
    BOOL result = NO;
    
    for (NSString *item in names)
    {
        result = [self _updateDependencyNamed:item skipRemove:YES];
        if (!result)
            break;
    }
    
    if (_itemsToBeRemoved.count)
    {
        //for (NSString *item in _itemsToBeRemoved)
        //    [self removeDependencyNamed:item];
        [_possiblyUnusedDependencies addObjectsFromArray:_itemsToBeRemoved];
    }
    
    // sync our main project submodules if it's not a module.
    if (![[MODSpecModel sharedInstance].dependenciesPath isLibraryPath])
    {
        NSInteger status = [self runCommand:@"git submodule sync"];
        if (status != 0)
            result = NO;
    }
    
    return result;
}

- (BOOL)switchBranches:(NSString *)branchName
{
    BOOL result = YES;
    
    result = [self _switchName:nil toBranch:branchName];
    
    if (result)
    {
        NSArray<MODSpecModel> *dependencies = [MODSpecModel sharedInstance].dependencies;
        for (MODSpecModel *item in dependencies)
        {
            result = [self _switchName:item.name toBranch:branchName];
        }
    }
    
    return result;
}

#pragma mark - Running Commands

- (NSInteger)runCommand:(NSString *)command parseBlock:(MODCommandParseBlock)parseBlock
{
    // lets print the command without the redirection stuff.
    if (self.verbose)
        sdprintln(@"Running: %@", command);
    
    NSString *tempFile = [_fileManager temporaryFile];

    if (parseBlock)
        command = [command stringByAppendingFormat:@" &> %@", tempFile];
    
    NSInteger status = system([command UTF8String]);
    
    if (parseBlock)
    {
        NSString *outputString = [NSString stringWithContentsOfFile:tempFile encoding:NSUTF8StringEncoding error:nil];
        status = parseBlock(status, outputString);
        if (status != 0)
            sdprintln(outputString);
        [_fileManager removeItemAtPath:tempFile error:nil];
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
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block NSString *branch = nil;
    NSInteger status = [self runCommand:@"git rev-parse --abbrev-ref HEAD" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        if (returnStatus == 0)
            branch = [outputString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
        return returnStatus;
    }];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return branch;
}

- (BOOL)hasOutstandingPushesForName:(NSString *)name
{
    NSString *branch = [self currentBranchForName:name];
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    NSString *command = [NSString stringWithFormat:@"git rev-list origin/%@...%@", branch, branch];
    __block BOOL hasPushesToDo = NO;
    NSInteger status = [self runCommand:command parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        hasPushesToDo = (outputString.length != 0);
        return returnStatus;
    }];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasPushesToDo;
}

- (BOOL)hasStashesForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block BOOL hasStashes = NO;
    NSInteger status = [self runCommand:@"git stash list" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        hasStashes = (outputString.length != 0);
        return returnStatus;
    }];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasStashes;
}

- (BOOL)hasOutstandingChangesForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block BOOL hasChanges = YES;
    NSInteger status = [self runCommand:@"git status" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        if ([outputString rangeOfString:@"nothing to commit"].location != NSNotFound)
            hasChanges = NO;
        return returnStatus;
    }];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasChanges;
}

- (BOOL)hasPushAccessForName:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    // get into our dependency dir
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    __block BOOL hasPushAccess = NO;
    NSInteger status = [self runCommand:@"git push --dry-run" parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
        if (![outputString containsString:@"Permission to"] && ![outputString containsString:@"denied to"])
            hasPushAccess = YES;
        return 0;
    }];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"Unable to determine the current branch for %@.", name);
    
    return hasPushAccess;
}

- (NSArray<NSString> *)uncleanDependencies
{
    return [self uncleanDependenciesForName:nil];
}

- (NSArray<NSString> *)uncleanDependenciesForName:(NSString *)name
{
    NSMutableArray *uncleanDeps = [NSMutableArray array];
    NSMutableArray *deps = [NSMutableArray array];
    if (name && name.length > 0)
    {
        [deps addObject:name]; // Check the top level dependency also
        [deps addObjectsFromArray:[[MODSpecModel sharedInstance] namesThatDependOn:name]];
    }
    else
    {
        [deps addObjectsFromArray:[[MODSpecModel sharedInstance] dependencyNames]];
    }
    
    for (NSString *item in deps)
    {
        BOOL hasStashes = [self hasStashesForName:item];
        BOOL hasCommitsToPush = [self hasOutstandingPushesForName:item];
        BOOL hasChangesToCommit = [self hasOutstandingChangesForName:item];
        
        if (hasStashes || hasCommitsToPush || hasChangesToCommit)
            [uncleanDeps addObject:item];
    }
    
    if (uncleanDeps.count)
        return (NSArray<NSString> *)[NSArray arrayWithArray:uncleanDeps];
    
    return nil;
}

#pragma mark - Internal utlities

- (void)_removeDependency:(NSString *)name
{
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];

    BOOL isLibrary = [dependencyLocalPath isLibraryPath];
    
    // if it's not a library, we need to muck with git a little.
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
    
    NSString *rmCommand = [NSString stringWithFormat:@"rm -rf %@", dependencyLocalPath];
    [self runCommand:rmCommand];
    
    [[MODSpecModel sharedInstance] removeDependencyNamed:name];
    [_removedDependencies addObject:name];
}

- (BOOL)_updateDependencyNamed:(NSString *)name skipRemove:(BOOL)skipRemove
{
    BOOL result = YES;
    
    sdprintln(@"Updating %@...", name);
    
    NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
    
    MODSpecModel *originalSpec = [MODSpecModel instanceFromPath:dependencyLocalPath];
    
    // get into our dependency dir
    [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
    
    // update that mofo.
    NSInteger status = [self runCommand:@"git pull --recurse-submodules"];
    
    // update any sub-submodules
    if (status == 0)
        status = [self runCommand:@"git submodule update --recursive"];
    
    // synchronize any sub-submodules
    if (status == 0)
        status = [self runCommand:@"git submodule sync"];
    
    // get back home.
    [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    if (status != 0)
        sderror(@"There was a problem updating %@.  See the log for details.  After correcting the issue, re-run this command.", name);
    
    MODSpecModel *updatedSpec = [MODSpecModel instanceFromPath:dependencyLocalPath];
    
    NSMutableArray *originalNames = [[originalSpec dependencyNames] mutableCopy];
    NSMutableArray *updatedNames = [[updatedSpec dependencyNames] mutableCopy];
    
    // update the items in our current spec with the changes we just got.
    for (NSString *item in updatedNames)
    {
        MODSpecModel *updatedDep = [updatedSpec dependencyNamed:item];
        [[MODSpecModel sharedInstance] updateDependency:updatedDep];
    }
    
    // find out which deps have been added
    NSMutableArray *addedNames = [updatedNames mutableCopy];
    [addedNames removeObjectsInArray:originalNames];
    
    // find out which deps have been removed.
    NSMutableArray *removedNames = [originalNames mutableCopy];
    [removedNames removeObjectsInArray:updatedNames];
    
    if (addedNames.count)
    {
        for (NSString *item in updatedNames)
        {
            MODSpecModel *updatedDep = [updatedSpec dependencyNamed:item];
            result = [self addDependencyWithModuleURL:updatedDep.moduleURL branch:updatedDep.initialBranch];
        }
    }
    
    if (removedNames.count && result)
    {
        if (!skipRemove)
        {
            for (NSString *item in removedNames)
            {
                // we don't care if this fails .. it'll only actually get removed if
                // nothing else depends on it.
                [self removeDependencyNamed:item];
            }
        }
        else
        {
            // put these names someplace so we can remove them later.
            [_itemsToBeRemoved addObjectsFromArray:removedNames];
        }
    }
    
    return result;
}

- (BOOL)_switchName:(NSString *)name toBranch:(NSString *)branchName
{
    BOOL result = YES;
    NSInteger status = 0;
    
    // if no name was specified, we're working on the main repo and not a dependency.
    if (!name)
    {
        // change branches in the local repo.
        
        __block BOOL alreadyExists = NO;
        NSString *command = [NSString stringWithFormat:@"git checkout -b %@", branchName];
        status = [self runCommand:command parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
            if ([outputString containsString:@" already exists."])
            {
                alreadyExists = YES;
                returnStatus = 0;
            }
            return returnStatus;
        }];
        
        // it already exists, so try to just change to it.
        if (alreadyExists)
        {
            NSString *newCommand = [NSString stringWithFormat:@"git checkout %@", branchName];
            status = [self runCommand:newCommand parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
                if ([outputString containsString:@"Switched to branch"])
                    returnStatus = 0;
                else
                    if ([outputString containsString:@"Already on"])
                        returnStatus = 0;
                    else
                        sdprintln(outputString);
                return returnStatus;
            }];
        }
    }
    else
    {
        // change branches on the specified module.
        
        if (![self hasPushAccessForName:name])
        {
            NSString *currentBranchName = [self currentBranchForName:name];
            NSString *nameWithCurrentBranch = [NSString stringWithFormat:@"%@ (%@)", name, currentBranchName];
            [_unpushableBranches addObject:nameWithCurrentBranch];
            return result;
        }
        
        NSString *dependencyLocalPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:name];
        
        // get into our dependency dir
        [_fileManager changeCurrentDirectoryPath:dependencyLocalPath];
        
        __block BOOL alreadyExists = NO;
        NSString *command = [NSString stringWithFormat:@"git checkout -b %@", branchName];
        status = [self runCommand:command parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
            if ([outputString containsString:@" already exists."])
            {
                alreadyExists = YES;
                returnStatus = 0;
            }
            return returnStatus;
        }];
        
        // it already exists, so try to just change to it.
        if (alreadyExists)
        {
            NSString *newCommand = [NSString stringWithFormat:@"git checkout %@", branchName];
            status = [self runCommand:newCommand parseBlock:^NSInteger(NSInteger returnStatus, NSString *outputString) {
                if ([outputString containsString:@"Switched to branch"])
                    returnStatus = 0;
                else
                    if ([outputString containsString:@"Already on"])
                        returnStatus = 0;
                    else
                        sdprintln(outputString);
                return returnStatus;
            }];
        }
        
        // get back home.
        [_fileManager changeCurrentDirectoryPath:[SDCommandLineParser sharedInstance].startingWorkingPath];
    }
    
    if (status != 0)
    {
        result = NO;
        sdprintln(@"Unable to switch module %@ to branch %@.", name, branchName);
        sderror(@"\nPlease fix the issue and re-run this command.  See log for details.");
    }
    else
    {
        if (!name)
            sdprintln(@"Switched %@ to branch %@", [MODSpecModel sharedInstance].name, branchName);
        else
            sdprintln(@"Switched module %@ to branch %@", name, branchName);
    }
    
    return result;
}

@end
