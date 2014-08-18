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
    return @[@"name",
             @"projectURL",
             @"licenseURL",
             @"moduleURL",
             @"dependenciesPath"];
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
    
    NSString *value = [self argumentAtIndex:1];
    
    if (isValidKeyName && value)
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
    
    NSString *keyName = [self argumentAtIndex:0];
    BOOL isValidKeyName = [[self supportedKeyNames] containsObject:keyName];
    
    NSString *value = [self argumentAtIndex:1];

    if (keyName && isValidKeyName && value)
    {
        [[MODSpecModel sharedInstance] setValue:value forKey:keyName];
        if ([[MODSpecModel sharedInstance] saveSpecification])
        {
            sdprintln(@"Updated key %@ in modulo.spec in %@", keyName, [SDCommandLineParser sharedInstance].startingWorkingPath);
        }
        else
        {
            sdprintln(@"Unable to update modulo spec in %@.  Please check that write permissions are enabled.", [SDCommandLineParser sharedInstance].startingWorkingPath);
            exit(1);
        }
    }
    else
    {
        sdprintln(@"An unknown error occurred.");
        exit(1);
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
