//
//  SDModelObject.m
//  ios-shared
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDModelObject.h"
#import "NSDictionary+SDExtensions.h"

#pragma mark - SDObjectProperty interface declaration

// we use the SDObjectProperty implementation in SDDataMap.

@interface SDObjectProperty : NSObject

@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, strong) NSString *propertyType;
@property (nonatomic, strong) NSString *propertySubtype;
@property (nonatomic, assign) SEL propertySelector;

+ (NSArray *)propertiesForObject:(id)object;
+ (instancetype)propertyFromObject:(NSObject *)object named:(NSString *)name;
+ (instancetype)propertyFromString:(NSString *)propertyString;
- (BOOL)isValid;
- (Class)desiredOutputClass;

@end

#pragma mark - SDModelObject implementation

@implementation SDModelObject

- (id)init
{
    self = [super init];
    return self;
}

- (BOOL)validModel
{
    @throw [NSException exceptionWithName:@"SDModelObjectException" reason:@"Subclasses MUST override -validModel." userInfo:nil];
}

/*- (NSDictionary *)mappingDictionaryForData:(id)data
{
    // this is the base class, so we'll return nothing.
    return nil;
}

- (NSDictionary *)importMappingDictionaryForData:(id)data
{
    // this is the base class, so we'll return nothing.
    return nil;
}

- (NSDictionary *)exportMappingDictionary
{
    // this is the base class, so we'll return nothing.
    return nil;
}*/

+ (instancetype)mapFromObject:(id)sourceObject
{
    id modelObject = [[self alloc] init];
    [[SDDataMap map] mapObject:sourceObject toObject:modelObject];

    if ([modelObject validModel])
        return modelObject;

    return nil;
}

- (NSString *)modelDescription
{
    NSDictionary *aDict = [self dictionaryForModel:YES];
    return [NSString stringWithFormat:@"%@", [aDict description]];
}

#pragma mark - Dictionary representation

- (NSDictionary *)dictionaryForModel:(BOOL)showNils
{
    NSArray *properties = [SDObjectProperty propertiesForObject:self];
    NSMutableDictionary *outputDictionary = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < properties.count; i++)
    {
        SDObjectProperty *property = [properties objectAtIndex:i];
        
        // skip it if there's no property name.  this shouldn't happen,
        // but lets do it just in case.
        if (!property.propertyName)
            continue;
        
        id value = [self valueForKey:property.propertyName];
        if ([value isKindOfClass:[SDModelObject class]])
            value = [value dictionaryRepresentation];

        if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *oldArray = (NSArray *)value;
            NSMutableArray *newArray = [NSMutableArray array];
            for (NSUInteger oldArrayIndex = 0; oldArrayIndex < oldArray.count; oldArrayIndex++)
            {
                id newValue = [oldArray objectAtIndex:oldArrayIndex];
                if ([newValue isKindOfClass:[SDModelObject class]])
                    newValue = [newValue dictionaryRepresentation];
                
                if (newValue)
                    [newArray addObject:newValue];
            }
            
            value = newArray;
        }

        if (value)
            [outputDictionary setValue:value forKey:property.propertyName];
        else
        if (showNils)
            [outputDictionary setValue:@"<nil>" forKey:property.propertyName];
    }
    
    return [NSDictionary dictionaryWithDictionary:outputDictionary];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryForModel:NO];
}

#pragma mark - JSON Representations

- (NSData *)JSONRepresentation
{
    return [[self dictionaryRepresentation] JSONRepresentation];
}

- (NSString *)JSONStringRepresentation
{
    return [[self dictionaryRepresentation] JSONStringRepresentation];
}

@end

@implementation SDErrorModelObject

- (BOOL)validModel
{
    @throw [NSException exceptionWithName:@"SDErrorModelObjectException" reason:@"Subclasses MUST override -validModel." userInfo:nil];
}

@end
