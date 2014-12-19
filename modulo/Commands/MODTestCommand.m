//
//  MODTestCommand.m
//  modulo
//
//  Created by Brandon Sneed on 12/18/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODTestCommand.h"

// This command is strictly for manual testing and will change pretty frequently.

@implementation MODTestCommand

- (BOOL)checkValidityOfCommand
{
    return YES;
}

- (void)performCommand
{
    NSArray *topLevelNames = [[MODSpecModel sharedInstance] namesThatDependOn:@"SDFoundation"];
    NSLog(@"%@", topLevelNames);
}

@end
