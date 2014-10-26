//
//  main.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommandLineParser.h"
#import "MODInitCommand.h"
#import "MODSetCommand.h"
#import "MODVersionCommand.h"
#import "MODHelpCommand.h"
#import "MODAddCommand.h"
#import "MODRemoveCommand.h"
#import "MODUpdateCommand.h"

/*
 modulo branch <branch name> // switches master project and all deps to specified branch, creates if necessary.
 modulo remove .. -f // removes submodules and cleans.  checks stashes, status, outstanding changes, and unpushed commits before destroying.
                     // -f forces destruction, regardless of checks.
 modulo update .. -f // the removal piece works the same as remove above. -f forces destruction.
 */

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MODInitCommand *initCommand = [MODInitCommand commandWithName:@"init" primary:YES];
        MODSetCommand *setCommand = [MODSetCommand commandWithName:@"set" primary:YES];
        MODVersionCommand *versionCommand = [MODVersionCommand commandWithName:@"--version" primary:NO];
        MODHelpCommand *helpCommand = [MODHelpCommand commandWithName:@"--help" primary:NO];
        MODAddCommand *addCommand = [MODAddCommand commandWithName:@"add" primary:YES];
        MODRemoveCommand *removeCommand = [MODRemoveCommand commandWithName:@"remove" primary:YES];
        MODUpdateCommand *updateCommand = [MODUpdateCommand commandWithName:@"update" primary:YES];
        
        SDCommandLineParser *commandLine = [SDCommandLineParser sharedInstance];
        [commandLine addSupportedCommands:(NSArray<SDCommand> *)@[initCommand,
                                                                  setCommand,
                                                                  versionCommand,
                                                                  helpCommand,
                                                                  addCommand,
                                                                  removeCommand,
                                                                  updateCommand]];
        
        // we wanna print this if we don't get any valid commands at all.
        commandLine.helpCommand = helpCommand;
        
        [commandLine processCommandLine];

        //sdprintln(@"%@", commandLine.command);
    }
    
    return 0;
}
