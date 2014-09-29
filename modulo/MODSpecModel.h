//
//  MODSpecModel.h
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "MODSpecOtherDependencyModel.h"

GENERICSABLE(MODSpecModel)

@interface MODSpecModel : SDModelObject

// data map properties
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *projectURL;
@property (nonatomic, copy) NSString *moduleURL;
@property (nonatomic, copy) NSString *licenseURL;
@property (nonatomic, assign) BOOL library;
@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *initialBranch;

@property (nonatomic, copy) NSString *dependenciesPath;
@property (nonatomic, strong) NSArray<MODSpecModel> *dependencies;
@property (nonatomic, strong) NSArray<MODSpecOtherDependencyModel> *otherDependencies;

// regular properties
@property (nonatomic, copy) NSString *pathToModel;

+ (instancetype)sharedInstance;
+ (instancetype)instanceFromPath:(NSString *)path;

- (BOOL)saveSpecification;

- (BOOL)isInitialized;
- (BOOL)hasDependencyPathSet;

- (void)addDependency:(MODSpecModel *)dependency;
- (BOOL)dependencyExistsNamed:(NSString *)name;
- (BOOL)removeDependencyNamed:(NSString *)name;

@end
