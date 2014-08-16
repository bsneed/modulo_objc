//
//  SDCommandLineHelper.h
//  modulo
//
//  Created by Brandon Sneed on 8/15/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

@class SDCommandLineHelper;

GENERICSABLE(SDCommand)
GENERICSABLE(NSString)

@interface SDCommand : NSObject
@property (nonatomic, readonly) NSString *command;
@property (nonatomic, readonly) NSArray<NSString> *arguments;
@property (nonatomic, readonly, weak) SDCommandLineHelper *helper;
@end

@interface SDCommandLineHelper : NSObject

@property (nonatomic, readonly) NSArray<SDCommand> *commands;
@property (nonatomic, readonly) NSArray *flags;
@property (nonatomic, readonly) NSArray *arguments;
@property (nonatomic, readonly) NSDictionary *environment;
@property (nonatomic, readonly) NSUInteger processID;

- (instancetype)initWithSupportedCommands:(NSArray<NSString> *)commands flags:(NSArray<NSString> *)flags;

- (BOOL)hasFlag:(NSString *)flag;
- (BOOL)hasCommand:(NSString *)command;

@end
