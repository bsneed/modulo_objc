//
//  MODSetCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODSetCommand.h"

@implementation MODSetCommand

- (NSArray *)supportedKeyNames
{
    return @[@"dependencies",
             @"otherDependencies",
             @"name",
             @"projectUrl",
             @"licenseUrl",
             @"moduleUrl",
             @"dependenciesPath",
             @"sourcePaths"
             ];
}

- (NSSet<NSString> *)supportedOptions
{
    // -help and -v are default and the only things this guy needs.
    return [super supportedOptions];
}

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    NSString *keyName = [self argumentAtIndex:0];
    BOOL isValidKeyName = [[self supportedKeyNames] containsObject:keyName];
    
    NSString *path = [self argumentAtIndex:1];
    
    if (isValidKeyName && path)
        result = YES;
    
    if ([self hasOption:@"help"])
        result = YES;
    
    return result;
}

- (void)performCommand
{
    if ([self hasOption:@"help"])
    {
        [self printHelp];
        return;
    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo set <key name> <value> [--silent] [--verbose]");
    sdprintln(@"       modulo set --help\n");
    sdprintln(@"valid key names are: %@\n", [self supportedKeyNames]);
}

- (NSString *)helpDescription
{
    return @"Sets a specified key/value pair in modulo.spec";
}


@end
