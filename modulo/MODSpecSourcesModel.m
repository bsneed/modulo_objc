//
//  MODSpecSourcesModel.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODSpecSourcesModel.h"

GENERICSABLE_IMPLEMENTATION(MODSpecSourceModel)

@implementation MODSpecSourcesModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"path": sdmo_key(self.path)};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"path": @"(NSString)path"};
    
}

@end
