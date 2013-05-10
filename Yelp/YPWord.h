//
//  YPWord.h
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPWord : NSObject
{
  @private
  NSString*word;
  NSString*prettyWord;
  NSUInteger scanLocation;
}

-(id)initWithToken:(NSString*)token scanLocation:(NSUInteger)scanLocation matchStrings:(NSArray*)matchStrings ignoreCase:(BOOL)ignoreCase;
-(NSUInteger)length;
-(NSUInteger)scanLocation;
-(NSString*)stringValue;
-(BOOL)isMatch;
+(void)setStartHighlightString:(NSString*)s;
+(void)setEndHighlightString:(NSString*)s;
+(NSString*)startHighlightString;
+(NSString*)endHighlightString;

@end
