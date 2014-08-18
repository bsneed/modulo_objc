//
//  MODSpecModel.m
//  modulo
//
//  Created by Brandon Sneed on 8/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import "MODSpecModel.h"
#import "SDCommandLineParser.h"
#import "NSDictionary+SDExtensions.h"

@implementation MODSpecModel

/*
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, copy) NSString *projectURL;
 @property (nonatomic, copy) NSString *moduleURL;
 @property (nonatomic, copy) NSString *licenseURL;
 
 @property (nonatomic, strong) NSArray<MODSpecSourceModel> *sources;
 
 @property (nonatomic, copy) NSString *dependenciesPath;
 @property (nonatomic, strong) NSArray<MODSpecDependencyModel> *dependencies;
 @property (nonatomic, strong) NSArray<MODSpecOtherDependencyModel> *otherDependencies;
 */

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"projectURL": sdmo_key(self.projectURL),
             @"moduleURL": sdmo_key(self.moduleURL),
             @"licenseURL": sdmo_key(self.licenseURL),
             @"sources": sdmo_key(self.sources),
             @"dependenciesPath": sdmo_key(self.dependenciesPath),
             @"dependencies": sdmo_key(self.dependencies),
             @"otherDependencies": sdmo_key(self.otherDependencies)};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"name": @"(NSString)name",
             @"projectURL": @"(NSString)projectURL",
             @"moduleURL": @"(NSString)moduleURL",
             @"licenseURL": @"(NSString)licenseURL",
             @"sources": @"(NSArray<NSDictionary>)sources",
             @"dependenciesPath": @"(NSString)dependenciesPath",
             @"dependencies": @"(NSArray<NSDictionary>)dependencies",
             @"otherDependencies": @"(NSArray<NSDictionary>)otherDependencies"};
    
}

- (BOOL)validModel
{
    if (self.name)
        return YES;
    return NO;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MODSpecModel *__sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[MODSpecModel alloc] init];
    });
    
    return __sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        [self loadSpecification];
    }
    
    return self;
}

- (BOOL)loadSpecification
{
    NSString *filePath = [[SDCommandLineParser sharedInstance].startingWorkingPath stringByAppendingPathComponent:@"modulo.spec"];
    
    // TODO: handle this error.
    NSError *error = nil;
    NSString *specString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    NSDictionary *specDict = [specString JSONDictionaryRepresentation];
    
    if (!specDict)
        return NO;
    
    [[SDDataMap map] mapObject:specDict toObject:self];
    if (self.name == nil)
        return NO;
    
    return YES;
}

- (BOOL)saveSpecification
{
    BOOL result = NO;
    NSMutableDictionary *specDict = [NSMutableDictionary dictionary];
    [[SDDataMap map] mapObject:self toObject:specDict];
    
    if ([specDict objectForKey:@"name"])
    {
        NSString *filePath = [[SDCommandLineParser sharedInstance].startingWorkingPath stringByAppendingPathComponent:@"modulo.spec"];
        NSString *specString = [specDict JSONStringRepresentation];
        
        // TODO: handle this error.
        NSError *error = nil;
        [specString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        result = YES;
    }
    
    return result;
}

@end
