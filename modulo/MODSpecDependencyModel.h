//
//  MODSpecDependencyModel.h
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "SDDataMap.h"

GENERICSABLE(MODSpecDependencyModel)

@interface MODSpecDependencyModel : SDModelObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *moduleURL;
@property (nonatomic, copy) NSString *projectURL;
@property (nonatomic, copy) NSString *commitHash;

@end
