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

@interface MODSpecModel ()
@property (nonatomic, strong) NSString *pathToModel;
@end

@implementation MODSpecModel

- (NSDictionary *)mappingDictionaryForData:(id)data
{
    return @{@"name": sdmo_key(self.name),
             @"projectURL": sdmo_key(self.projectURL),
             @"moduleURL": sdmo_key(self.moduleURL),
             @"licenseURL": sdmo_key(self.licenseURL),
             @"sourcePath": sdmo_key(self.sourcePath),
             @"initialBranch": sdmo_key(self.initialBranch),
             @"dependenciesPath": sdmo_key(self.dependenciesPath),
             @"dependencies": sdmo_key(self.dependencies)};
}

- (NSDictionary *)exportMappingDictionary
{
    return @{@"name": @"(NSString)name",
             @"projectURL": @"(NSString)projectURL",
             @"moduleURL": @"(NSString)moduleURL",
             @"licenseURL": @"(NSString)licenseURL",
             @"sourcePath": @"(NSString)sourcePath",
             @"initialBranch": @"(NSString)initialBranch",
             @"dependenciesPath": @"(NSString)dependenciesPath",
             @"dependencies": @"(NSArray<NSDictionary>)dependencies"};
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

+ (instancetype)instanceFromName:(NSString *)name;
{
    MODSpecModel *instance = [MODSpecModel sharedInstance];
    NSString *path = [instance dependencyLocalPathFromName:name];
    MODSpecModel *newInstance = [MODSpecModel instanceFromPath:path];
    
    return newInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
    }
    
    return self;
}

- (NSString *)localPath
{
    NSString *dependenciesPath = [MODSpecModel sharedInstance].dependenciesPath;
    NSString *dependenciesFullPath = [[SDCommandLineParser sharedInstance].currentWorkingPath stringByAppendingPathComponent:dependenciesPath];
    NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:self.name] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];

    return dependencyLocalPath;
}

- (NSString *)dependencyLocalPathFromName:(NSString *)name
{
    NSString *dependenciesFullPath = [[SDCommandLineParser sharedInstance].currentWorkingPath stringByAppendingPathComponent:self.dependenciesPath];
    
    NSString *dependencyName = name;
    dependencyName = [dependencyName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", dependencyName.pathExtension] withString:@""];
    NSString *dependencyLocalPath = [[dependenciesFullPath stringByAppendingPathComponent:dependencyName] stringWithPathRelativeTo:[SDCommandLineParser sharedInstance].startingWorkingPath];
    
    return dependencyLocalPath;
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

- (NSString *)description
{
    return self.name;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[MODSpecModel class]])
        return NO;
    
    MODSpecModel *obj = (MODSpecModel *)object;
    if ([self.name isEqualToString:obj.name])
        return YES;
    return NO;
}

- (void)addDependency:(MODSpecModel *)dependency
{
    NSMutableArray *newDeps = [self.dependencies mutableCopy];
    [newDeps addObject:dependency];
    self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:newDeps];
}

- (void)removeTopLevelDependencyNamed:(NSString *)name
{
    NSMutableArray *newDeps = [self.dependencies mutableCopy];
    for (MODSpecModel *item in newDeps)
    {
        if ([item.name isEqualToString:name])
        {
            [newDeps removeObject:item];
            break;
        }
    }
    self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:newDeps];
}

- (MODSpecModel *)topLevelDependencyNamed:(NSString *)name
{
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item.name isEqualToString:name])
            return item;
    }
    
    return nil;
}

- (BOOL)dependsOn:(NSString *)name
{
    BOOL result = NO;
    
    NSArray *deps = [self flatDependencyList];
    if ([deps containsObject:name])
        return YES;
    
    return result;
}

- (NSArray<NSString> *)topLevelNamesThatDependOn:(NSString *)name
{
    NSMutableArray *result = [NSMutableArray array];
    
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item dependsOn:name])
        {
            [result addObject:item.name];
        }
    }
    
    if (result.count == 0)
        return nil;
    
    return (NSArray<NSString> *)[NSArray arrayWithArray:result];
}

- (NSArray<NSString> *)flatDependencyList
{
    NSMutableArray *result = [NSMutableArray array];
    
    [self _flatDependencyList:result];
    
    if (result.count == 0)
        return nil;
    
    return (NSArray<NSString> *)[NSArray arrayWithArray:result];
}

- (void)_flatDependencyList:(NSMutableArray *)array
{
    for (MODSpecModel *item in self.dependencies)
    {
        if (![array containsObject:item.name])
            [array addObject:item.name];
        [item _flatDependencyList:array];
    }
}

@end
