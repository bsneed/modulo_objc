//
//  SDModelObject.h
//  ios-shared
//
//  Created by Brandon Sneed on 10/15/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDataMap.h"

/**
 sdmo_key performs class inspection to generate the proper string format for a given property via class inspection.
 
 ie: NSArray<MyObject> *myProp via sdmo_key(self.myProp) would become @"(NSArray<MyObject>)myProp"
 
 Note: A reference to 'self' is implicit.
 */
#define sdmo_key(property) \
    _sddm_key(self, variable_name(property))

/**
 sdmo_selector validates a selector against an object and converts it to the string format used by SDDataMap.
 
 ie: sdmo_selector(@selector(setSomething:)) becomes @"@selector(setSomething:)"
 
 Note: A reference to 'self' is implicit. 
 */
#define sdmo_selector(selector) \
    _sddm_selector(self, selector)

/**
 *  SDModelObject is a base modeling class which ideally works in conjunction with SDDataMap.
 *  
 *  SDModelObject's mapFromObject will generate a new instance of this class/subclass and then
 *  make a call to mappingDictionaryForData in order to retrieve a map for use with SDDataMap
 *  and then map the sourceObject to the newly created instance.
 */
@interface SDModelObject : NSObject<SDDataMapProtocol>

/**
 *	Subclasses should override this method to provide a data map dictionary per the specifications
 *  for SDDataMap.  The map should be in the format of @{@"sourceKey": @"destKey"}.  The destination
 *  will always be the subclass of SDModelObject.
 *
 *	@return	A dictionary containing the data mapping dictionary.
 */
//- (NSDictionary *)mappingDictionaryForData:(id)data;

/**
 *  The dictionary representation is an NSDictionary filled with the SDDataMap name values based on
 *  - mappingDictionaryForData:
 *
 *  @return A dictionary representing this object
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 *  JSON Representation of this request.
 *
 *  @return a NSData containing the internal dataDictionary as JSON
 */
- (NSData *)JSONRepresentation;

/**
 *  JSON Representation of this request, converted to a string.
 *
 *  @return a NSString of the internal dataDictionary as a UTF8 - JSON string
 */
- (NSString *)JSONStringRepresentation;

/**
 *  Utility creation method that maps a source object's name value pairs to the new object
 *
 *  @param sourceObject The source name / value pairs
 *
 *  @return A newly created and mapped object or nil if the model was not valid.  See -isValidModel.
 */
+ (instancetype)mapFromObject:(id)sourceObject;

- (NSString *)modelDescription;

@end


@interface SDErrorModelObject : SDModelObject

/**
 *  Subclasses MUST override this method to do valid error model checking.
 *
 *  @return YES if the model is valid.  No if the model is not valid.
 */
- (BOOL)validModel;

@end
