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
        if (self.arguments.count == 0 && ![self hasOption:@"branch"])
            result = YES;
        else
        if (self.arguments.count >= 1 && self.arguments.count <= 2)
            result = YES;
    }
    
    return result;
}

- (void)performCommand
{
    /*[super performCommand];
    
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
    
    NSString *branch = nil;
    if ([self hasOption:@"branch"])
    {
        if (self.arguments.count == 1)
            branch = [self argumentAtIndex:0];
        else
            branch = [self argumentAtIndex:1];
    }
    
    NSString *repo = nil;
    if (!branch && self.arguments.count == 1)
        repo = [self argumentAtIndex:0];
    
    NSArray *modulesToUpdate = nil;
    if (repo)
        modulesToUpdate = @[repo];
    else
        modulesToUpdate = [[MODSpecModel sharedInstance].dependencies allKeys];
    
    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    [processor updateDependencies:modulesToUpdate];
    
    [[MODSpecModel sharedInstance] saveSpecification];*/
}

- (void)printHelp
{
    sdprintln(@"usage: modulo update [<dependency name>] [--branch <branch>] [--verbose]");
    sdprintln(@"       modulo update --help");
}

- (NSString *)helpDescription
{
    return @"Updates the specified module, or all modules.";
}

@end
