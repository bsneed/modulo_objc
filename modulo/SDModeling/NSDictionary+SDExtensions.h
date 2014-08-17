//
//  NSDictionary+SDExtensions.h
//  SetDirection
//
//  Created by Brandon Sneed on 6/27/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SDSectionKeyBlock)(id blockObject);

/**
 A number of these typeForKey type methods came into being to extract a specific type from a given object, e.g. in the case of badly typed data in a JSON response.
 So, if intForKey is provided a key that points to a string, then the method will try and convert the string into an int and return that using standard underlying data type conversion methods.
 */

@interface NSDictionary (SDExtensions)

/**
 Returns a `NSString` representation of the object for `key`. Returns `nil` if no representation is available using standard underlying data type conversion methods.
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 Returns a `NSInteger` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSInteger)intForKey:(NSString *)key;

/**
 Returns a `NSInteger` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSInteger)integerForKey:(NSString *)key;

/**
 Returns a `NSUInteger` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSUInteger)unsignedIntForKey:(NSString *)key;

/**
 Returns a `NSUInteger` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;

/**
 Returns a `float` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (float)floatForKey:(NSString *)key;

/**
 Returns a `double` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (double)doubleForKey:(NSString *)key;

/**
 Returns a `long long` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (long long)longLongForKey:(NSString *)key;

/**
 Returns a `BOOL` representation of the object for `key`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (BOOL)boolForKey:(NSString *)key;

/**
 Returns the object for `key` as NSArray. Returns `nil` otherwise.
 */
- (NSArray *)arrayForKey:(NSString *)key;

/**
 Returns the object for `key` as NSDictionary.  Returns `nil` otherwise.
 */
- (NSDictionary *)dictionaryForKey:(NSString *)key;

/**
 Returns `YES` if an object exists for `key`. Returns `NO` otherwise.
 */
- (BOOL)keyExists:(NSString *)key;


/**
 Returns a `NSString` representation of the object for `keyPath`. Returns `nil` if no representation is available using standard underlying data type conversion methods.
 */
- (NSString *)stringForKeyPath:(NSString *)keyPath;

/**
 Returns a `NSInteger` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSInteger)intForKeyPath:(NSString *)keyPath;

/**
 Returns a `NSInteger` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSInteger)integerForKeyPath:(NSString *)keyPath;

/**
 Returns a `NSUInteger` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSUInteger)unsignedIntForKeyPath:(NSString *)keyPath;

/**
 Returns a `NSUInteger` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (NSUInteger)unsignedIntegerForKeyPath:(NSString *)keyPath;

/**
 Returns a `float` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (CGFloat)floatForKeyPath:(NSString *)keyPath;

/**
 Returns a `double` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (double)doubleForKeyPath:(NSString *)keyPath;

/**
 Returns a `long long` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (long long)longLongForKeyPath:(NSString *)keyPath;

/**
 Returns a `BOOL` representation of the object for `keyPath`. Returns `0` if no representation is available using standard underlying data type conversion methods.
 */
- (BOOL)boolForKeyPath:(NSString *)keyPath;

/**
 Returns the object for `keyPath` if it is a kind of NSArray. Returns `nil` otherwise.
 */
- (NSArray *)arrayForKeyPath:(NSString *)keyPath;

/**
 Returns the object for `keyPath` if it is a kind of NSDictionary. Returns `nil` otherwise.
 */
- (NSDictionary *)dictionaryForKeyPath:(NSString *)keyPath;

/**
 Returns an NSData * containing the JSON representation of this object.
 */
- (NSData *)JSONRepresentation;

/**
 Returns an NSString * containing the JSON representation of this object.
 */
- (NSString *)JSONStringRepresentation;

/**
 Returns a `NSString` representation of the object for `keyPath`. Returns `defaultValue` if no representation is available using standard underlying data type conversion methods. If no default value is provided then `nil` is returned.
 */
- (NSString*)stringForKeyPath:(NSString*)keyPath defaultValue:(NSString*)defaultValue;

/**
 Returns a `NSNumber` representation of the object for `keyPath`. Returns `defaultValue` if no representation is available using standard underlying data type conversion methods. If no default value is provided then `nil` is returned.
 */
- (NSNumber*)numberForKeyPath:(NSString*)keyPath defaultValue:(NSNumber*)defaultValue;

/**
 Returns a `NSArray` representation of the object for `keyPath`. Returns `defaultValue` if no representation is available using standard underlying data type conversion methods. If no default value is provided then `nil` is returned.
 */
- (NSArray*)arrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue;

/**
 Returns a `NSDictionary` representation of the object for `keyPath`. Returns `defaultValue` if no representation is available using standard underlying data type conversion methods. If no default value is provided then `nil` is returned.
 */
- (NSDictionary*)dictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue;


/**
 Returns a `NSArray` of the object at the `keypath`.  If the object is a NSArray then it is returned as is.  If it is not a NSArray then the object is wrapped in an array.  If the `keypath` doesn't exist then the default value is returned.
 */
- (NSArray*)conformedArrayForKeyPath:(NSString*)keyPath defaultValue:(NSArray*)defaultValue;

/**
 Returns a `NSDictionary` of the object at the `keypath`.  If the object is a NSDictionary then it is returned as is.  If it is not a NSDictionary then the object is wrapped in an dictionary with the key 'default'.  If the `keypath` doesn't exist then the default value is returned.
 */
- (NSDictionary*)conformedDictionaryForKeyPath:(NSString*)keyPath defaultValue:(NSDictionary*)defaultValue;

/**
 Returns the dictionary as an URL-encoded HTTP query string
 */
- (NSString*)queryString;

/**
 Returns a  given inputArray as a dictionary of arrays split by critera defined in sortBlock. Used for grouping by month or other section interval.
 */
+ (NSDictionary*)sectionDictionaryFromArray:(NSArray*)inputArray withSectionKeyBlock:(SDSectionKeyBlock)keyBlock;

/**
 Merges multiple dictionaries into a single dictionary.  If the dictionaries contain duplicate keys,
 the latter dictionary values will overwrite the former values.
 */
+ (NSDictionary *)mergeDictionaries:(NSArray *)dictionaries;


@end
