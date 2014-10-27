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

- (BOOL)addDependency:(MODSpecModel *)dependency
{
    BOOL result = NO;
    NSMutableArray *newDeps = [self.dependencies mutableCopy];
    if (!newDeps)
        newDeps = [NSMutableArray array];
    
    // if it doesn't exist, add it.
    if (![newDeps containsObject:dependency])
    {
        dependency.dependencies = nil;
        dependency.dependenciesPath = nil;

        [newDeps addObject:dependency];
        
        self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:newDeps];
        result = YES;
    }
    else
    {
        // if it does, update it.
        [self updateDependency:dependency];
    }
    
    return result;
}

- (BOOL)updateDependency:(MODSpecModel *)dependency
{
    MODSpecModel *existing = [self dependencyNamed:dependency.name];
    if (!existing)
    {
        // it doesn't exist, so just add it.
        return [self addDependency:dependency];
    }
    
    existing.moduleURL = dependency.moduleURL;
    existing.sourcePath = dependency.sourcePath;
    existing.initialBranch = dependency.initialBranch;
    
    return YES;
}

- (BOOL)removeDependencyNamed:(NSString *)name
{
    BOOL result = NO;
    NSMutableArray *newDeps = [self.dependencies mutableCopy];
    for (MODSpecModel *item in newDeps)
    {
        if ([item.name isEqualToString:name])
        {
            [newDeps removeObject:item];
            result = YES;
            break;
        }
    }
    self.dependencies = (NSArray<MODSpecModel> *)[NSArray arrayWithArray:newDeps];
    return result;
}

- (MODSpecModel *)dependencyNamed:(NSString *)name
{
    for (MODSpecModel *item in self.dependencies)
    {
        if ([item.name isEqualToString:name])
            return item;
    }
    
    return nil;
}

- (NSArray<NSString> *)namesThatDependOn:(NSString *)name
{
    NSMutableArray *names = [NSMutableArray array];
    
    MODSpecModel *dummy = [[MODSpecModel alloc] init];
    dummy.name = name;
    
    for (MODSpecModel *item in self.dependencies)
    {
        MODSpecModel *spec = [MODSpecModel instanceFromName:item.name];
        if ([spec.dependencies containsObject:dummy])
            [names addObject:item.name];
    }
    
    if (names.count)
        return (NSArray<NSString> *)[NSArray arrayWithArray:names];
    
    return nil;
}

- (NSArray<NSString> *)dependencyNames
{
    NSMutableArray *names = [NSMutableArray array];
    
    for (MODSpecModel *item in self.dependencies)
    {
        [names addObject:item.name];
    }
    
    return (NSArray<NSString> *)[NSArray arrayWithArray:names];
}

@end
