//
//  NSString+MODExtensions.h
//  modulo
//
//  Created by Brandon Sneed on 10/14/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+SDExtensions.h"

@interface NSString(MODExtensions)

- (NSString *)nameFromModuleURL;
- (BOOL)isLibraryPath;

@end
