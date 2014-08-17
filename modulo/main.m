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
#import "MODVersionCommand.h"
#import "MODHelpCommand.h"

/*
 
    * = done for now
    ~ = in progress
 
    *--help - shows help
    *--version - shows the version info
    init - initializes the path for use with modulo
    validate - validates dependencies, overall setup, etc
    add - adds a dependency
    rm - removes a dependency
    dependency - performs actions related to a given dependency
    clean - removes modulo.spec and all dependency files
    update - updates dependencies and their subdependencies
    ~set - sets a key/value pair in the projects modulo.spec file
    outdated - looks through dependencies to find what modules may be outdated
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        MODSetCommand *setCommand = [MODSetCommand commandWithName:@"set" primary:YES];
        MODVersionCommand *versionCommand = [MODVersionCommand commandWithName:@"--version" primary:NO];
        MODHelpCommand *helpCommand = [MODHelpCommand commandWithName:@"--help" primary:NO];
        
        SDCommandLineParser *commandLine = [SDCommandLineParser sharedInstance];
        [commandLine addSupportedCommands:(NSArray<SDCommand> *)@[setCommand,
                                                                  versionCommand,
                                                                  helpCommand]];
        [commandLine processCommandLine];

        sdprint(@"%@", commandLine.command);
    }
    
    return 0;
}
