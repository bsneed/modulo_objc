//
//  MODCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODCommand.h"

@implementation MODCommand

//@property (nonatomic, readonly) NSUInteger supportArgumentCount;

- (BOOL)verbose
{
    if ([self hasOption:@"verbose"])
        return YES;
    return NO;
}

- (NSSet<NSString> *)supportedOptions
{
    return (NSSet<NSString> *)[NSSet setWithObjects:@"help", @"verbose", nil];
}

- (BOOL)checkValidityOfCommand
{
    return NO;
}

- (void)performCommand
{
    if (![MODSpecModel sharedInstance].isInitialized)
        sderror(@"This directory has not been initialized for modulo.");
    
    [self checkDependencyPath];
}

- (void)checkDependencyPath
{
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
}

@end
