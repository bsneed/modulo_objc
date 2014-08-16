//
//  SDCommandLineHelper.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDCommandLineParser.h"

#pragma mark - SDCommand

@interface SDCommand ()
- (instancetype)initWithCommandName:(NSString *)name primary:(BOOL)primary;
- (void)addCommandArgument:(NSString *)argument;
- (void)addCommandFlag:(NSString *)flag;
- (BOOL)stringIsFlag:(NSString *)string;
@end

@implementation SDCommand
{
    NSMutableArray *_rawArguments;
    NSMutableSet *_rawFlags;
}

+ (instancetype)commandWithName:(NSString *)name primary:(BOOL)primary
{
    return [[[self class] alloc] initWithCommandName:name primary:primary];
}

- (instancetype)initWithCommandName:(NSString *)name primary:(BOOL)primary
{
    if ((self = [super init]))
    {
        _rawArguments = [NSMutableArray array];
        _rawFlags = [NSMutableSet set];
        _command = name;
        _primary = primary;
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
    
    [result appendString:@"flags: "];
    NSArray *flags = [self.flags allObjects];
    for (NSUInteger i = 0; i < flags.count; i++)
    {
        NSString *flag = [flags objectAtIndex:i];
        [result appendFormat:@"%@, ", flag];
    }
    
    return result;
}

- (BOOL)hasFlag:(NSString *)flag
{
    if ([self.flags containsObject:flag])
        return YES;
    return NO;
}

- (NSString *)argumentAtIndex:(NSUInteger)index
{
    if (index > _rawArguments.count - 1)
        return nil;
    
    return [_rawArguments objectAtIndex:index];
}

- (NSArray<NSString> *)arguments
{
    return (NSArray<NSString> *)[NSArray arrayWithArray:_rawArguments];
}

- (NSSet<NSString> *)flags
{
    return (NSSet<NSString> *)[NSSet setWithSet:_rawFlags];
}

- (void)addCommandArgument:(NSString *)argument
{
    [_rawArguments addObject:argument];
}

- (BOOL)stringIsFlag:(NSString *)string
{
    // this catches "-help" and "--help" and treats them the same.
    NSString *filteredFlag = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return (([string rangeOfString:@"-"].location == 0) ||
            ([self.supportedFlags containsObject:filteredFlag]));
}

- (void)addCommandFlag:(NSString *)flag
{
    if (flag.length < 2)
        return;
    
    // this catches "-help", "--help" and "help" and treats them the same.
    NSString *filteredFlag = [flag stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if ([self.supportedFlags containsObject:filteredFlag])
        [_rawFlags addObject:filteredFlag];
    else
    {
        for (NSUInteger i = 0; i < filteredFlag.length; i++)
        {
            NSString *character  = [NSString stringWithFormat:@"%c", [filteredFlag characterAtIndex:i]];
            if ([self.supportedFlags containsObject:character])
                [_rawFlags addObject:character];
        }
    }
}

- (BOOL)checkValidityOfCommand
{
    return NO;
}

- (void)performCommand
{
    // do nothing.
}


@end

GENERICSABLE_IMPLEMENTATION(SDCommand)


#pragma mark - SDCommandLineHelper

GENERICSABLE_IMPLEMENTATION(NSString)

@implementation SDCommandLineParser
{
    NSProcessInfo *_processInfo;
    NSArray *_rawArguments;
    NSMutableArray *_supportedCommands;
}

#pragma mark - initialization

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[[self class] alloc] init];
    });
    
    return __sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _processInfo = [NSProcessInfo processInfo];
        _rawArguments = [_processInfo arguments];
        _environment = [_processInfo environment];
        _processID = [_processInfo processIdentifier];
        
        _supportedCommands = [NSMutableArray array];
    }
    
    return self;
}

- (void)processRawArguments
{
    // arg 0 is the full name/path of the app.
    for (NSUInteger i = 1; i < _rawArguments.count; i++)
    {
        NSString *arg = [_rawArguments objectAtIndex:i];
        
        if (!_command)
        {
            _command = [self commandForString:arg];
        }
        else
        if (_command)
        {
            if ([_command stringIsFlag:arg])
                [_command addCommandFlag:arg];
            else
                [_command addCommandArgument:arg];
        }
    }
}

#pragma mark - private methods

- (SDCommand *)commandForString:(NSString *)string
{
    __block SDCommand *foundCommand = nil;
    [_supportedCommands enumerateObjectsUsingBlock:^(SDCommand *command, NSUInteger idx, BOOL *stop) {
        if ([command.command isEqualToString:string])
        {
            foundCommand = command;
            *stop = YES;
        }
    }];
    
    return foundCommand;
}

#pragma mark - public methods

- (NSArray *)rawArguments
{
    return [NSArray arrayWithArray:_rawArguments];
}

- (void)addSupportedCommands:(NSArray<SDCommand> *)commands
{
    [_supportedCommands addObjectsFromArray:commands];
}

- (void)processCommandLine
{
    [self processRawArguments];
    
    if (self.command)
    {
        if ([self.command checkValidityOfCommand])
            [self.command performCommand];
        else
            exit(1);
    }
}

@end

#pragma mark - Print helpers

static void sd_printf_worker(FILE *file, NSString *format, va_list arguments)
{
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    fprintf(file, "%s", [msg UTF8String]);
}

void sdprint(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    sd_printf_worker(stdout, format, arguments);
    va_end(arguments);
}

void sdprintln(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    format = [format stringByAppendingString:@"\n"];
    sd_printf_worker(stdout, format, arguments);
    va_end(arguments);
}

void sdfprint(FILE *file, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    sd_printf_worker(file, format, arguments);
    va_end(arguments);
}

void sdfprintln(FILE *file, NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    format = [format stringByAppendingString:@"\n"];
    sd_printf_worker(file, format, arguments);
    va_end(arguments);
}
