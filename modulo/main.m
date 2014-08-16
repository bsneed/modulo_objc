//
//  main.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommandLineParser.h"
#import "MODSetCommand.h"

// -abc cmd1 arg1 arg2 -def -all arg3

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //NSArray *supportedCommands = @[@"cmd1", @"cmd2", @"cmd3"];
        //NSArray *supportedFlags = @[@"all", @"a", @"b", @"c", @"d", @"e", @"f", @"x", @"y", @"z"];
        
        MODCommand *cmd1 = [MODCommand commandWithName:@"cmd1" primary:YES];
        MODSetCommand *setCommand = [MODSetCommand commandWithName:@"set" primary:YES];
        
        SDCommandLineParser *commandLine = [SDCommandLineParser sharedInstance];
        [commandLine addSupportedCommands:(NSArray<SDCommand> *)@[cmd1, setCommand]];
        [commandLine processCommandLine];

        NSLog(@"found command: %@", commandLine.command);
    }
    
    return 0;
}
