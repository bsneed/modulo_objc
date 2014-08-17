//
//  SDLog.h
//
//  Created by brandon on 2/12/11.
//  Copyright 2011-2014 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

// this turns off logging if DEBUG is not defined in the target
// assuming one is using SDLog everywhere to log to console.

#if defined(DEBUG)
void SDLogRT( NSString* format, ... );
#endif

#ifndef SDLog
#if defined(TESTFLIGHT)
#define SDLog(__FORMAT__, ...) NSLog((@"%s [Line %zd] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#elif defined(DEBUG) && !defined(TESTFLIGHT)
#define SDLog(__FORMAT__, ...) SDLogRT(__FORMAT__, ##__VA_ARGS__)
#define SDTrace(__FORMAT__, ...) SDLogRT((@"Trace: %s [Line %zd] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define SDStack() SDLogRT(@"%@", [NSThread callStackSymbols])
#else
#define SDLog(x...)
#define SDTrace(x...)
#define SDStack()
#endif
#endif

#if defined(DEBUG)
#define SDLogResponse(__FORMAT__, ...) { if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kIncludeResponsesInLogs"]) SDLogRT(__FORMAT__, ##__VA_ARGS__); }
#else
#define SDLogResponse(x...)
#endif
