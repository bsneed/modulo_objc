//
//  MODSpecModel.h
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "MODSpecSourcesModel.h"
#import "MODSpecDependencyModel.h"
#import "MODSpecOtherDependencyModel.h"

@interface MODSpecModel : SDModelObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *projectURL;
@property (nonatomic, copy) NSString *moduleURL;
@property (nonatomic, copy) NSString *licenseURL;

@property (nonatomic, strong) NSArray<MODSpecSourceModel> *sources;

@property (nonatomic, copy) NSString *dependenciesPath;
@property (nonatomic, strong) NSArray<MODSpecDependencyModel> *dependencies;
@property (nonatomic, strong) NSArray<MODSpecOtherDependencyModel> *otherDependencies;

+ (instancetype)sharedInstance;

- (BOOL)saveSpecification;

@end
