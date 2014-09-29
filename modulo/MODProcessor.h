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

@interface MODProcessor : NSObject

@property (nonatomic, assign) BOOL verbose;
@property (nonatomic, readonly) NSArray *modifiedDependencies;

+ (instancetype)processor;

//- (MODSpecModel *)processDependencyNamed:(NSString *)name moduleURL:(NSString *)moduleURL branch:(NSString *)branch;
//- (void)rewindDependency:(NSString *)dependencyName localPath:(NSString *)dependencyLocalPath error:(NSString *)error;
- (void)addDependencyNamed:(NSString *)dependencyName moduleURL:(NSString *)moduleURL branch:(NSString *)branch;
- (void)removeDependencyNamed:(NSString *)dependencyName;

@end
