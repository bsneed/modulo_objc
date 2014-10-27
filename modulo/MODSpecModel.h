//
//  MODSpecModel.h
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "NSString+MODExtensions.h"

GENERICSABLE(MODSpecModel)

@interface MODSpecModel : SDModelObject

// data map properties

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *projectURL;
@property (nonatomic, copy) NSString *moduleURL;
@property (nonatomic, copy) NSString *licenseURL;
@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, copy) NSString *initialBranch;
@property (nonatomic, copy) NSString *dependenciesPath;
@property (nonatomic, strong) NSArray<MODSpecModel> *dependencies;

// normal properties

+ (instancetype)sharedInstance;
+ (instancetype)instanceFromPath:(NSString *)path;
+ (instancetype)instanceFromName:(NSString *)name;

- (NSString *)dependencyLocalPathFromName:(NSString *)name;

- (BOOL)saveSpecification;

- (BOOL)isInitialized;
- (BOOL)hasDependencyPathSet;

- (BOOL)addDependency:(MODSpecModel *)dependency;
- (BOOL)updateDependency:(MODSpecModel *)dependency;
- (BOOL)removeDependencyNamed:(NSString *)name;
- (MODSpecModel *)dependencyNamed:(NSString *)name;

- (NSArray<NSString> *)namesThatDependOn:(NSString *)name;
- (NSArray<NSString> *)dependencyNames;

@end
