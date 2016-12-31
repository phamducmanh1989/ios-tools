//
//  GenerateModelTests.m
//  GenerateModelTests
//
//  Created by Manh Pham on 12/31/16.
//  Copyright © 2016 Manh Pham. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+MP.h"
@interface GenerateModelTests : XCTestCase

@end

@implementation GenerateModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateModel {
    
    NSString *__input = @"{\
        \"pi\": 3.141,\
        \"happy\": true,\
        \"name\": \"Niels\",\
        \"nothing\": null,\
        \"answer\": {\
            \"everything\": 42\
        },\
        \"list\": [1, 0, 2],\
        \"object\": {\
            \"currency\": \"USD\",\
            \"value\": 42.99\
        }\
    }";

    NSString *__output = [__input generateModel];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
