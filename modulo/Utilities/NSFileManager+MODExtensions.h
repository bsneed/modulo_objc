//
//  NSFileManager+MODExtensions.h
//  modulo
//
//  Created by Brandon Sneed on 10/27/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager(MODExtensions)

- (NSString *)temporaryFile;
+ (NSString *)temporaryFile;

@end
