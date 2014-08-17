//
//  SDLog.m
//
//  Created by Steven Woolgar on 02/06/2014.
//  Copyright 2014 SetDirection. All rights reserved.
//

#import "SDLog.h"

#ifdef DEBUG

void SDLogRT( NSString* format, ... )
{
    static BOOL sInterceptLogging = NO;

    // Only check the environment variables once.
	static dispatch_once_t sDispatchOnce;
    dispatch_once(&sDispatchOnce, ^
    {
        NSDictionary* environmentDictionary = [[NSProcessInfo processInfo] environment];
        BOOL isUnitTesting = [environmentDictionary[@"isUnitTesting"] boolValue];
        if(isUnitTesting)
            sInterceptLogging = YES;
	});

    if(sInterceptLogging == NO)
    {
        va_list args;
        va_start( args, format );
        NSLogv( format, args );
        va_end( args );
    }
}

#endif
