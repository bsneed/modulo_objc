//
//  NSFileManager+MODExtensions.m
//  modulo
//
//  Created by Brandon Sneed on 10/27/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "NSFileManager+MODExtensions.h"

@implementation NSFileManager(MODExtensions)

- (NSString *)temporaryFile
{
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"file.txt"];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    return [fileURL path];
}

+ (NSString *)temporaryFile
{
    return [[NSFileManager defaultManager] temporaryFile];
}

@end
