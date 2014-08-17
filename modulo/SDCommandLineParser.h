//
//  SDCommandLineHelper.h
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"
#import "NSString+SDExtensions.h"

@class SDCommandLineParser;

GENERICSABLE(SDCommand)

/*
 Enforces a command line structure of:
 
 <command> ... <various combinations of options/params>
 */

@interface SDCommand : NSObject

+ (instancetype)commandWithName:(NSString *)name primary:(BOOL)primary;

@property (nonatomic, readonly) NSString *commandName;
@property (nonatomic, readonly) BOOL primary;
@property (nonatomic, readonly) NSArray<NSString> *arguments;
@property (nonatomic, readonly) NSSet<NSString> *options;

- (BOOL)hasOption:(NSString *)option;
- (NSString *)argumentAtIndex:(NSUInteger)index;

// override this stuff below here.

@property (nonatomic, readonly) NSSet<NSString> *supportedOptions;
@property (nonatomic, readonly) NSString *helpDescription;

/**
 Subclasses should override this method.
 
 Check for a valid command line for this command.  Returning YES signifies that the
 command line is valid.  Returning NO signifies that there's an error.
 */
- (BOOL)checkValidityOfCommand;

/**
 */
- (void)performCommand;

/**
 */
- (void)printHelp;

@end

@interface SDCommandLineParser : NSObject

@property (nonatomic, readonly) NSArray<SDCommand> *supportedCommands;
@property (nonatomic, readonly) SDCommand *command;
@property (nonatomic, readonly) NSArray *rawArguments;
@property (nonatomic, readonly) NSDictionary *environment;
@property (nonatomic, readonly) NSInteger processID;
@property (nonatomic, readonly) NSString *processName;
@property (nonatomic, readonly) NSString *currentWorkingPath;
@property (nonatomic, readonly) NSString *startingWorkingPath;

+ (instancetype)sharedInstance;

- (void)addSupportedCommands:(NSArray<SDCommand> *)commands;

- (void)processCommandLine;

@end

#pragma mark - Print helpers

extern void sdprint(NSString *format, ...);
extern void sdprintln(NSString *format, ...);
extern void sdfprint(FILE *file, NSString *format, ...);
extern void sdfprintln(FILE *file, NSString *format, ...);
