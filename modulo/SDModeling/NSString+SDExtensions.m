//
//  NSString+SDExtensions.m
//  SetDirection
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import "NSString+SDExtensions.h"
#import "NSData+SDExtensions.h"

GENERICSABLE_IMPLEMENTATION(NSString)

@implementation NSString(SDExtensions)

- (NSString *)replaceHTMLWithUnformattedText {
    return [self replaceHTMLWithUnformattedText:NO];
}

- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets {
    NSString* fixed = [self copy];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

    // kill the HTML entities
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&#[0-9]+;"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@""];
    
    if (keepBullets) {
        error = NULL;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<li>"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        fixed = [regex stringByReplacingMatchesInString:fixed 
                                                options:0 
                                                  range:NSMakeRange(0, [fixed length]) 
                                           withTemplate:@"\n• "];
    }
    
    // kill the HTML tags
    error = NULL;
    
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];

    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];
    
    // a final trimmy trimmy
    fixed = [fixed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return fixed;
}

- (NSString*)stripHTMLFromListItems {
    NSString *fixed = [self copy];

    // some common entities
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

    // replace any HTML tag with a space
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<*[A-Z][A-Z0-9]* ?\\/>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];

    // replace two or more spaces with one
    fixed = [fixed removeExcessWhitespace];
    return fixed;
}


- (NSString*)escapedString 
{            
	NSString *selfCopy = [self mutableCopy];
	return (__bridge_transfer  NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)selfCopy, NULL, CFSTR("%￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
}

- (NSString *)removeExcessWhitespace 
{
    // The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:0 error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@" "];
    return result;
}

- (NSString *)removeLeadingWhitespace 
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s+"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self 
                                           options:0 
                                             range:NSMakeRange(0, [self length]) 
                                      withTemplate:@""];
}

- (NSString *)removeLeadingZeroes
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^0+"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, [self length])
                                      withTemplate:@""];
}

- (NSString *)removeTrailingWhitespace 
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+$"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self 
                                           options:0 
                                             range:NSMakeRange(0, [self length]) 
                                      withTemplate:@""];
}

/**
 Removes all leading and trailing white space characters in the receiver.
 */
- (NSString *)removeLeadingAndTrailingWhitespace
{
    NSString *cleaned = [self removeLeadingWhitespace];
    return [cleaned removeTrailingWhitespace];
}

+ (NSString *)stringWithNewUUID
{
	NSString*	uuidString = nil;
	
	CFUUIDRef	uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	if (uuidRef)
	{
		uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
		
		CFRelease(uuidRef);
	}
	
	return uuidString;
}

- (NSDictionary *)parseURLQueryParams{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; 
        NSString *key = [keyValuePairArray objectAtIndex:0];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        [queryComponents setObject:value forKey:key];
    }
    return queryComponents;
}

+ (NSString *)stringWithJSONObject:(id)obj
{
    NSError *jsonError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&jsonError];
    NSString *theJSONString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return theJSONString;
}

// Method and regex obtained from http://www.cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
- (BOOL)isValidateEmailFormat
{
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

- (NSString *)stringWithNumberFormat:(NSString *)format
{
    if (self.length == 0 || format.length == 0)
        return self;

    format = [format stringByAppendingString:@"#"];
    NSString *string = [self stringByAppendingString:@"0"];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSString *stripped = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, string.length) withTemplate:@""];

    NSMutableArray *patterns = [[NSMutableArray alloc] init];
    NSMutableArray *separators = [[NSMutableArray alloc] init];
    [patterns addObject:@0];

    NSInteger maxLength = 0;
    for (NSInteger i = 0; i < [format length]; i++)
    {
        NSString *character = [format substringWithRange:NSMakeRange((NSUInteger)i, 1)];
        if ([character isEqualToString:@"#"])
        {
            maxLength++;
            NSNumber *number = [patterns objectAtIndex:patterns.count - 1];
            number = @(number.integerValue + 1);
            [patterns replaceObjectAtIndex:patterns.count - 1 withObject:number];
        }
        else
        {
            [patterns addObject:@0];
            [separators addObject:character];
        }
    }

    if (stripped.length > maxLength)
        stripped = [stripped substringToIndex:(NSUInteger)maxLength];

    NSString *match = @"";
    NSString *replace = @"";

    NSMutableArray *expressions = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < patterns.count; i++)
    {
        NSString *currentMatch = [match stringByAppendingString:@"(\\d+)"];
        match = [match stringByAppendingString:[NSString stringWithFormat:@"(\\d{%zd})", ((NSNumber *)[patterns objectAtIndex:i]).integerValue]];

        NSString *template;
        if (i == 0)
            template = [NSString stringWithFormat:@"$%zd", i+1];
        else
            template = [NSString stringWithFormat:@"%@$%zd", [separators objectAtIndex:(NSUInteger)i-1], i+1];

        replace = [replace stringByAppendingString:template];
        [expressions addObject:@{@"match": currentMatch, @"replace": replace}];
    }

    NSString *result = [stripped copy];

    for (NSDictionary *exp in expressions)
    {
        NSString *localMatch = [exp objectForKey:@"match"];
        NSString *localReplace = [exp objectForKey:@"replace"];
        NSString *modifiedString = [stripped stringByReplacingOccurrencesOfString:localMatch withString:localReplace options:NSRegularExpressionSearch range:NSMakeRange(0, stripped.length)];

        if (![modifiedString isEqualToString:stripped])
            result = modifiedString;
    }

    return [result substringWithRange:NSMakeRange(0, result.length - 1)];
}

#if TARGET_OS_IPHONE
/**
 *
 * Returns a UIColor objects for the string's hex representation:
 *
 * For example: [@"#fff" uicolor] returns a UIColor of white.
 *              [@"#118653" uicolor] returns something green.
 *              [@"#1186537F" uicolor] returns something green with a 50% alpha value
 *
 */
- (UIColor *)uicolor
{
    UIColor *color = [UIColor whiteColor];
    NSString *hexString = [self copy];
    
    /* strip out undesired pound character */
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    /* pad the string to 6 characters when coder was lazy and specified something like: #fff */
    if (hexString.length == 3)
    {
        NSString __block *paddedHexString = @"";
        [hexString enumerateSubstringsInRange:NSMakeRange(0, hexString.length)
                                      options:NSStringEnumerationByComposedCharacterSequences
                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                       paddedHexString = [paddedHexString stringByAppendingString:substring];
                                       paddedHexString = [paddedHexString stringByAppendingString:substring];
                                   }];
        hexString = paddedHexString;
    }
    
    /* if we have a 6 character string, try and make a color out of it */
    if (hexString.length == 6)
    {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexString] scanHexInt:&hexValue];
        color = [UIColor colorWithRed:((hexValue >> 16) & 0xFF) / 255.0f
                                green:((hexValue >>  8) & 0xFF) / 255.0f
                                 blue:((hexValue >>  0) & 0xFF) / 255.0f
                                alpha:1.0f];
    }
    
    /* if we have a 8 character string, try and make a color out of it with a suppplied alpha */
    if (hexString.length == 8)
    {
        unsigned int hexValue;
        [[NSScanner scannerWithString:hexString] scanHexInt:&hexValue];
        color = [UIColor colorWithRed:((hexValue >> 24) & 0xFF) / 255.0f
                                green:((hexValue >> 16) & 0xFF) / 255.0f
                                 blue:((hexValue >>  8) & 0xFF) / 255.0f
                                alpha:((hexValue >>  0) & 0xFF) / 255.0f];
    }

    return color;
}
#endif

- (NSArray *)JSONArrayRepresentation
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data JSONArray];
}

- (NSDictionary *)JSONDictionaryRepresentation
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data JSONDictionary];
}

- (NSString *)capitalizedStreetAddressString
{
    NSString* capitalizedString = [self capitalizedString];

    // Handle the simple polar directions.
    capitalizedString = [capitalizedString stringByReplacingOccurrencesOfString:@" Ne " withString:@" NE "];
    capitalizedString = [capitalizedString stringByReplacingOccurrencesOfString:@" Nw " withString:@" NW "];
    capitalizedString = [capitalizedString stringByReplacingOccurrencesOfString:@" Se " withString:@" SE "];
    capitalizedString = [capitalizedString stringByReplacingOccurrencesOfString:@" Sw " withString:@" SW "];

    // Now go and first the appreviations after the street numbers.
    NSError* error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]|[ ])(St|Nd|Rd|Th)([ ])" options:0 error:&error];
    if(error == nil && regex)
    {
        NSMutableString* mutableString = [capitalizedString mutableCopy];
        NSUInteger offset = 0; // Keeps track of range changes in the string
        for(NSTextCheckingResult *result in [regex matchesInString:capitalizedString
                                                           options:0
                                                             range:(NSRange){ 0, capitalizedString.length }])
        {
            NSRange resultRange = [result range];
            resultRange.location += offset; // resultRange.location is updated based on the offset updated below

            // Implement your own replace functionality using replacementStringForResult:inString:offset:template:
            // note that in the template $0 is replaced by the match
            NSString* match = [regex replacementStringForResult:result
                                                       inString:mutableString
                                                         offset:(NSInteger)offset
                                                       template:@"$0"];
            NSString* replacement = [match lowercaseString];

            // make the replacement
            [mutableString replaceCharactersInRange:resultRange withString:replacement];

            // update the offset based on the replacement
            offset += ([replacement length] - resultRange.length);
        }

        capitalizedString = [mutableString copy];
    }

    return capitalizedString;
}

+ (NSString *)pluralizedCount:(NSUInteger)count singleString:(NSString *)singleString pluralString:(NSString *)pluralString
{
    if (count == 1)
        return [NSString stringWithFormat:@"%tu %@", count, singleString];
    return [NSString stringWithFormat:@"%tu %@", count, pluralString];
}

/**
 * Quick validation of US ZIP code.
 */

- (BOOL)isValidZIPCode
{
    return [self isValidWithRegex:@"^\\d{5}([\\-]?\\d{4})?$"];
}

/**
 * Validate a string with a regex. Returns YES if there is a match.
 */

- (BOOL)isValidWithRegex:(NSString*)regexString
{
    BOOL valid = NO;
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionSearch
                                                                             error:&error];

    if(regex && error == nil)
    {
        NSTextCheckingResult* result = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length] )];
        if (result)
        {
            valid = YES;
        }
    }

    return valid;
}

+ (BOOL) isEmpty:(NSString *)string {
    return NO == [self isNotEmpty:string];
}

+ (BOOL) isNotEmpty:(NSString *)string {
    return (string && [string length] > 0);
}

- (NSString*)stringWithPathRelativeTo:(NSString*)anchorPath
{
    NSArray *pathComponents = [self pathComponents];
    NSArray *anchorComponents = [anchorPath pathComponents];
    
    NSUInteger componentsInCommon = MIN([pathComponents count], [anchorComponents count]);
    for (NSUInteger i = 0, n = componentsInCommon; i < n; i++)
    {
        if (![[pathComponents objectAtIndex:i] isEqualToString:[anchorComponents objectAtIndex:i]])
        {
            componentsInCommon = i;
            break;
        }
    }
    
    NSUInteger numberOfParentComponents = [anchorComponents count] - componentsInCommon;
    NSUInteger numberOfPathComponents = [pathComponents count] - componentsInCommon;
    
    NSMutableArray *relativeComponents = [NSMutableArray arrayWithCapacity:numberOfParentComponents + numberOfPathComponents];
    for (NSInteger i = 0; i < numberOfParentComponents; i++)
    {
        [relativeComponents addObject:@".."];
    }
    
    [relativeComponents addObjectsFromArray:[pathComponents subarrayWithRange:NSMakeRange(componentsInCommon, numberOfPathComponents)]];
    NSString *result = [NSString pathWithComponents:relativeComponents];
    
    // remove any leading ./ and trailing /
    NSRange leadingRange = [result rangeOfString:@"./"];
    if (leadingRange.location == 0)
        result = [result stringByReplacingOccurrencesOfString:@"./" withString:@"" options:0 range:leadingRange];

    NSRange trailingRange = [result rangeOfString:@"/"];
    if (trailingRange.location == result.length - 1)
        result = [result stringByReplacingOccurrencesOfString:@"/" withString:@"" options:0 range:trailingRange];

    return result;
}

@end

