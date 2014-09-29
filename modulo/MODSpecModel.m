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

GENERICSABLE_IMPLEMENTATION(MODSpecModel)

@implementation MODSpecModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"projectURL": sdmo_key(self.projectURL),
             @"moduleURL": sdmo_key(self.moduleURL),
             @"licenseURL": sdmo_key(self.licenseURL),
             @"library": sdmo_key(self.library),
             @"sourcePath": sdmo_key(self.sourcePath),
             @"localPath": sdmo_key(self.localPath),
             @"initialBranch": sdmo_key(self.initialBranch),
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
             @"library": @"(NSNumber)library",
             @"sourcePath": @"(NSString)sourcePath",
             @"localPath": @"(NSString)localPath",
             @"initialBranch": @"(NSString)initialBranch",
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
        __sharedInstance.pathToModel = [[SDCommandLineParser sharedInstance].startingWorkingPath stringByAppendingPathComponent:@"modulo.spec"];
        [__sharedInstance loadSpecification];
    });
    
    return __sharedInstance;
}

+ (instancetype)instanceFromPath:(NSString *)path
{
    if ([path rangeOfString:@"modulo.spec"].location == NSNotFound)
        path = [path stringByAppendingPathComponent:@"modulo.spec"];
    
    MODSpecModel *specModel = [[MODSpecModel alloc] init];
    specModel.pathToModel = path;
    [specModel loadSpecification];
    return specModel;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
    }
    
    return self;
}

- (BOOL)loadSpecification
{
    NSString *filePath = self.pathToModel;
    
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
        NSData *fileData = [specString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (![fileData writeToFile:filePath atomically:YES])
        {
            sdprintln(@"There was a problem writing modulo.spec to %@", filePath);
            exit(1);
        }
        
        result = YES;
    }
    
    return result;
}

- (BOOL)isInitialized
{
    BOOL result = NO;
    
    if (self.name.length > 0)
        result = YES;
    
    return result;    
}

- (BOOL)hasDependencyPathSet
{
    BOOL result = NO;
    
    if (self.dependenciesPath.length > 0)
        result = YES;
    
    return result;
}

- (void)addDependency:(MODSpecModel *)dependency
{
    NSMutableArray *dependencies = [NSMutableArray arrayWithArray:self.dependencies];
    [dependencies addObject:dependency];
    self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:dependencies];
}

- (BOOL)dependencyExistsNamed:(NSString *)name
{
    BOOL result = NO;
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item.name isEqualToString:name])
        {
            result = YES;
            break;
        }
    }
    return result;    
}

- (MODSpecModel *)dependencyNamed:(NSString *)name
{
    MODSpecModel *result = nil;
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item.name isEqualToString:name])
        {
            result = item;
            break;
        }
    }
    return result;
}

- (BOOL)removeDependencyNamed:(NSString *)name
{
    NSMutableArray *dependencies = [NSMutableArray arrayWithArray:self.dependencies];
    BOOL result = NO;
    MODSpecModel *itemToRemove = nil;
    for (MODSpecModel *item in dependencies)
    {
        if ([item.name isEqualToString:name])
        {
            result = YES;
            itemToRemove = item;
            break;
        }
    }
    
    if (result)
    {
        [dependencies removeObject:itemToRemove];
        self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:dependencies];
    }
    
    return result;
}

- (NSArray *)dependenciesThatDependOn:(NSString *)name;
{
    NSMutableArray *dependents = [NSMutableArray array];
    
    // dependencies are arranged somewhat flat when stored, so we really only need to look at the first level deep.
    
    for (MODSpecModel *item in self.dependencies)
    {
        for (MODSpecModel *subItem in item.dependencies)
        {
            if ([subItem.name isEqualToString:name])
                [dependents addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:dependents];
}

- (NSArray *)dependenciesThatDependOn:(NSString *)name excluding:(NSString *)exclusionName
{
    NSMutableArray *dependents = [NSMutableArray array];
    
    // dependencies are arranged somewhat flat when stored, so we really only need to look at the first level deep.
    
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item.name isEqualToString:exclusionName])
            continue;
        
        for (MODSpecModel *subItem in item.dependencies)
        {
            if ([subItem.name isEqualToString:name])
                [dependents addObject:item];
        }
    }
    
    return [NSArray arrayWithArray:dependents];
}

@end
