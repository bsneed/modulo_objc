//
//  NSString+SDExtensions.h
//  SetDirection
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveCGenerics.h"

GENERICSABLE(NSString)

@interface NSString(SDExtensions)

/**
 A convenience method to create a UUID of type NSString using CFUUID* functions.
 */
+ (NSString *)stringWithNewUUID;

/**
 A convenience method to create a JSON string from a given object.
 */
+ (NSString *)stringWithJSONObject:(id)obj;

/**
 A method to replace HTML in multi-line strings with an adequate plain-text alternative, using Unicode characters where appropriate to replace.
 @param keepBullets If `YES` then convert HTML list items tags into `•`, rather than discarding them.
 */
- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets;

/**
 A method to replace HTML in multi-line strings with an adequate plain-text alternative, using Unicode characters where appropriate to replace.
 */
- (NSString *)replaceHTMLWithUnformattedText;

/**
 A method to replace HTML in single-line strings designed for compact representation (e.g., items in a list)
 This is similar in behavior to replaceHTMLWithUnformattedText except it makes no attempt to format text for attractive multi-line display.
 */
- (NSString *)stripHTMLFromListItems;

/**
 Replace the characters in the set `￼=,!$&'()*+;@?\n\"<>#\t :/` with percent escapes for the string in the receiver.
 */
- (NSString *)escapedString;

/**
 Replaces all ocurrences of multiple white space characters in the receiver with a single space character.
 */
- (NSString *)removeExcessWhitespace;

/**
 Replaces all leading white space characters in the receiver with a single space character.
 */
- (NSString *)removeLeadingWhitespace;

/**
 Removes all trailing white space characters in the receiver.
 */
- (NSString *)removeTrailingWhitespace;

/**
 Removes all leading and trailing white space characters in the receiver.
 */
- (NSString *)removeLeadingAndTrailingWhitespace;

/**
 Removes all leading zeroes in the receiver.
 */
- (NSString *)removeLeadingZeroes;

/**
 Returns a dictionary created from all key-value pairs in the receiver assuming it is formatted as URL query parameters.
 */
- (NSDictionary *)parseURLQueryParams;

/**
 Returns true if the receiver matches an email address as defined by the regex at http://www.cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
 */
- (BOOL)isValidateEmailFormat;

/**
 Returns the string formatted with the given number format.
 
 ie: ##/##/#### would return 08/25/1977 for example.
 */
- (NSString *)stringWithNumberFormat:(NSString *)format;

#if TARGET_OS_IPHONE
/**
 *
 * Returns a UIColor objects for the string's hex representation:
 *
 * For example: [@"#fff" uicolor] returns a UIColor of white.
 *              [@"#118653" uicolor] returns something green.
 *
 */
- (UIColor *)uicolor;
#endif

/**
 *  Returns an NSArray of the JSON data in the string, or nil if the string is not a JSON array
 *
 *  @return NSArray of JSON data in this string
 */
- (NSArray *)JSONArrayRepresentation;

/**
 *  Returns an NSDictionary of the JSON data in the string, or nil if the string is not a JSON dictionary
 *
 *  @return NSDictionary of JSON data in this string
 */
- (NSDictionary *)JSONDictionaryRepresentation;

/**
 *  Returns a string capitalized while preserving polar directions as well as numeric position abbreviations.
 *  For example, capitalizeString would change: 1234 NE 11TH STREET to 1234 Ne 11Th Street. We want: 1234 NE 11th Street
 *
 */
- (NSString *)capitalizedStreetAddressString;

/**
 Pluralizes a string with a count.  ie: "0 items", "1 item", "2 items"
 */
+ (NSString *)pluralizedCount:(NSUInteger)count singleString:(NSString *)singleString pluralString:(NSString *)pluralString;

/**
 * Quick validation of US ZIP code.
 */

- (BOOL)isValidZIPCode;

/**
 * Validate a string with a regex. Returns YES if there is a match.
 */

- (BOOL)isValidWithRegex:(NSString*)regexString;

/** A convenience test that checks for both nil and zero length of the supplied string. */
+ (BOOL) isEmpty:(NSString *)string;

/** Returns the inverse of #isEmpty:. */
+ (BOOL) isNotEmpty:(NSString *)string;

- (NSString*)stringWithPathRelativeTo:(NSString*)anchorPath;

@end
