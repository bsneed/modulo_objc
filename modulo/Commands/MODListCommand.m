//
//  MODListCommand.m
//  modulo
//
//  Created by Brandon Sneed on 11/3/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODListCommand.h"

@implementation MODListCommand

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
        sdprintln(@"%@ depends on the following modules:\n", moduleName);
        
        // find the longest item in the list to use as padding
        NSNumber *spacing = [deps valueForKeyPath:@"@max.name.length"];
        
        for (MODSpecModel *item in deps)
        {
            NSString *localPath = [[MODSpecModel sharedInstance] dependencyLocalPathFromName:item.name];

            NSString *paddedName = [NSString stringWithFormat:@"%@%*c", item.name, (int)(spacing.unsignedIntegerValue - item.name.length)+1, ' '];
            
            if (item.sourcePath.length == 0)
                sdprintln(@"    %@ at %@ (No source path)", paddedName, localPath);
            else
            {
                NSString *sourcePath = [localPath stringByAppendingPathComponent:item.sourcePath];
                sdprintln(@"    %@ at %@", paddedName, sourcePath);
            }
        }
    }
}

- (void)printHelp
{
    sdprintln(@"usage: modulo list <module name>");
    sdprintln(@"       modulo list --help");
}

- (NSString *)helpDescription
{
    return @"Shows all module dependencies in a flat listing.";
}

@end
