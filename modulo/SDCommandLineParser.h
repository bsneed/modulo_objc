//
//  SDCommandLineHelper.h
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

@class SDCommandLineParser;

GENERICSABLE(SDCommand)
GENERICSABLE(NSString)

/*
 Enforces a command line structure of:
 
 <command> ... <various combinations of flags/params>
 */

@interface SDCommand : NSObject

+ (instancetype)commandWithName:(NSString *)name primary:(BOOL)primary;

@property (nonatomic, readonly) NSString *command;
@property (nonatomic, readonly) BOOL primary;
@property (nonatomic, readonly) NSArray<NSString> *arguments;
@property (nonatomic, readonly) NSSet<NSString> *flags;

- (BOOL)hasFlag:(NSString *)flag;
- (NSString *)argumentAtIndex:(NSUInteger)index;

// override this stuff below here.

@property (nonatomic, readonly) NSSet<NSString> *supportedFlags;

/**
 Subclasses should override this method.
 
 Check for a valid command line for this command.  Returning YES signifies that the
 command line is valid.  Returning NO signifies that there's an error.  The method
 should report the issue via the console or screen, as exit(1) will be called immediately after if the result is NO.
 */
- (BOOL)checkValidityOfCommand;

/**
 */
- (void)performCommand;

@end

@interface SDCommandLineParser : NSObject

@property (nonatomic, readonly) SDCommand *command;
@property (nonatomic, readonly) NSArray *rawArguments;
@property (nonatomic, readonly) NSDictionary *environment;
@property (nonatomic, readonly) NSInteger processID;

+ (instancetype)sharedInstance;

- (void)addSupportedCommands:(NSArray<SDCommand> *)commands;

- (void)processCommandLine;

@end

#pragma mark - Print helpers

extern void sdprint(NSString *format, ...);
extern void sdprintln(NSString *format, ...);
extern void sdfprint(FILE *file, NSString *format, ...);
extern void sdfprintln(FILE *file, NSString *format, ...);
