//Copyright 2013 Tomer Shiri generics@shiri.info
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.




#define GENERICSABLE(__className) \
	GENERICSABLE_ALL(__className)
#define GENERICSABLE_IMPLEMENTATION(__className) \
	GENERICSABLE_IMPLEMENTATION_ALL(__className)

#pragma mark - Interface

#if NS_BLOCKS_AVAILABLE
	#define GENERICSABLE_ALL(__className) \
        @protocol __className; \
		__GENERICSABLE_WITHOUT_BLOCKS(__className) \
		__GENERICSABLE_WITH_BLOCKS(__className)
#else
	#define GENERICSABLE_ALL(__className) \
        @protocol __className; \
		__GENERICSABLE_WITHOUT_BLOCKS(__className)
#endif



#define __GENERICSABLE_WITHOUT_BLOCKS(__className) \
	@class __className; \
	@class __className##Array; \
	__GENERICSABLE_ENUMERATOR(__className) \
	__GENERICSABLE_ARRAY(__className) \
	__GENERICSABLE_MUTABLE_ARRAY(__className) \
	__GENERICSABLE_DICTIONARY(__className) \
	__GENERICSABLE_MUTABLE_DICTIONARY(__className) \
	__GENERICSABLE_SET(__className) \
	__GENERICSABLE_MUTABLE_SET(__className) \
	__GENERICSABLE_COUNTED_SET(__className)

#define  __GENERICSABLE_WITH_BLOCKS(__className) \
	typedef NSComparisonResult (^__className##Comparator)(__className* obj1, __className* obj2); \
	__GENERICSABLE_ENUMERATOR_BLOCKS(__className) \
	__GENERICSABLE_ARRAY_BLOCKS(__className) \
	__GENERICSABLE_MUTABLE_ARRAY_BLOCKS(__className) \
	__GENERICSABLE_DICTIONARY_BLOCKS(__className) \
	__GENERICSABLE_MUTABLE_DICTIONARY_BLOCKS(__className) \
	__GENERICSABLE_SET_BLOCKS(__className) \
	__GENERICSABLE_MUTABLE_SET_BLOCKS(__className) \
	__GENERICSABLE_COUNTED_SET_BLOCKS(__className) \


// Enumerator
#define __GENERICSABLE_ENUMERATOR(__className) \
	@interface __className##Enumerator : NSEnumerator \
		- (__className*)nextObject;  \
		- (__className##Array*)allObjects; \
	@end \


// Array
#define __GENERICSABLE_ARRAY(__className) \
	@interface __className##Array : NSArray \
		\
		- (__className*)objectAtIndex:(NSUInteger)index; \
		- (__className##Array*)arrayByAddingObject:(__className*)anObject; \
		- (NSArray*)arrayByAddingObjectsFromArray:(__className##Array*)otherArray; \
		- (BOOL)containsObject:(__className*)anObject; \
		- (__className*)firstObjectCommonWithArray:(__className##Array*)otherArray; \
		- (NSUInteger)indexOfObject:(__className*)anObject; \
		- (NSUInteger)indexOfObject:(__className*)anObject inRange:(NSRange)range; \
		- (NSUInteger)indexOfObjectIdenticalTo:(__className*)anObject; \
		- (NSUInteger)indexOfObjectIdenticalTo:(__className*)anObject inRange:(NSRange)range; \
		- (BOOL)isEqualToArray:(__className##Array*)otherArray; \
		- (__className*)lastObject; \
		- (__className##Enumerator*)objectEnumerator; \
		- (__className##Enumerator*)reverseObjectEnumerator; \
		- (__className##Array*)sortedArrayUsingFunction:(NSInteger (*)(__className*, __className*, void *))comparator context:(void *)context; \
		- (__className##Array*)sortedArrayUsingFunction:(NSInteger (*)(__className*, __className*, void *))comparator context:(void *)context hint:(NSData *)hint; \
		- (__className##Array*)sortedArrayUsingSelector:(SEL)comparator; \
		- (__className##Array*)subarrayWithRange:(NSRange)range; \
		- (__className##Array*)objectsAtIndexes:(NSIndexSet *)indexes; \
		- (__className*)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0); \
		\
		+ (__className##Array*)array; \
		+ (__className##Array*)arrayWithObject:(__className*)anObject; \
		+ (__className##Array*)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		+ (__className##Array*)arrayWithObjects:(__className*)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		+ (__className##Array*)arrayWithArray:(__className##Array*)array; \
		\
		- (__className##Array*)initWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		- (__className##Array*)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		- (__className##Array*)initWithArray:(NSArray *)array; \
		- (__className##Array*)initWithArray:(NSArray *)array copyItems:(BOOL)flag; \
		\
		+ (__className##Array*)arrayWithContentsOfFile:(NSString *)path; \
		+ (__className##Array*)arrayWithContentsOfURL:(NSURL *)url; \
		- (__className##Array*)initWithContentsOfFile:(NSString *)path; \
		- (__className##Array*)initWithContentsOfURL:(NSURL *)url; \
		\
	@end \


// MutableArray
#define __GENERICSABLE_MUTABLE_ARRAY(__className) \
	@interface __className##MutableArray : NSMutableArray \
		\
		- (void)addObjectsFromArray:(__className##Array*)otherArray; \
		- (void)removeObject:(__className*)anObject inRange:(NSRange)range; \
		- (void)removeObject:(__className*)anObject; \
		- (void)removeObjectIdenticalTo:(__className*)anObject inRange:(NSRange)range; \
		- (void)removeObjectIdenticalTo:(__className*)anObject; \
		- (void)removeObjectsInArray:(__className##Array*)otherArray; \
		\
		- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(__className##Array*)otherArray range:(NSRange)otherRange; \
		- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(__className##Array*)otherArray; \
		- (void)setArray:(__className##Array*)otherArray; \
		- (void)sortUsingFunction:(NSInteger (*)(__className*, __className*, void *))compare context:(void *)context; \
		\
		- (void)insertObjects:(__className##Array*)objects atIndexes:(NSIndexSet *)indexes; \
		- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes; \
		- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(__className##Array*)objects; \
		\
		- (void)setObject:(__className*)obj atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0); \
		\
		+ (__className##MutableArray*)array; \
		+ (__className##MutableArray*)arrayWithObject:(__className*)anObject; \
		+ (__className##MutableArray*)arrayWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		+ (__className##MutableArray*)arrayWithObjects:(__className*)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		+ (__className##MutableArray*)arrayWithArray:(__className##Array*)array; \
		\
		- (__className##MutableArray*)initWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		- (__className##MutableArray*)initWithObjects:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		- (__className##MutableArray*)initWithArray:(NSArray *)array; \
		- (__className##MutableArray*)initWithArray:(NSArray *)array copyItems:(BOOL)flag; \
		\
		+ (__className##MutableArray*)arrayWithContentsOfFile:(NSString *)path; \
		+ (__className##MutableArray*)arrayWithContentsOfURL:(NSURL *)url; \
		- (__className##MutableArray*)initWithContentsOfFile:(NSString *)path; \
		- (__className##MutableArray*)initWithContentsOfURL:(NSURL *)url; \
		\
	@end \


// Dictionary
#define __GENERICSABLE_DICTIONARY(__className) \
	@interface __className##Dictionary : NSDictionary \
		\
		- (NSArray *)allKeysForObject:(__className*)anObject; \
		- (__className##Array*)allValues; \
		- (__className##Enumerator *)objectEnumerator; \
		- (__className##Array *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker; \
		- (__className*)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0); \
		\
		\
		+ (__className##Dictionary *)dictionary; \
		+ (__className##Dictionary *)dictionaryWithObject:(id)object forKey:(id <NSCopying>)key; \
		+ (__className##Dictionary *)dictionaryWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt; \
		+ (__className##Dictionary *)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION; \
		+ (__className##Dictionary *)dictionaryWithDictionary:(__className##Dictionary *)dict; \
		+ (__className##Dictionary *)dictionaryWithObjects:(__className##Array *)objects forKeys:(NSArray *)keys; \
		 \
		- (__className##Dictionary *)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt; \
		- (__className##Dictionary *)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION; \
		- (__className##Dictionary *)initWithDictionary:(__className##Dictionary *)otherDictionary; \
		- (__className##Dictionary *)initWithDictionary:(__className##Dictionary *)otherDictionary copyItems:(BOOL)flag; \
		- (__className##Dictionary *)initWithObjects:(__className##Array *)objects forKeys:(NSArray *)keys; \
		 \
		+ (__className##Dictionary *)dictionaryWithContentsOfFile:(NSString *)path; \
		+ (__className##Dictionary *)dictionaryWithContentsOfURL:(NSURL *)url; \
		- (__className##Dictionary *)initWithContentsOfFile:(NSString *)path; \
		- (__className##Dictionary *)initWithContentsOfURL:(NSURL *)url; \
		\
	@end \


// MutableDictionary
#define __GENERICSABLE_MUTABLE_DICTIONARY(__className) \
	@interface __className##MutableDictionary : NSMutableDictionary \
		\
		- (void)removeObjectForKey:(id)aKey; \
		- (void)setObject:(__className *)anObject forKey:(id <NSCopying>)aKey; \
		\
		- (void)addEntriesFromDictionary:(__className##Dictionary *)otherDictionary; \
		- (void)removeAllObjects; \
		- (void)removeObjectsForKeys:(NSArray *)keyArray; \
		- (void)setDictionary:(__className##Dictionary *)otherDictionary; \
		- (void)setObject:(__className *)obj forKeyedSubscript:(id <NSCopying>)key NS_AVAILABLE(10_8, 6_0); \
		\
		+ (__className##MutableDictionary*)dictionaryWithCapacity:(NSUInteger)numItems; \
		- (__className##MutableDictionary*)initWithCapacity:(NSUInteger)numItems; \
		\
	@end \


// Set
#define __GENERICSABLE_SET(__className) \
	@interface __className##Set : NSSet \
		\
		- (__className*)member:(__className*)object; \
		- (__className##Enumerator*)objectEnumerator; \
		\
		- (__className##Array*)allObjects; \
		- (__className*)anyObject; \
		- (BOOL)containsObject:(__className*)anObject; \
		- (BOOL)intersectsSet:(__className##Set*)otherSet; \
		- (BOOL)isEqualToSet:(__className##Set*)otherSet; \
		- (BOOL)isSubsetOfSet:(__className##Set*)otherSet; \
		\
		- (__className##Set*)setByAddingObject:(__className*)anObject NS_AVAILABLE(10_5, 2_0); \
		- (__className##Set*)setByAddingObjectsFromSet:(__className##Set*)other NS_AVAILABLE(10_5, 2_0); \
		- (__className##Set*)setByAddingObjectsFromArray:(NSArray *)other NS_AVAILABLE(10_5, 2_0); \
		\
		+ (__className##Set*)set; \
		+ (__className##Set*)setWithObject:(__className*)object; \
		+ (__className##Set*)setWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		+ (__className##Set*)setWithObjects:(__className*)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		+ (__className##Set*)setWithSet:(__className##Set*)set; \
		+ (__className##Set*)setWithArray:(__className##Array*)array; \
		\
		- (__className##Set*)initWithObjects:(const id [])objects count:(NSUInteger)cnt; \
		- (__className##Set*)initWithObjects:(__className*)firstObj, ... NS_REQUIRES_NIL_TERMINATION; \
		- (__className##Set*)initWithSet:(__className##Set*)set; \
		- (__className##Set*)initWithSet:(__className##Set*)set copyItems:(BOOL)flag; \
		- (__className##Set*)initWithArray:(__className##Array*)array; \
		\
	@end \


// MutableSet
#define __GENERICSABLE_MUTABLE_SET(__className) \
	@interface __className##MutableSet : NSMutableSet \
		\
		- (void)addObject:(__className*)object; \
		- (void)removeObject:(__className*)object; \
		- (void)addObjectsFromArray:(__className##Array*)array; \
		- (void)intersectSet:(__className##Set*)otherSet; \
		- (void)minusSet:(__className##Set*)otherSet; \
		- (void)unionSet:(__className##Set*)otherSet; \
		\
		- (void)setSet:(__className##Set*)otherSet; \
		+ (__className##MutableSet*)setWithCapacity:(NSUInteger)numItems; \
		- (__className##MutableSet*)initWithCapacity:(NSUInteger)numItems; \
		\
	@end \


// CountedSet
#define __GENERICSABLE_COUNTED_SET(__className) \
	@interface __className##CountedSet : NSCountedSet \
		\
		- (__className##CountedSet*)initWithCapacity:(NSUInteger)numItems;  \
		- (__className##CountedSet*)initWithArray:(__className##Array*)array; \
		- (__className##CountedSet*)initWithSet:(__className##Set*)set; \
		- (NSUInteger)countForObject:(__className*)object; \
		- (__className##Enumerator*)objectEnumerator; \
		- (void)addObject:(__className*)object; \
		- (void)removeObject:(__className*)object; \
		\
	@end \

#if NS_BLOCKS_AVAILABLE

	// MutableArray Blocks
	#define __GENERICSABLE_MUTABLE_ARRAY_BLOCKS(__className) \
		@interface __className##MutableArray (__className##_NSMutableArray_BLOCKS_Generics) \
			- (void)sortUsingComparator:(__className##Comparator)cmptr NS_AVAILABLE(10_6, 4_0); \
			- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(__className##Comparator)cmptr NS_AVAILABLE(10_6, 4_0); \
		@end


	// Dictionary Blocks
	#define __GENERICSABLE_DICTIONARY_BLOCKS(__className) \
		@interface __className##Dictionary (__className##_NSDictionary_BLOCKS_Generics) \
			- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, __className * obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0); \
			- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, __className * obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0); \
			 \
			- (NSArray *)keysSortedByValueUsingComparator:(__className##Comparator)cmptr NS_AVAILABLE(10_6, 4_0); \
			- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(__className##Comparator)cmptr NS_AVAILABLE(10_6, 4_0); \
			 \
			- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, __className* obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0); \
			- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, __className* obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0); \
		@end


	// Set Blocks
	#define __GENERICSABLE_SET_BLOCKS(__className) \
		@interface __className##Set (__className##_NSSet_BLOCKS_Generics) \
			- (void)enumerateObjectsUsingBlock:(void (^)(__className* obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0); \
			- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(__className* obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0); \
			- (__className##Set*)objectsPassingTest:(BOOL (^)(__className* obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0); \
			- (__className##Set*)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(__className* obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0); \
		@end \

	#define __GENERICSABLE_ENUMERATOR_BLOCKS(__className)
	#define __GENERICSABLE_ARRAY_BLOCKS(__className)
	#define __GENERICSABLE_MUTABLE_DICTIONARY_BLOCKS(__className)
	#define __GENERICSABLE_MUTABLE_SET_BLOCKS(__className)
	#define __GENERICSABLE_COUNTED_SET_BLOCKS(__className)

#endif


#pragma mark Implementation

#define __GENERICSABLE_IMPLEMENTATION_CLASS__(__className) \
	_Pragma("clang diagnostic push") \
	_Pragma("clang diagnostic ignored \"-Wincomplete-implementation\"") \
		@implementation __className \
		@end \
	_Pragma("clang diagnostic pop") \


#define GENERICSABLE_IMPLEMENTATION_ALL(__className) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##Array) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##MutableArray) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##Dictionary) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##MutableDictionary) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##Set) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##MutableSet) \
	__GENERICSABLE_IMPLEMENTATION_CLASS__(__className##CountedSet)

