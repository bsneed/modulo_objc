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
- (void)addCommandOption:(NSString *)option;
- (BOOL)stringIsOption:(NSString *)string;
@end

@implementation SDCommand
{
    NSMutableArray *_rawArguments;
    NSMutableSet *_rawOptions;
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
        _rawOptions = [NSMutableSet set];
        _commandName = name;
        _primary = primary;
    }
    
    return self;
}

- (NSString *)description
{
    NSMutableString *result = [[NSMutableString alloc] init];

    [result appendFormat:@"command: '%@' {\n    arguments: ", self.commandName];
    for (NSUInteger i = 0; i < self.arguments.count; i++)
    {
        NSString *argument = [self.arguments objectAtIndex:i];
        [result appendFormat:@"%@", argument];
        if (i != self.arguments.count - 1)
            [result appendString:@", "];
    }
    
    NSArray *options = [self.options allObjects];
    if (options.count > 0)
    {
        [result appendString:@"\n\toptions: "];
        for (NSUInteger i = 0; i < options.count; i++)
        {
            NSString *option = [options objectAtIndex:i];
            [result appendFormat:@"%@", option];
            if (i != options.count - 1)
                [result appendString:@", "];
        }
    }
    
    [result appendString:@"\n}\n"];
    
    return result;
}

- (BOOL)hasOption:(NSString *)option
{
    if ([self.options containsObject:option])
        return YES;
    return NO;
}

- (NSString *)argumentAtIndex:(NSUInteger)index
{
    if (index < _rawArguments.count)
        return [_rawArguments objectAtIndex:index];
    return nil;
}

- (NSArray<NSString> *)arguments
{
    return (NSArray<NSString> *)[NSArray arrayWithArray:_rawArguments];
}

- (NSSet<NSString> *)options
{
    return (NSSet<NSString> *)[NSSet setWithSet:_rawOptions];
}

- (void)addCommandArgument:(NSString *)argument
{
    [_rawArguments addObject:argument];
}

- (BOOL)stringIsOption:(NSString *)string
{
    // this catches "-help" and "--help" and treats them the same.
    NSString *filteredOption = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return (([string rangeOfString:@"-"].location == 0) ||
            ([self.supportedOptions containsObject:filteredOption]));
}

- (void)addCommandOption:(NSString *)option
{
    if (option.length < 2)
        return;
    
    // this catches "-help", "--help" and "help" and treats them the same.
    NSString *filteredOption = [option stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if ([self.supportedOptions containsObject:filteredOption])
        [_rawOptions addObject:filteredOption];
    else
    {
        for (NSUInteger i = 0; i < filteredOption.length; i++)
        {
            NSString *character  = [NSString stringWithFormat:@"%c", [filteredOption characterAtIndex:i]];
            if ([self.supportedOptions containsObject:character])
                [_rawOptions addObject:character];
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

- (void)printHelp
{
    
}

- (NSString *)helpDescription
{
    return @"No description";
}

@end

GENERICSABLE_IMPLEMENTATION(SDCommand)


#pragma mark - SDCommandLineHelper

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
        _processName = [_processInfo processName];
        _startingWorkingPath = [[NSFileManager defaultManager] currentDirectoryPath];
        
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
        
        // double-dash the fuck out of here and stop processing.
        if ([arg isEqualToString:@"--"])
            return;
        
        if (!_command)
        {
            _command = [self commandForString:arg];
        }
        else
        if (_command)
        {
            if ([_command stringIsOption:arg])
                [_command addCommandOption:arg];
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
        if ([command.commandName isEqualToString:string])
        {
            foundCommand = command;
            *stop = YES;
        }
    }];
    
    return foundCommand;
}

#pragma mark - public methods

- (NSString *)currentWorkingPath
{
    return [[NSFileManager defaultManager] currentDirectoryPath];
}

- (NSArray *)rawArguments
{
    return [NSArray arrayWithArray:_rawArguments];
}

- (NSArray<SDCommand> *)supportedCommands
{
    return (NSArray<SDCommand> *)[NSArray arrayWithArray:_supportedCommands];
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
        {
            [self.command printHelp];
            exit(1);
        }
    }
    else
    {
        if (self.helpCommand)
            [self.helpCommand printHelp];
        else
            sdprintln(@"Unknown, invalid or no command given.");
    }
}

@end

#pragma mark - Print helpers

static void sd_printf_worker(FILE *file, NSString *format, va_list arguments)
{
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:arguments];
    
    // when given a format such as @"%@\n" and arguments is nil, msg = @"(null)\n".
    // Such dumb.  Much wow.
    
    // lets skip printing out that junk.
    if ([msg rangeOfString:@"(null)"].location == 0)
        return;
    
    fprintf(file, "%s", [msg UTF8String]);
}

void sderror(NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    if (format.length > 0)
        format = [NSString stringWithFormat:@"error: %@\n", format];
    else
        format = @"\n";
    sd_printf_worker(stdout, format, arguments);
    va_end(arguments);
    
    exit(1);
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
