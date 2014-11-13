//
//  MODBranchCommand.m
//  modulo
//
//  Created by Brandon Sneed on 10/28/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODBranchCommand.h"
#import "MODProcessor.h"

@implementation MODBranchCommand

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    // they just want help, bestow it upon them.
    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        // if they didn't specify a branch, the command is invalid.
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
    
    NSString *branchName = [self argumentAtIndex:0];
    MODProcessor *processor = [MODProcessor processor];
    processor.verbose = self.verbose;
    
    BOOL success = [processor switchBranches:branchName];
    if (!success)
    {
        sderror(@"An error occurred attempting to switch all module branches to %@.  See log for details.", branchName);
    }
    else
    {
        sdprintln(@"");
        
        NSArray *unpushable = processor.unpushableBranches;
        if (unpushable.count)
        {
            sdprintln(@"The following modules do not have git push access and were left on the branches shown:");
            for (NSString *item in unpushable)
                sdprintln(@"    %@", item);
            sdprintln(@"");
        }

    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo branch <branch name> [--verbose]");
    sdprintln(@"       modulo branch --help");
}

- (NSString *)helpDescription
{
    return @"Switches all modules with write access to the specified branch.";
}

@end
