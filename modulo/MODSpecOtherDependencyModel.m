//
//  MODSpecOtherDependencyModel.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODSpecOtherDependencyModel.h"

GENERICSABLE_IMPLEMENTATION(MODSpecOtherDependencyModel)

@implementation MODSpecOtherDependencyModel

/*
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, copy) NSString *defaultPath;
 @property (nonatomic, copy) NSString *projectURL;
*/

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"defaultPath": sdmo_key(self.defaultPath),
             @"projectURL": sdmo_key(self.projectURL)};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"name": @"(NSString)name",
             @"defaultPath": @"(NSString)defaultPath",
             @"projectURL": @"(NSString)projectURL"};
}

@end
