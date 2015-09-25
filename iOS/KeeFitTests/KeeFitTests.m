//
//  KeeFitTests.m
//  KeeFitTests
//
//  Created by lichen on 5/16/14.
//  Copyright (c) 2014 codoon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DeviceSportSleep.h"

@interface KeeFitTests : XCTestCase

@end

@implementation KeeFitTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testStoreAndGet
{
    Byte startByte[] = {0xAA, 0xBB};
    int nLength = sizeof(startByte);
    XCTAssertEqual(nLength, 2, @"长度就为2");
    
    Byte startByte1[] = {};
    nLength = sizeof(startByte1);
    XCTAssertEqual(nLength, 0, @"长度就为0");
}

- (void)testCombine
{
    NSData *command = [DeviceSportSleep combineCommand:0x0c andData:nil];
    
    Byte commandBytes[] = {0xaa,0x0c,0x00,0xb6};
    NSData *commandData = [NSData dataWithBytes: commandBytes length:4];
    XCTAssertTrue([command isEqualToData:commandData], @"相等");
}

@end
