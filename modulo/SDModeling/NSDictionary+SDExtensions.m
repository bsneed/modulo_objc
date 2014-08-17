//
//  NSDictionary+SDExtensions.m
//  SetDirection
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "NSDictionary+SDExtensions.h"
#import "NSString+SDExtensions.h"
#import "SDLog.h"

@implementation NSDictionary (SDExtensions)

- (NSDictionary *)dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
	NSMutableDictionary *result = [self mutableCopy];
	[result addEntriesFromDictionary:dictionary];
	return result;
}


- (NSString *)stringForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return obj;
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj stringValue];
    return nil;
}

- (NSInteger)intForKey:(NSString *)key { return [self integerForKey:key]; }
- (NSInteger)integerForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj integerValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj integerValue];
    return 0;
}

- (NSUInteger)unsignedIntForKey:(NSString *)key { return [self unsignedIntegerForKey:key]; }
- (NSUInteger)unsignedIntegerForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
    {
        NSNumber *number = [NSNumber numberWithInteger:[obj integerValue]];
        return [number unsignedIntegerValue];
    }
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj unsignedIntegerValue];
    return 0;
}

- (float)floatForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj doubleValue];
    return 0;
}

- (double)doubleForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj doubleValue];
    return 0;
}

- (long long)longLongForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj longLongValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj longLongValue];
    return 0;
}

- (BOOL)boolForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSString class]])
        return [obj boolValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj boolValue];
    return 0;
}

- (NSArray *)arrayForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    return nil;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]])
        return obj;
    return nil;
}

- (BOOL)keyExists:(NSString *)key
{
	return [self objectForKey:key] != nil;
}

// values for keypath

- (NSString *)stringForKeyPath:(NSString *)key
{
    id obj = [self valueForKeyPath:key];
    if ([obj isKindOfClass:[NSString class]])
        return obj;
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj stringValue];
    return nil;
}

- (NSInteger)intForKeyPath:(NSString *)keyPath { return [self integerForKeyPath:keyPath]; }
- (NSInteger)integerForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj integerValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj integerValue];
    return 0;
}

- (NSUInteger)unsignedIntForKeyPath:(NSString *)keyPath { return [self unsignedIntegerForKeyPath:keyPath]; }
- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
    {
        NSNumber *number = [NSNumber numberWithInteger:[obj integerValue]];
        return [number unsignedIntegerValue];
    }
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj unsignedIntegerValue];
    return 0;
}

- (CGFloat)floatForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj doubleValue];
    return 0;
}

- (double)doubleForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj doubleValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj doubleValue];
    return 0;
}

- (long long)longLongForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj longLongValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj longLongValue];
    return 0;
}

- (BOOL)boolForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSString class]])
        return [obj boolValue];
    else
    if ([obj isKindOfClass:[NSNumber class]])
        return [obj boolValue];
    return 0;
}

- (NSArray *)arrayForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    return nil;
}

- (NSArray *)dictionaryForKeyPath:(NSString *)keyPath
{
    id obj = [self valueForKeyPath:keyPath];
    if ([obj isKindOfClass:[NSDictionary class]])
        return obj;
    return nil;
}

- (NSString *)JSONStringRepresentation
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error)
        SDLog(@"error converting event into JSON: %@", error);
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

- (NSData *)JSONRepresentation
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error)
        SDLog(@"error converting event into JSON: %@", error);
    return data;
}

- (id)valueForKeyPath:(NSString*)keyPath defaultValue:(id)defaultValue
{
	id	value = [self valueForKeyPath:keyPath];
	
	// NSNull is a stand-in for an empty node, use the default value if no object or empty node
	if (value == nil || value == [NSNull null])
		value = defaultValue;
	
	return value;
}


- (NSString*)stringForKeyPath:(NSString*)keyPath defaultValue:(NSString*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a string, otherwise default
	if (![value isKindOfClass:[NSString class]])
		value = defaultValue;
	
	return value;
}



- (NSNumber*)numberForKeyPath:(NSString*)keyPath defaultValue:(NSNumber*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a number, otherwise default
	if (![value isKindOfClass:[NSNumber class]])
		value = defaultValue;
	
	return value;
}



- (NSArray*)arrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be an array, otherwise default
	if (![value isKindOfClass:[NSArray class]])
		value = defaultValue;
	
	return value;
}


- (NSDictionary*)dictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// The value is expected to be a dictionary, otherwise default
	if (![value isKindOfClass:[NSDictionary class]])
		value = defaultValue;
	
	return value;
}


- (NSArray*)conformedArrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// Conform the value to an array if it is not an array
	if (![value isKindOfClass:[NSArray class]])
		value = value ? [NSArray arrayWithObject:value] : defaultValue;
	
	return value;
}


- (NSDictionary*)conformedDictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue
{
	id	value = [self valueForKeyPath:keyPath defaultValue:defaultValue];
	
	// Conform the value to a dictionary if it is not a dictionary
	if (![value isKindOfClass:[NSDictionary class]])
		value = value ? [NSDictionary dictionaryWithObject:value forKey:@"default"] : defaultValue;
	
	return value;
}

- (NSString*)queryString
{
	NSMutableArray*	keyValuePairs = [NSMutableArray array];
	
	// Create an URL query string (properly URL-encoded) from the dictionary's keys and values
	for (NSString* key in self)
	{
		NSString*	value = [self objectForKey:key];
		
		[keyValuePairs addObject:[NSString stringWithFormat:@"%@=%@", [key escapedString], [value escapedString]]];
	}
	
	return [keyValuePairs componentsJoinedByString:@"&"];
}

+ (NSDictionary*)sectionDictionaryFromArray:(NSArray*)inputArray withSectionKeyBlock:(SDSectionKeyBlock)keyBlock
{
    NSMutableDictionary *sections = [NSMutableDictionary dictionary];
    for (id object in inputArray)
    {
        id <NSCopying> keyRepresentingThisSection = keyBlock(object);
        NSMutableArray *objectsForThisSection = [sections objectForKey:keyRepresentingThisSection];
        if (objectsForThisSection == nil)
        {
            objectsForThisSection = [NSMutableArray array];
            [sections setObject:objectsForThisSection forKey:keyRepresentingThisSection];
        }
        [objectsForThisSection addObject:object];
    }
    
    return [sections copy];
}

+ (NSDictionary *)mergeDictionaries:(NSArray *)dictionaries
{
    if (dictionaries.count == 0)
        return nil;
    
    // validate the items given to us and add the ones that match.
    NSMutableArray *validatedDictionaries = [NSMutableArray array];
    for (NSUInteger i = 0; i < dictionaries.count; i++)
    {
        id item = [dictionaries objectAtIndex:i];
        if ([item isKindOfClass:[NSDictionary class]])
            [validatedDictionaries addObject:item];
    }
    
    NSMutableDictionary *tempDictionary = [NSMutableDictionary dictionary];
    
    // lets do them in order ...
    for (NSUInteger i = 0; i < validatedDictionaries.count; i++)
    {
        NSDictionary *dictionary = [validatedDictionaries objectAtIndex:i];
        NSArray *keyList = [dictionary allKeys];
        
        for (NSString *key in keyList)
        {
            // this takes all the data provided in replacements and overwrites any default
            // values specified in the plist.
            NSObject *value = [dictionary objectForKey:key];
            [tempDictionary setObject:value forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:tempDictionary];
}

@end
