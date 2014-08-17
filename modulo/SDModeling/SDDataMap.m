//
//  SDDataMap.m
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/14/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "SDDataMap.h"
#import "SDModelObject.h"
#import "NSObject+SDExtensions.h"
#import "objc/runtime.h"
#import "SDLog.h"

@interface SDObjectProperty : NSObject

@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, strong) NSString *propertyType;
@property (nonatomic, strong) NSString *propertySubtype;
@property (nonatomic, assign) SEL propertySelector;

@property (nonatomic, readonly) Class propertyTypeClass;
@property (nonatomic, readonly) Class propertySubtypeClass;

+ (NSArray *)propertiesForObject:(id)object;
+ (instancetype)propertyFromClass:(Class)aClass named:(NSString *)name;
+ (instancetype)propertyFromObject:(NSObject *)object named:(NSString *)name;
+ (instancetype)propertyFromString:(NSString *)propertyString;
- (BOOL)isValid;
- (Class)desiredOutputClass;

@end

#pragma mark - SDDataMap definition

@implementation SDDataMap
{
    NSDictionary *_mapDictionary;
}

/**
 This is *NOT* thread-safe.  Do not mutate it under any circumstances!
 
 This is used for the number formatting aspects of data mappings.
 */
static NSNumberFormatter *__internalFormatter = nil;
static dispatch_once_t __formatterOnceToken = 0;


#pragma mark - Initializers

+ (SDDataMap *)mapForName:(NSString *)mapName
{
    SDDataMap *result = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:mapName ofType:@"plist"];
    if (path)
    {
	    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	    result = [self mapForDictionary:dictionary];
    }
    
    return result;
}

+ (SDDataMap *)mapForDictionary:(NSDictionary *)dictionary
{
 	SDDataMap *result = nil;
    
	result = [[SDDataMap alloc] init];
	result->_mapDictionary = [dictionary copy];
    
    dispatch_once(&__formatterOnceToken, ^{
        __internalFormatter = [[NSNumberFormatter alloc] init];
        [__internalFormatter setNumberStyle:NSNumberFormatterNoStyle];
    });
                  
	return result;
}

+ (SDDataMap *)map
{
    return [[self class] mapForDictionary:nil];
}

#pragma mark - Public interfaces

- (void)mapObject:(id)object1 toObject:(id)object2
{
    [self mapObject:object1 toObject:object2 strict:YES];
}

- (void)mapJSON:(id)object1 toObject:(id)object2
{
    [self mapObject:object1 toObject:object2 strict:YES];
}

- (void)mapObject:(id)object1 toObject:(id)object2 strict:(BOOL)strict
{
    // allow for pulling data from deeper within objec1.
    id tempObject1 = object1;
    if ([object2 respondsToSelector:@selector(initialKeyPath)])
    {
        NSString *initialKeyPath = [object2 initialKeyPath];
        id newObject1 = [self valueFromObject:object1 forKeyPath:initialKeyPath];
        if (newObject1)
            tempObject1 = newObject1;
    }
    object1 = tempObject1;
    
    // check for import/export mapping.
    if (!_mapDictionary)
    {
        // typically the destination object will be a model and should supply the map
        if ([object2 respondsToSelector:@selector(mappingDictionaryForData:)])
            _mapDictionary = [object2 mappingDictionaryForData:object1];
        else
        if ([object1 respondsToSelector:@selector(exportMappingDictionary)])
            _mapDictionary = [object1 exportMappingDictionary];
    }
    
    [_mapDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id value = [self valueFromObject:object1 forKeyPath:key];
        if (!value)
            return;
        
        NSString *destPropertyString = (NSString *)obj;
        // check the destPropertyString to make sure it's not a keyPath.
        if ([destPropertyString rangeOfString:@"."].location != NSNotFound)
            [NSException raise:@"SDException" format:@"Destionation maps do not support key paths (%@)", destPropertyString];
        
        SDObjectProperty *destProperty = [SDObjectProperty propertyFromString:destPropertyString];
        
        // if we don't have a destination property type, do some introspection on the destination
        // object to see what it's type actually is.
        if (!destProperty.propertyType)
        {
            SDObjectProperty *actualProperty = [SDObjectProperty propertyFromObject:object2 named:destProperty.propertyName];
            destProperty.propertyType = actualProperty.propertyType;
        }

        if (destProperty.propertySelector)
        {
            // do the selector shit.
            [self performSelector:destProperty.propertySelector destProperty:destProperty withValue:value targetObject:object2];
        }
        else
        {
            if (!destProperty.propertyType)
            {
                // it doesn't have a subtype, so just set it.
                [self setValue:value destProperty:destProperty targetObject:object2];
            }
            else
            {
                Class outputClass = [destProperty desiredOutputClass];

                // if we want an array and the value isn't an array or set, then we can't really do
                // anything here.
                if ([destProperty.propertyType isEqualToString:@"NSArray"] && ![value isKindOfClass:[NSArray class]] && ![value isKindOfClass:[NSSet class]])
                {
                    // we didn't get a match up.  weep silently.
                    SDLog(@"We didn't get a valid type mapping for the data provided.");
                }
                else
                if ([value isKindOfClass:[NSSet class]])
                {
                    NSArray *arrayItems = [value allObjects];
                    
                    // is the destination an array?  if so, hand off to our boy Leroy so he can take care of bid'ness.
                    
                    // ^  it sure as shit is now.  setArrayValue knows how to convert between sets and arrays and
                    // outputs the proper type.
                    
                    [self setArrayValue:arrayItems destProperty:destProperty targetObject:object2];
                }
                else
                if ([value isKindOfClass:[NSArray class]])
                {
                    // is the destination an array?  if so, hand off to our boy Leroy so he can take care of bid'ness.
                    [self setArrayValue:value destProperty:destProperty targetObject:object2];
                }
                else
                if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:outputClass])
                {
                    // it's a dictionary, or some other kind of object-y type thing.
                    [self setObjectValue:value destProperty:destProperty targetObject:object2];
                }
                else
                {
                    // handle anything else we get.
                    [self setObjectValue:value destProperty:destProperty targetObject:object2];
                }
            }
        }
    }];
    
    // Now that the object has been mapped, let's tell the
    // target object that the model has been loaded
    if ([object2 respondsToSelector:@selector(modelDidLoad)])
    {
        [object2 modelDidLoad];
    }
}

#pragma mark - Collection and Model handling

- (void)setObjectValue:(id)value destProperty:(SDObjectProperty *)destProperty targetObject:(id)targetObject
{
    Class outputClass = [destProperty desiredOutputClass];

    id outputObject = [[outputClass alloc] init];
    
    // lets make sure it's something that's not immutable and avoid any exceptions.
    if ([outputObject isKindOfClass:[NSDictionary class]])
        outputObject = [NSMutableDictionary dictionary];
    else
    if ([outputObject isKindOfClass:[NSArray class]])
        outputObject = [NSMutableArray array];
    
    BOOL respondsToCreateWithData = [outputClass respondsToSelector:@selector(createWithData:)];
    BOOL respondsToMappingDictionaryForData = [outputObject respondsToSelector:@selector(mappingDictionaryForData:)];
    
    /*if (respondsToCreateWithData && respondsToMappingDictionaryForData)
        [NSException raise:@"SDException" format:@"Model objects must not implement both createWithData: and mappingDictionaryForData:.  See documentation."];*/
    
    if (respondsToCreateWithData)
    {
        // if the model object class responds to createWithData, use that.
        outputObject = [[outputObject class] createWithData:value];

        // assume models are valid unless model explicitly says no.
        BOOL validModel = YES;
        if ([outputObject respondsToSelector:@selector(validModel)])
        {
            validModel = [outputObject validModel];
        }
        
        if (validModel)
            [self setValue:outputObject destProperty:destProperty targetObject:targetObject];
    }
    else
    if (respondsToMappingDictionaryForData || [value respondsToSelector:@selector(exportMappingDictionary)])
    {
        SDDataMap *newMap = [SDDataMap map];
        [newMap mapObject:value toObject:outputObject strict:YES];
        
        // assume models are valid unless model explicitly says no.
        BOOL validModel = YES;
        if ([outputObject respondsToSelector:@selector(validModel)])
        {
            validModel = [outputObject validModel];
        }
        
        if (validModel)
            [self setValue:outputObject destProperty:destProperty targetObject:targetObject];
    }
    else
    {
        // it doesn't support the mapping protocol, so just set it.
        [self setValue:value destProperty:destProperty targetObject:targetObject];
    }
}

- (void)setArrayValue:(NSArray *)value destProperty:(SDObjectProperty *)destProperty targetObject:(id)targetObject
{
    Class outputClass = [destProperty desiredOutputClass];
    
    BOOL itsAnNSSet = NO;
    if (outputClass == [NSSet class])
    {
        outputClass = [NSArray class];
        itsAnNSSet = YES;
    }
    
    NSArray *array = value;
    NSMutableArray *workArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < array.count; i++)
    {
        id item = [array objectAtIndex:i];
        if ([item isKindOfClass:outputClass])
        {
            // the types match already, just add it.
            [workArray addObject:item];
        }
        else
        {
            // maybe it's a model object?
            id outputObject = [[outputClass alloc] init];
            
            // lets make sure it's something that's not immutable and avoid any exceptions.
            if ([outputObject isKindOfClass:[NSDictionary class]])
                outputObject = [NSMutableDictionary dictionary];
            else
            if ([outputObject isKindOfClass:[NSArray class]])
                outputObject = [NSMutableArray array];
            
            BOOL respondsToCreateWithData = [outputClass respondsToSelector:@selector(createWithData:)];
            BOOL respondsToMappingDictionaryForData = [outputObject respondsToSelector:@selector(mappingDictionaryForData:)];
            
            /*if (respondsToCreateWithData && respondsToMappingDictionaryForData)
                [NSException raise:@"SDException" format:@"Model objects must not implement both createWithData: and mappingDictionaryForData:.  See documentation."];*/
            
            if (respondsToCreateWithData)
            {
                // if the model object class responds to createWithData, use that.
                outputObject = [[outputObject class] createWithData:item];
                
                // assume models are valid unless model explicitly says NO.
                BOOL validModel = YES;
                if ([outputObject respondsToSelector:@selector(validModel)])
                    validModel = [outputObject validModel];
                
                if (validModel && outputObject)
                    [workArray addObject:outputObject];
            }
            else
            if (respondsToMappingDictionaryForData || [item respondsToSelector:@selector(exportMappingDictionary)])
            {
                // if the model object or item doesn't support the protocol, we don't know how
                // to map the objects, if it does, let's do it.

                SDDataMap *newMap = [SDDataMap map];
                [newMap mapObject:item toObject:outputObject strict:YES];
                
                // assume models are valid unless model explicitly says NO.
                BOOL validModel = YES;
                if ([outputObject respondsToSelector:@selector(validModel)])
                    validModel = [outputObject validModel];

                if (validModel && outputObject)
                    [workArray addObject:outputObject];
            }
            else
            {
                // it's of some other thing..
                outputObject = [self convertValue:item forType:[outputClass className]];
                if (outputObject)
                    [workArray addObject:outputObject];
            }
        }
    }
    
    id outputArray = [NSArray arrayWithArray:workArray];
    
    if (itsAnNSSet)
        outputArray = [NSSet setWithArray:workArray];
    
    [self setValue:outputArray destProperty:destProperty targetObject:targetObject];
}

#pragma mark - Utilities

/// This is a classwide replacement for [NSObject valueForKeyPath:]
/// it adds array notation to the standard valueForKeyPath
/// such that a mapping dictionary entry @"foo[1].bar": @"fooBar" works properly
- (id)valueFromObject:(NSObject *)sourceObject forKeyPath:(NSString *)keyPath
{
    id value = nil;
    
    NSRegularExpression *indexRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\().*(?=\\))|(?<=\\[).*(?=\\])" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *pathRegex = [NSRegularExpression regularExpressionWithPattern:@"^[^\\[]*" options:NSRegularExpressionCaseInsensitive error:nil];

    id tempValue = sourceObject;
    
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    for (NSUInteger i = 0; i < keyPaths.count; i++)
    {
        // ie: blah[123]
        NSString *fullPath = [keyPaths objectAtIndex:i];
        
        // find the index, ie: 123
        NSTextCheckingResult *match = [indexRegex firstMatchInString:fullPath options:0 range:NSMakeRange(0, fullPath.length)];
        NSString *stringIndex = [fullPath substringWithRange:[match rangeAtIndex:0]];
        if (stringIndex.length == 0)
            stringIndex = nil;

        // get the actual path without the index, ie: blah
        match = [pathRegex firstMatchInString:fullPath options:0 range:NSMakeRange(0, fullPath.length)];
        NSString *path = [fullPath substringWithRange:[match rangeAtIndex:0]];
        if (path.length == 0)
            path = nil;

        if (stringIndex && path)
        {
            NSUInteger index = [stringIndex unsignedIntegerValue];
            
            tempValue = [tempValue valueForKey:path];
            if (tempValue && [tempValue isKindOfClass:[NSArray class]])
            {
                // make sure we don't blast past the end of the array.
                NSArray *array = (NSArray *)tempValue;
                if (index < array.count)
                    tempValue = [tempValue objectAtIndex:index];
                else
                {
                    // there's nothing to query for a value, return nil.
                    tempValue = nil;
                }
            }
        }
        else
        {
            if (path && [tempValue keyPathExists:path])
                tempValue = [tempValue valueForKey:path];
            else
            {
                // there's nothing to query for a value, return nil.
                tempValue = nil;
            }
        }
    }
    
    if (tempValue != sourceObject)
        value = tempValue;
    
    return value;
}

- (void)setValue:(id)value destProperty:(SDObjectProperty *)destProperty targetObject:(id)targetObject
{
    NSString *basePath = destProperty.propertyName;
    NSArray *components = [basePath componentsSeparatedByString:@"."];
    
    NSString *propName = [components lastObject];
    
    NSString *trailingPath = [NSString stringWithFormat:@".%@", propName];
    NSString *parentPath = [basePath stringByReplacingOccurrencesOfString:trailingPath withString:@""];
    
    if ([targetObject keyPathExists:parentPath])
    {
        id targetParent = [self valueFromObject:targetObject forKeyPath:parentPath];
        if (![parentPath isEqualToString:propName])
        {
            destProperty = [SDObjectProperty propertyFromObject:targetParent named:propName];
        }
    }
    
    value = [self convertValue:value forProperty:destProperty];
    [targetObject setValue:value forKeyPath:parentPath];
}

- (id)convertValue:(id)value forProperty:(SDObjectProperty *)property
{
    id newValue = value;
    
    if ([property.propertyType isEqualToString:@"NSDecimalNumber"])
    {
        if ([value isKindOfClass:[NSNumber class]])
        {
            newValue = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
        }
    }
    
    return [self convertValue:newValue forType:property.propertyType];
}

- (id)convertValue:(id)value forType:(NSString *)type
{
    // All values are instances of NSString, NSNumber, NSArray, NSDictionary, or NSNull.
    
    // if we didn't do any conversion, send the same thing back out.
    id result = value;
    
    if (!value)
    {
        // handle non-obj types that need to be set to 0.
        if ([type length] == 1)
            result = [NSNumber numberWithInteger:0]; // kvo will turn this into 0 for everything.
        else
            result = nil;
    }
    else
    if ([value isKindOfClass:[NSNull class]])
        result = nil;
    else
    if ([value isKindOfClass:[NSString class]])
    {
        if ([value isEqualToString:@"null"])
            result = nil;
        else
        // is this one necessary?
        if ([value isEqualToString:@"<nil>"])
            result = nil;
        else
        {
            if ([type isEqualToString:@"NSNumber"])
            {
                result = [__internalFormatter numberFromString:value];
            }
        }
    }
    else
    if ([value isKindOfClass:[NSNumber class]])
    {
        if ([type isEqualToString:@"NSString"])
            result = [value stringValue];
    }
    
    // it's a C type, and we're about to try to set it to nil, yikes!
    if (type.length == 1 && !result)
        result = [NSNumber numberWithInteger:0];
    
    return result;
}

- (void)performSelector:(SEL)selector destProperty:(SDObjectProperty *)destProperty withValue:(id)value targetObject:(id)targetObject
{
    // keeps implementors from needing to worry about NSNull.
    if ([value isKindOfClass:[NSNull class]])
        value = nil;
    
    NSString *basePath = destProperty.propertyName;
    NSArray *components = [basePath componentsSeparatedByString:@"."];
    
    NSString *propName = [components lastObject];
    
    NSString *trailingPath = [NSString stringWithFormat:@".%@", propName];
    NSString *parentPath = [basePath stringByReplacingOccurrencesOfString:trailingPath withString:@""];
    
    if ([targetObject keyPathExists:parentPath])
    {
        id targetParent = [self valueFromObject:targetObject forKeyPath:parentPath];
        if (![parentPath isEqualToString:propName] && targetParent)
            targetObject = targetParent;
    }
    
    // call that selector..
    [targetObject performSelector:selector returnAddress:nil argumentAddresses:&value];
}

@end


#pragma mark - SDObjectProperty definition

@implementation SDObjectProperty

+ (instancetype)property
{
    return [[[self class] alloc] init];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"propertyName = %@, propertyType = %@, propertySubType = %@", self.propertyName, self.propertyType, self.propertySubtype];
}

+ (NSArray *)propertiesForClass:(id)objectClass
{
    NSMutableArray *results = [NSMutableArray array];
    
    unsigned int outCount;
    NSUInteger i;
    objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if (propName)
        {
            SDObjectProperty *objectProperty = [SDObjectProperty property];
            objectProperty.propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            objectProperty.propertyType = [SDObjectProperty propertyType:property];

            if (objectProperty.isValid)
                [results addObject:objectProperty];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSArray arrayWithArray:results];
}


+ (NSArray *)propertiesForObject:(id)object
{
    if (!object)
        return nil;
    
    NSMutableArray *results = [NSMutableArray array];
    
    Class objectClass = [object class];
    [results addObjectsFromArray:[self propertiesForClass:objectClass]];
    
    // enumerate superclasses if it's a model object and get their properties as well.
    if ([object isKindOfClass:[SDModelObject class]])
    {
        objectClass = [objectClass superclass];
        while ([objectClass isSubclassOfClass:[SDModelObject class]] && ![[objectClass className] isEqualToString:[SDModelObject className]])
        {
            [results addObjectsFromArray:[self propertiesForClass:objectClass]];
            objectClass = [objectClass superclass];
        }
    }
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSArray arrayWithArray:results];
}

+ (instancetype)propertyFromClass:(Class)class named:(NSString *)name
{
    NSArray *nameParts = [name componentsSeparatedByString:@"."];
    Class aClass = class;
    
    NSString *propertyType = nil;
    NSString *propertySubtype = nil;
    
    for (NSUInteger i = 0; i < nameParts.count; i++)
    {
        NSString *propertyName = [nameParts objectAtIndex:i];
        objc_property_t property = class_getProperty(aClass, [propertyName UTF8String]);
        propertyType = [SDObjectProperty propertyType:property];
        if (propertyType.length > 2)
        {
            Class nextClass = NSClassFromString(propertyType);
            if (nextClass)
                aClass = nextClass;
        }
        else
            propertyType = nil;
    }
    
    SDObjectProperty *objectProperty = [SDObjectProperty property];

    if (propertyType)
    {
        propertyType = [propertyType stringByReplacingOccurrencesOfString:@">" withString:@""];
        NSArray *typeParts = [propertyType componentsSeparatedByString:@"<"];
        if (typeParts.count > 1)
        {
            propertyType = [typeParts objectAtIndex:0];
            propertySubtype = [typeParts objectAtIndex:1];
        }
    }
    
    objectProperty.propertyType = propertyType;
    objectProperty.propertySubtype = propertySubtype;
    objectProperty.propertyName = name;
    
    return objectProperty;
}

+ (instancetype)propertyFromObject:(NSObject *)object named:(NSString *)name
{
    if (!object || !name)
        return nil;
    
    SDObjectProperty *objectProperty = nil;
    objc_property_t property = class_getProperty([object class], [name UTF8String]);
    if (property)
    {
        const char *propName = property_getName(property);
        if (propName)
        {
            objectProperty = [SDObjectProperty property];
            objectProperty.propertyName = [NSString stringWithUTF8String:propName];
            objectProperty.propertyType = [SDObjectProperty propertyType:property];
            if (!objectProperty.isValid)
                return nil;
        }
    }
    
    return objectProperty;
}

+ (instancetype)propertyFromString:(NSString *)propertyString
{
    SDObjectProperty *property = [SDObjectProperty property];
    [property interpretPropertyString:propertyString];
    if ([property isValid])
        return property;
    
    return nil;
}

- (void)setPropertyType:(NSString *)propertyType
{
    if (propertyType && [propertyType rangeOfString:@"<"].location != NSNotFound)
    {
        NSRegularExpression *typeRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\().*(?=\\))|(?<=\\<).*(?=\\>)" options:0 error:nil];
        NSString *propertySubtype = nil;
        if (propertyType && [typeRegex numberOfMatchesInString:propertyType options:0 range:NSMakeRange(0, propertyType.length)])
        {
            propertySubtype = [propertyType substringWithRange:[typeRegex rangeOfFirstMatchInString:propertyType options:0 range:NSMakeRange(0, propertyType.length)]];
            if (propertySubtype)
            {
                propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\\((.*)(<.*>)\\)|<(.*)>|\\((.*)\\)" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, propertyType.length)];
                _propertySubtype = propertySubtype;
            }
        }
    }
    _propertyType = propertyType;
}

+ (NSString *)propertyType:(objc_property_t)property
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strlcpy(buffer, attributes, sizeof(buffer));
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL)
    {
        if (attribute[0] == 'T' && attribute[1] != '@')
        {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return [NSString stringWithUTF8String:(const char *)[name cStringUsingEncoding:NSASCIIStringEncoding]];
        }
        else
        if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2)
        {
            // it's an ObjC id type:
            return @"id";
        }
        else
        if (attribute[0] == 'T' && attribute[1] == '@')
        {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return [NSString stringWithUTF8String:(const char *)[name cStringUsingEncoding:NSASCIIStringEncoding]];
        }
    }
    
    return @"";
}
                
- (Class)propertyTypeClass
{
    if (self.propertyType.length > 1)
        return NSClassFromString(self.propertyType);
    return nil;
}

- (Class)propertySubtypeClass
{
    if (self.propertySubtype.length > 1)
        return NSClassFromString(self.propertyType);
    return nil;
}

- (void)interpretPropertyString:(NSString *)propertyString
{
    NSString *path = [propertyString stringByReplacingOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [propertyString length]-1)];
    
    /*
     these regex's work for:
     
     (NSArray<RxObject>)blah
     <RxObject>blah
     (RxObject)blah
     @selector(booya:)
     */
    
    BOOL isSelector = ([path rangeOfString:@"@"].location != NSNotFound);

    NSString *propertyName = [path stringByReplacingOccurrencesOfString:@"\\((.*)(<.*>)\\)|<(.*)>|\\((.*)\\)" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, path.length)];

    NSRegularExpression *typeRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=\\().*(?=\\))|(?<=\\<).*(?=\\>)" options:0 error:nil];
    NSString *propertyType = nil;
    if (path && [typeRegex numberOfMatchesInString:path options:0 range:NSMakeRange(0, path.length)])
    {
        propertyType = [path substringWithRange:[typeRegex rangeOfFirstMatchInString:path options:0 range:NSMakeRange(0, path.length)]];
    }
    
    if (isSelector)
    {
        self.propertyName = @"selector";
        self.propertySelector = NSSelectorFromString(propertyType);
    }
    else
    if (!isSelector && propertyName && propertyName.length > 1)
    {
        // break the property type apart if we need to.
        
        NSString *propertySubtype = nil;
        if (propertyType && [typeRegex numberOfMatchesInString:propertyType options:0 range:NSMakeRange(0, propertyType.length)])
        {
            propertySubtype = [propertyType substringWithRange:[typeRegex rangeOfFirstMatchInString:propertyType options:0 range:NSMakeRange(0, propertyType.length)]];
            if (propertySubtype)
                propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\\((.*)(<.*>)\\)|<(.*)>|\\((.*)\\)" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, propertyType.length)];
        }
        
        self.propertyName = propertyName;
        self.propertyType = propertyType;
        self.propertySubtype = propertySubtype;
    }
}

- (BOOL)isValid
{
    BOOL isValid = NO;
    
    isValid = ((self.propertyName && self.propertyName.length > 1) || self.propertySelector);
    
    return isValid;
}

- (Class)desiredOutputClass
{
    if ([self.propertyType isEqualToString:@"NSArray"])
        return NSClassFromString(self.propertySubtype);
    if (self.propertyType)
        return NSClassFromString(self.propertyType);
    
    return nil;
}

@end


#pragma mark - NSString extensions

// Helper extension code

@implementation NSString(SDDataMap)

/*
 
 NSString has these conversion methods already.
 
 - doubleValue;
 - floatValue;
 - intValue;
 - integerValue;
 - longLongValue;
 - boolValue;
 
 ... so we implement these to allow KVO to do type conversion on its own.
 
 - charValue;
 - shortValue;
 - decimalValue;
 - longValue;
 - unsignedCharValue;
 - unsignedIntegerValue;
 - unsignedIntValue;
 - unsignedLongLongValue;
 - unsignedLongValue;
 - unsignedShortValue;
 
 */

- (NSNumber *)numberValue
{
    dispatch_once(&__formatterOnceToken, ^{
        __internalFormatter = [[NSNumberFormatter alloc] init];
        [__internalFormatter setNumberStyle:NSNumberFormatterNoStyle];
    });
    
    return [__internalFormatter numberFromString:self];
}

- (char)charValue
{
    // handle some outlying cases.
    if ([self length] == 0)
        return 0;
    
    // look for the normal strings used for bool values.
    
    NSString *temp = [self uppercaseString];
    if ([temp isEqualToString:@"TRUE"])
        return 1;
    else
    if ([temp isEqualToString:@"FALSE"])
        return 0;
    else
    if ([temp isEqualToString:@"YES"])
        return 1;
    else
    if ([temp isEqualToString:@"NO"])
        return 0;
    else
    if ([temp isEqualToString:@"true"])
        return 1;
    else
    if ([temp isEqualToString:@"false"])
        return 0;
    else
    if ([temp isEqualToString:@"yes"])
        return 1;
    else
    if ([temp isEqualToString:@"no"])
        return 0;
    else
    if ([temp isEqualToString:@"0"])
        return 0;
    else
    if ([temp isEqualToString:@"1"])
        return 1;
    
    // default result should be false.
    return 0;
}

- (short)shortValue
{
    short result = [[self numberValue] shortValue];
    return result;
}

- (NSDecimal)decimalValue
{
    NSDecimal result = [[self numberValue] decimalValue];
    return result;
}

- (long)longValue
{
    long result = [[self numberValue] longValue];
    return result;
}

- (unsigned char)unsignedCharValue
{
    unsigned char result = [[self numberValue] unsignedCharValue];
    return result;
}

- (NSUInteger)unsignedIntegerValue
{
    NSUInteger result = [[self numberValue] unsignedIntegerValue];
    return result;
}

- (unsigned int)unsignedIntValue
{
    unsigned int result = [[self numberValue] unsignedIntValue];
    return result;
}

- (unsigned long long)unsignedLongLongValue
{
    unsigned long long result = [[self numberValue] unsignedLongLongValue];
    return result;
}

- (unsigned long)unsignedLongValue
{
    unsigned long result = [[self numberValue] unsignedLongValue];
    return result;
}

- (unsigned short)unsignedShortValue
{
    unsigned short result = [[self numberValue] unsignedShortValue];
    return result;
}

@end

#pragma mark - SDDataModelProtocol map helpers

NSString *_sddm_key(id object, NSString *propertyName)
{
    NSMutableArray *kvoParts = [[propertyName componentsSeparatedByString:@"."] mutableCopy];
    if (kvoParts.count < 2)
        [NSException raise:@"sdmo_key" format:@"%@ is not properly being used with sdmo_key().", propertyName];
    
    // remove the first one, as it's almost certainly the same as "object", ie: self.
    [kvoParts removeObjectAtIndex:0];

    NSMutableString *keyPath = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < kvoParts.count; i++)
    {
        if (i > 0)
            [keyPath appendString:@"."];
        [keyPath appendString:[kvoParts objectAtIndex:i]];
    }
    
    SDObjectProperty *property = [SDObjectProperty propertyFromClass:[object class] named:keyPath];
    
    NSString *propertyType = property.propertyType;
    NSString *propertySubtype = property.propertySubtype;
    NSString *propertyString = nil;
    
    if (propertyType.length > 1 && propertySubtype.length > 1)
        propertyString = [NSString stringWithFormat:@"(%@<%@>)%@", propertyType, propertySubtype, keyPath];
    else
    if (propertyType.length > 1)
        propertyString = [NSString stringWithFormat:@"(%@)%@", propertyType, keyPath];
    else
        propertyString = [NSString stringWithString:keyPath];
    
    return propertyString;
}

NSString *_sddm_selector(id object, SEL selector)
{
    const char *selectorName = sel_getName(selector);

    if (![object respondsToSelector:selector])
        [NSException raise:@"sdmo_selector" format:@"%@ does not respond to %s", NSStringFromClass([object class]), selectorName];
    
    NSString *selectorString = [NSString stringWithFormat:@"@selector(%s)", selectorName];
    return selectorString;
}
