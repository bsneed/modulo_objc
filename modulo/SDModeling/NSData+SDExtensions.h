//
//  NSData+SDExtensions.h
//  ios-shared
//
//  Created by Brandon Sneed on 4/10/13.
//  Copyright (c) 2013 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SDExtensions)

- (id)JSONObjectMutable:(BOOL)shouldBeMutable error:(NSError **)error;

- (id)JSONObject;
- (NSArray *)JSONArray;
- (NSMutableArray *)JSONMutableArray;
- (NSDictionary *)JSONDictionary;
- (NSMutableDictionary *)JSONMutableDictionary;

- (NSString *)stringRepresentation;

@end
