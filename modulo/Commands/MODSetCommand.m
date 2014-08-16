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

- (NSSet<NSString> *)supportedFlags
{
    // -help and -v are default and the only things this guy needs.
    return [super supportedFlags];
}

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    NSString *keyName = [self argumentAtIndex:0];
    BOOL isValidKeyName = [[self supportedKeyNames] containsObject:keyName];
    
    NSString *path = [self argumentAtIndex:1];
    
    if (isValidKeyName && path)
        result = YES;
    
    if (!result)
    {
        sdprint(@"usage: modulo set <key name> <value>\n\n");
        sdprint(@"valid key names are: %@\n", [self supportedKeyNames]);
    }
    
    return result;
}

- (void)performCommand
{
}

@end
