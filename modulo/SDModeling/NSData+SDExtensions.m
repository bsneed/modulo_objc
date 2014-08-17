//
//  NSData+SDExtensions.m
//  ios-shared
//
//  Created by Brandon Sneed on 4/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import "NSData+SDExtensions.h"
#import "SDLog.h"

@implementation NSData (SDExtensions)

- (id)JSONObjectMutable:(BOOL)shouldBeMutable error:(NSError **)error
{
    NSJSONReadingOptions options = shouldBeMutable ? (NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves): 0;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:self options:options error:error];
    if (!jsonObject || (error && *error))
    {
        if (error)
            SDLog(@"Error parsing JSONData: %@", [*error debugDescription]);
        
        // AH HELLS MAN WHY DO WE LET MERCHANTS CREATE INVALID JSON!
        // We'll fix this because we're bad ass iOS Engineering y0
        
        // This corrects an issue where invalid UTF8 chars sometimes come through in JSON and
        // prevent proper parsing.  ie: non-breaking space char A0 in HTML.
        NSString *responseString = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
        if (!responseString)
        {
            SDLog(@"Wow can you believe it, this JSON did not even parse as ASCII!");
        }
        else
        {
            NSData *fixedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            jsonObject = [NSJSONSerialization JSONObjectWithData:fixedData options:options error:error];
        }
    }
    
    return jsonObject;

}

- (id)JSONObject
{
    id object = [self JSONObjectMutable:NO error:nil];
    return object;
}

- (NSArray *)JSONArray
{
    id arrayObject = [self JSONObject];
    if ([arrayObject isKindOfClass:[NSArray class]])
        return arrayObject;
    
    return nil;
}

- (NSMutableArray *)JSONMutableArray
{
    id arrayObject = [self JSONObjectMutable:YES error:nil];
    if ([arrayObject isKindOfClass:[NSMutableArray class]])
        return arrayObject;

    return nil;
}

- (NSDictionary *)JSONDictionary
{
    id arrayObject = [self JSONObject];
    if ([arrayObject isKindOfClass:[NSDictionary class]])
        return arrayObject;

    return nil;
}

- (NSMutableDictionary *)JSONMutableDictionary
{
    id arrayObject = [self JSONObjectMutable:YES error:nil];
    if ([arrayObject isKindOfClass:[NSMutableDictionary class]])
        return arrayObject;

    return nil;
}

- (NSString *)stringRepresentation
{
    NSString *result = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (!result)
        result = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
    return result;
}

@end
