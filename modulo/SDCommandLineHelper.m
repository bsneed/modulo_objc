//
//  SDCommandLineHelper.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDCommandLineHelper.h"

#pragma mark - SDCommand

@interface SDCommand ()
- (instancetype)initWithCommandName:(NSString *)command;
- (void)addCommandArgument:(NSString *)argument;
@end

@implementation SDCommand
{
    NSMutableArray *_rawArguments;
    NSArray *_arguments;
}

- (instancetype)initWithCommandName:(NSString *)command
{
    if ((self = [super init]))
    {
        _rawArguments = [NSMutableArray array];
        _command = command;
    }
    
    return self;
}

- (NSString *)description
{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendFormat:@"command: '%@', arguments: ", self.command];
    for (NSUInteger i = 0; i < self.arguments.count; i++)
    {
        NSString *argument = [self.arguments objectAtIndex:i];
        [result appendFormat:@"%@, ", argument];
    }
    
    return result;
}

- (void)addCommandArgument:(NSString *)argument
{
    [_rawArguments addObject:argument];
}

- (NSArray<NSString> *)arguments
{
    return (NSArray<NSString> *)[NSArray arrayWithArray:_rawArguments];
}

@end

GENERICSABLE_IMPLEMENTATION(SDCommand)


#pragma mark - SDCommandLineHelper

GENERICSABLE_IMPLEMENTATION(NSString)

@implementation SDCommandLineHelper
{
    NSProcessInfo *_processInfo;
    NSArray *_rawArguments;
    NSArray<NSString> *_supportedCommands;
    NSArray<NSString> *_supportedFlags;
}

#pragma mark - initialization

- (instancetype)initWithSupportedCommands:(NSArray<NSString> *)commands flags:(NSArray<NSString> *)flags
{
    if ((self = [super init]))
    {
        _processInfo = [NSProcessInfo processInfo];
        _rawArguments = [_processInfo arguments];
        _environment = [_processInfo environment];
        _processID = [_processInfo processIdentifier];
        
        _supportedCommands = commands;
        _supportedFlags = flags;
    }
    
    [self processRawArguments];
    
    return self;
}

- (void)processRawArguments
{
    NSMutableArray *flags = [NSMutableArray array];
    NSMutableArray *commands = [NSMutableArray array];
    
    SDCommand *lastCommand = nil;
    
    // arg 0 is the full name/path of the app.
    for (NSUInteger i = 1; i < _rawArguments.count; i++)
    {
        NSString *arg = [_rawArguments objectAtIndex:i];
        
        if ((lastCommand) && (![self stringIsCommand:arg] && ![self stringIsFlag:arg]))
        {
                [lastCommand addCommandArgument:arg];
        }
        else
        {
            // nil this, since it's no longer relevant.
            //lastCommand = nil;
            
            if ([self stringIsFlag:arg])
            {
                // it's a flag.  add it to the list.
                [self addToFlags:flags fromString:arg];
            }
            else
            if ([self stringIsCommand:arg])
            {
                lastCommand = [[SDCommand alloc] initWithCommandName:arg];
                [commands addObject:lastCommand];
            }
        }
    }
    
    _flags = [NSArray arrayWithArray:flags];
    _commands = (NSArray<SDCommand> *)[NSArray arrayWithArray:commands];
}

#pragma mark - private methods

- (BOOL)stringIsFlag:(NSString *)string
{
    return ([string rangeOfString:@"-"].location == 0);
}

- (void)addToFlags:(NSMutableArray *)flags fromString:(NSString *)string
{
    if (string.length < 2)
        return;
    
    // we want to preserve the order.
    for (NSUInteger i = 0; i < string.length; i++)
    {
        NSString *character  = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        if (![character isEqualToString:@"-"])
            [flags addObject:character];
    }
}

- (BOOL)stringIsCommand:(NSString *)string
{
    return [_supportedCommands containsObject:string];
}

#pragma mark - public methods

- (BOOL)hasFlag:(NSString *)flag
{
    BOOL result = NO;
    
    return result;
}

- (BOOL)hasCommand:(NSString *)command
{
    BOOL result = NO;
    
    return result;
}

@end
