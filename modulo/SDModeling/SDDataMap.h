//
//  SDDataMap.h
//  SDDataMapDemo
//
//  Created by Brandon Sneed on 11/14/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Objects that support this protocol may be used to generate sub-objects, such as
 dictionaries and arrays being mapped into objects of specific types.
 */
@protocol SDDataMapProtocol <NSObject>
@optional

/**
 Subclasses can implement this class method as an alternative means by which to input data into
 the resulting object.  This bypasses the mapp all together.  If both this class method and
 mappingDictionaryForData: are implemented, an exception is thrown by SDDataMap.
 */
+ (id)createWithData:(id)data;

/**
 Provides a mapping dictionary based on the input data in the form of "srcKey":"destKey".
 Caller can optionally pass nil which should return a default map.
 */
- (NSDictionary *)mappingDictionaryForData:(id)data;

/**
 Provides an export mapping dictionary based on the object itself that determines how the data within
 should be exported. A dictionary in the form of "srcKey":"destKey" should be returned.
 */
- (NSDictionary *)exportMappingDictionary;

/**
 Allows the model to specify an initial keypath by which to start mapping within the object.
 */
- (NSString *)initialKeyPath;

/**
 Allows the model to be validated against some known values.
 */
- (BOOL)validModel;

/**
* Called after the model was successfully loaded
*/
- (void)modelDidLoad;

@end

/**
 Macros to make defined maps work better with Xcode's refactor tools.
 */

/**
 sddm_key performs class inspection on 'object' to generate the proper string format for a given property via class inspection.
 
 ie: NSArray<MyObject> *myProp via sddm_key(self, self.myProp) would become @"(NSArray<MyObject>)myProp"
 */
#define sddm_key(object, property) \
    _sddm_key(object, variable_name(property))


/**
 sddm_selector validates a selector against 'object' and converts it to the string format used by SDDataMap.
 
 ie: sddm_selector(self, @selector(setSomething:)) becomes @"@selector(setSomething:)"
 */
#define sddm_selector(object, selector) \
    _sddm_selector(object, selector)

// do not call these directly.
NSString *_sddm_key(id object, NSString *propertyName);
NSString *_sddm_selector(id object, SEL selector);


/**
 SDDataMap provides a mechanism by which to assign keypaths from one object to another.
 A plist can be specified by name to provide definitions, optionally a dictionary can be used.
 A sample plist is available as a private gist at: https://gist.github.com/bsneed/f32db309d2ed70902702
 
 ### SDDataMap Property List Format Specification ###
 
 * Keys in the plist/dictionary are processed as being from the source or object to be mapped.
 * Types are always of String.
 * Values are the destination keyPaths on the object being mapped-to.
 
 ### Examples of possible values: ###
 
 * `browseIdentifier`: ie: myObject.browseIdentifier
 * `textLabel.text, name`: This would assign the value to myObject.textLabel.text as well as myObject.name
 * `@selector(testSelector:)`: This would call the selector specified.  This is useful is additional processing
 needs to take place before the assignment.  This could also be accomplished in the above examples by making
 a setter for a given property.
 
 */
@interface SDDataMap : NSObject

/**
 Loads `mapName`.plist as a dictionary to use as a map specification.
 */
+ (SDDataMap *)mapForName:(NSString *)mapName;
/**
 Loads a dictionary for use as a map specification.
 */
+ (SDDataMap *)mapForDictionary:(NSDictionary *)dictionary;

/**
 Returns an SDDataMap with an empty mapping dictionary.  It's assumed that
 the model will supply the map when mapObject* is called.
 */
+ (SDDataMap *)map;

/**
 Maps object1's keypaths to object2 based on the specification that SDDataMap was instantiated with.
 */
- (void)mapObject:(id)object1 toObject:(id)object2 strict:(BOOL)strict;
- (void)mapObject:(id)object1 toObject:(id)object2;
- (void)mapJSON:(id)object1 toObject:(id)object2;

@end

/**
 Helper extensions to allow for more base types to be supported by KVO in a map.
 */

@interface NSString(SDDataMap)

- (NSNumber *)numberValue;
- (char)charValue;
- (short)shortValue;
- (NSDecimal)decimalValue;
- (long)longValue;
- (unsigned char)unsignedCharValue;
- (NSUInteger)unsignedIntegerValue;
- (unsigned int)unsignedIntValue;
- (unsigned long long)unsignedLongLongValue;
- (unsigned long)unsignedLongValue;
- (unsigned short)unsignedShortValue;

@end
