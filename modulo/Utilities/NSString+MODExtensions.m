//
//  NSString+MODExtensions.m
//  modulo
//
//  Created by Brandon Sneed on 10/14/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "NSString+MODExtensions.h"

@implementation NSString(MODExtensions)

- (NSString *)nameFromModuleURL
{
    NSString *result = [[self lastPathComponent] stringByReplacingOccurrencesOfString:@".git" withString:@""];
    return result;
}

- (BOOL)isLibraryPath
{
    return [self rangeOfString:@"../"].location == 0;
}

@end
