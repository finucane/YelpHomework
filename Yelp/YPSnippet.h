//
//  YPSnippet.h
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPSnippet : NSObject
{
  @private
  NSMutableArray*words;
  NSUInteger maxLength;
  NSUInteger length;
  unsigned numMatches;
}


-(id)initWithMaxLength:(NSUInteger)maxLength;
-(BOOL)appendToken:(NSString*)token slide:(BOOL)slide scanLocation:(NSUInteger)scanLocation matchStrings:(NSArray*)matchStrings ignoreCase:(BOOL)ignoreCase;
-(void)clear;
-(NSString*)stringValue;
-(NSUInteger)scanLocation;
-(unsigned)matchMetric;
-(NSUInteger)length;

@end
