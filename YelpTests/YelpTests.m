//
//  YelpTests.m
//  YelpTests
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import "YelpTests.h"
#import "YPWord.h"

@implementation YelpTests

static NSArray*matchStrings;
static NSString*document = @"Finally got to try this great place! They have something for everyone, including people like my hub who isn't a fan of deep dish pizza.";

- (void)setUp
{
  [super setUp];
  YPWord.startHighlightString = @"[[HIGHLIGHT]]";
  YPWord.endHighlightString = @"[[ENDHIGHLIGHT]]";
  
  matchStrings = @[@"deep", @"dish", @"pizza"];
  
}

- (void)tearDown
{
  // Tear-down code here.
  
  [super tearDown];
}

- (void)testWordMatch
{
  YPWord*word = [[YPWord alloc] initWithToken:@"pizza" scanLocation:0 matchStrings:matchStrings ignoreCase:YES];
  STAssertTrue(word.isMatch, @"YPWord with token pizza matches search string deep dish pizza");
}

- (void)testWordNoMatch
{
  YPWord*word = [[YPWord alloc] initWithToken:@"egret" scanLocation:0 matchStrings:matchStrings ignoreCase:YES];
  STAssertTrue(!word.isMatch, @"YPWord with token pizza matches search string deep dish pizza");
}

@end
