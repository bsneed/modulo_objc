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
 @property (nonatomic, copy) NSString *localPath;
 @property (nonatomic, copy) NSString *addedAutomatically;
 @property (nonatomic, copy) NSArray<NSString> *owningDependencies;
 */

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"moduleURL": sdmo_key(self.moduleURL),
             @"projectURL": sdmo_key(self.projectURL),
             @"localPath": sdmo_key(self.localPath),
             @"sourcePath": sdmo_key(self.sourcePath),
             @"addedAutomatically": sdmo_key(self.addedAutomatically),
             @"owningDependencies": sdmo_key(self.owningDependencies)
             };
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"name": @"(NSString)name",
             @"moduleURL": @"(NSString)moduleURL",
             @"projectURL": @"(NSString)projectURL",
             @"localPath": @"(NSString)localPath",
             @"sourcePath": @"(NSString)sourcePath",
             @"addedAutomatically": @"(NSNumber)addedAutomatically",
             @"owningDependencies": @"(NSArray<NSString>)owningDependencies"
             };
}

- (BOOL)validModel
{
    return YES;
}

@end
