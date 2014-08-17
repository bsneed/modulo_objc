//
//  MODHelpCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/16/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODHelpCommand.h"
#import <sys/ioctl.h>

@implementation MODHelpCommand

static struct winsize __windowSize;

+ (void)initialize
{
    // get the terminal buffer sizing.  this won't work in xcode's console, but does in terminal/iterm.
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &__windowSize);
    
    if (__windowSize.ws_col == 0)
        __windowSize.ws_col = 80;
}

- (NSSet<NSString> *)supportedOptions
{
    return nil;
}

- (BOOL)checkValidityOfCommand
{
    return YES;
}

- (void)appendString:(NSMutableString *)mutableString withString:(NSString *)string maxLineLength:(inout NSUInteger *)maxLineLength newLineSpace:(NSUInteger)newLineSpace
{
    NSUInteger mutableStringLength = mutableString.length;
    NSUInteger stringLength = string.length;
    NSUInteger length = mutableStringLength + stringLength;
    BOOL tooLong = (length >= *maxLineLength);
    if (tooLong)
    {
        *maxLineLength += __windowSize.ws_col - 8;
        [mutableString appendString:@"\n"];
        for (NSUInteger i = 0; i < newLineSpace; i++)
            [mutableString appendString:@" "];
    }
    
    [mutableString appendString:string];
}

- (void)performCommand
{
    NSString *usageLine = @"usage: ";
    NSString *processName = [[SDCommandLineParser sharedInstance] processName];
    
    NSArray *commands = [SDCommandLineParser sharedInstance].supportedCommands;
    NSPredicate *filterPredicate = nil;
    NSUInteger alignmentWidth = processName.length + usageLine.length + 1;
    NSUInteger maxLineLength = __windowSize.ws_col;
    
    filterPredicate = [NSPredicate predicateWithFormat:@"commandName BEGINSWITH \"--\""];
    NSArray *optionCommands = [commands filteredArrayUsingPredicate:filterPredicate];
    NSMutableString *optionCommandsString = [NSMutableString stringWithFormat:@"%@%@ ", usageLine, processName];
    for (NSUInteger i = 0; i < optionCommands.count; i++)
    {
        SDCommand *command = [optionCommands objectAtIndex:i];
        NSString *string = [NSString stringWithFormat:@"[%@] ", command.commandName];
        [self appendString:optionCommandsString withString:string maxLineLength:&maxLineLength newLineSpace:alignmentWidth];
    }
    
    sdprintln(optionCommandsString);
    sdprintln(@"");
    sdprintln(@"The most commonly used modulo commands are:");
    
    filterPredicate = [NSPredicate predicateWithFormat:@"primary == YES"];
    NSArray *primaryCommands = [commands filteredArrayUsingPredicate:filterPredicate];
    NSMutableString *primaryCommandsString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < primaryCommands.count; i++)
    {
        SDCommand *command = [primaryCommands objectAtIndex:i];
        NSString *string = [NSString stringWithFormat:@"   %@%@\n", [command.commandName stringByPaddingToLength:11 withString:@" " startingAtIndex:0], command.helpDescription];
        [primaryCommandsString appendString:string];
    }
    
    sdprintln(primaryCommandsString);
    
}

- (void)printHelp
{
    [self performCommand];
}

@end
