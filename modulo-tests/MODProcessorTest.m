//
//  MODProcessorTest.m
//  modulo
//
//  Created by Sam Grover on 11/17/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MODProcessor.h"

@interface MODProcessorTest : XCTestCase

@property (nonatomic, strong) MODProcessor* processor;

@end

@implementation MODProcessorTest

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.processor = [MODProcessor processor];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [super tearDown];
}

- (void)testExample
{
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
