//
//  MODMapCommand.m
//  modulo
//
//  Created by Brandon Sneed on 1/2/15.
//  Copyright (c) 2015 SetDirection. All rights reserved.
//

#import "MODMapCommand.h"

@implementation MODMapCommand

- (BOOL)checkValidityOfCommand
{
    BOOL result = NO;
    
    // they just want help, bestow it upon them.
    if ([self hasOption:@"help"])
        result = YES;
    else
    {
        if (self.arguments.count <= 1)
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
    
    MODSpecModel *instance = [MODSpecModel sharedInstance];
    NSString *moduleName = instance.name;
    
    if (self.arguments.count == 1)
    {
        moduleName = [self argumentAtIndex:0];
        instance = [MODSpecModel instanceFromName:moduleName];
    }
    
    if (!instance)
    {
        sderror(@"There is no module named %@.", moduleName);
    }
    
    NSArray *deps = instance.dependencies;
    
    if (deps.count == 0)
    {
        sdprintln(@"%@ has no dependencies.", moduleName);
    }
    else
    {
        [self dependencyMapFromSpec:instance spacing:0];
    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo map <module name>");
    sdprintln(@"       modulo map --help");
}

- (NSString *)helpDescription
{
    return @"Shows a map of module dependencies.";
}

#pragma mark - Utility methods

- (void)dependencyMapFromSpec:(MODSpecModel *)startSpec spacing:(NSUInteger)spacing
{
    //sdprintln(@"%@", startSpec.name);
    for (MODSpecModel *item in startSpec.dependencies)
    {
        NSString *paddedName = [NSString stringWithFormat:@"%*s%@", (int)spacing, "", item.name];
        
        MODSpecModel *temp = [MODSpecModel instanceFromName:item.name];
        [self flatDependencyListFromSpec:temp output:output];
    }
}

@end
