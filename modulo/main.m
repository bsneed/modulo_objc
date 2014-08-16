//
//  main.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommandLineHelper.h"

// -abc cmd1 arg11 arg12 cmd2 -def arg21 cmd3 arg31 -xyz arg32

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *supportedCommands = @[@"cmd1", @"cmd2", @"cmd3"];
        NSArray *supportedFlags = @[@"a", @"b", @"c", @"d", @"e", @"f", @"x", @"y", @"z"];
        
        SDCommandLineHelper *commandLine = [[SDCommandLineHelper alloc] initWithSupportedCommands:(NSArray<NSString> *)supportedCommands flags:(NSArray<NSString> *)supportedFlags];

        NSLog(@"found flags: %@", commandLine.flags);
        NSLog(@"found commands: %@", commandLine.commands);
    }
    
    return 0;
}
