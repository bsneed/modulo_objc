//
//  MODProcessor.h
//  modulo
//
//  Created by Brandon Sneed on 9/29/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MODSpecModel.h"
#import "MODCommand.h"
#import "NSString+MODExtensions.h"

@interface MODProcessor : NSObject

@property (nonatomic, assign) BOOL verbose;
@property (nonatomic, readonly) NSArray<MODSpecModel> *addedDependencies;
@property (nonatomic, readonly) NSArray<NSString> *removedDependencies;
@property (nonatomic, readonly) NSArray<NSString> *possiblyUnusedDependencies;
@property (nonatomic, readonly) NSArray<NSString> *updatedDependencies;

+ (instancetype)processor;

- (BOOL)addDependencyWithModuleURL:(NSString *)moduleURL branch:(NSString *)branch;
- (BOOL)removeDependencyNamed:(NSString *)name;
- (BOOL)updateDependencyNames:(NSArray<NSString> *)names;

- (NSArray<NSString> *)uncleanDependencies;
- (NSArray<NSString> *)uncleanDependenciesForName:(NSString *)name;

@end
