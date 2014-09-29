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
    
    NSString *dependencyName = [self argumentAtIndex:0].lastPathComponent;
    NSString *moduleURL = [self argumentAtIndex:0];

    NSString *branch = @"master";
    if ([self hasOption:@"branch"] && self.arguments.count == 2)
        branch = [self argumentAtIndex:1];

    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    [processor addDependencyNamed:dependencyName moduleURL:moduleURL branch:branch];
    
    // filter out existing deps.
    NSArray *modifiedDependencies = processor.modifiedDependencies;
    NSMutableArray *filteredDependencies = [NSMutableArray array];
    for (MODSpecModel *item in modifiedDependencies)
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
