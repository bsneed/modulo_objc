//
//  MODCommand.m
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODCommand.h"

@implementation MODCommand

//@property (nonatomic, readonly) NSUInteger supportArgumentCount;

- (BOOL)verbose
{
    if ([self hasOption:@"verbose"])
        return YES;
    return NO;
}

- (NSSet<NSString> *)supportedOptions
{
    return (NSSet<NSString> *)[NSSet setWithObjects:@"help", @"verbose", @"silent", nil];
}

- (BOOL)checkValidityOfCommand
{
    return NO;
}

- (void)performCommand
{
    if (![MODSpecModel sharedInstance].isInitialized)
        sderror(@"This directory has not been initialized for modulo.");
}

- (NSInteger)runCommand:(NSString *)command parseBlock:(MODCommandParseBlock)parseBlock
{
    if (parseBlock)
        command = [command stringByAppendingString:@" 2> modulo_temp.txt"];
    
    if (self.verbose)
        sdprintln(@"Running: %@", command);
    
    NSInteger status = system([command UTF8String]);
    
    if (parseBlock)
    {
        NSString *outputString = [NSString stringWithContentsOfFile:@"modulo_temp.txt" encoding:NSUTF8StringEncoding error:nil];
        status = parseBlock(status, outputString);
        if (status != 0)
            sdprintln(outputString);
    }
    
    return status;
}

- (NSInteger)runCommand:(NSString *)command
{
    return [self runCommand:command parseBlock:nil];
}



@end
