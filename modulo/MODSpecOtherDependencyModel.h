//
//  MODSpecOtherDependencyModel.h
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "SDDataMap.h"

GENERICSABLE(MODSpecOtherDependencyModel)

@interface MODSpecOtherDependencyModel : SDModelObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *defaultPath;
@property (nonatomic, copy) NSString *projectURL;

@end
