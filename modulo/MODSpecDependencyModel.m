//
//  MODSpecDependencyModel.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODSpecDependencyModel.h"

GENERICSABLE_IMPLEMENTATION(MODSpecDependencyModel)

@implementation MODSpecDependencyModel

/*
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, copy) NSString *moduleURL;
 @property (nonatomic, copy) NSString *projectURL;
 @property (nonatomic, copy) NSString *commitHash;
 */

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"moduleURL": sdmo_key(self.moduleURL),
             @"projectURL": sdmo_key(self.projectURL),
             @"commitHash": sdmo_key(self.commitHash)};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"name": @"(NSString)name",
             @"moduleURL": @"(NSString)moduleURL",
             @"projectURL": @"(NSString)projectURL",
             @"commitHash": @"(NSString)commitHash"};
}

@end
