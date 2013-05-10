//
//  YPSnippet.m
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import "YPSnippet.h"
#import "YPWord.h"
#import "insist.h"

@implementation YPSnippet


-(id)initWithMaxLength:(NSUInteger)aMaxLength
{
  if ((self = [super init]))
  {
    words = [[NSMutableArray alloc] init];
    maxLength = aMaxLength;
    numMatches = 0;
    length = 0;
  }
  return self;
}

/*
  append a token onto the snippet. if the token makes the snippet too long, and if "slide" is YES, then discard words from
  the start of the snippet.
 
  return YES on success. NO means a pathologically long token in the slide case or that we can't grow the snippet anymore
  in the non slide case
*/

-(BOOL)appendToken:(NSString*)token slide:(BOOL)slide scanLocation:(NSUInteger)scanLocation matchStrings:(NSArray*)matchStrings ignoreCase:(BOOL)ignoreCase
{
  YPWord*word = [[YPWord alloc] initWithToken:token scanLocation:scanLocation matchStrings:matchStrings ignoreCase:ignoreCase];
  insist (word);
  insist (words);
  
  /*discard words from the start to make room, if we have to. the "1" is for the space we need between each word.*/
  while (slide && words.count && length + 1 + word.length > maxLength)
  {
    /*remove the first word and subtract its length*/
    YPWord*w = [words objectAtIndex:0];
    [words removeObjectAtIndex:0];
    
    insist (length >= w.length);
    length -= w.length;
    
    if (w.isMatch)
      numMatches--;
    insist (numMatches >= 0);
    
    /*the space*/
    if (words.count > 1)
    {
      insist (length);
      length --;
    }
  }
  
  /*if we can't make room, nothing we can do*/
  NSUInteger newLength = length + (words.count ? 1 : 0) + word.length;
  if (newLength > maxLength)
  {
    insist (words.count == 0 || !slide);
    return NO;
  }
  
  /*add the new word to the end of the snippet*/
  [words addObject:word];
  if (word.isMatch)
    numMatches++;
  length = newLength;
  return YES;
}

-(void)clear
{
  length = 0;
  numMatches = 0;
  [words removeAllObjects];
}

/*return a nice string for the snippet, this includes any of the markup*/
-(NSString*)stringValue
{
  NSMutableString*s = [[NSMutableString alloc] init];
  insist (s);
  
  for (YPWord*word in words)
  {
    /*separate the words with a single whitespace. whitespace information from the original document has already been discarded*/
    if (s.length)
      [s appendString:@" "];
    
    [s appendString:[word stringValue]];
  }
  
  /*CodeTest.pdf wants strings containing successive matches to be in one set of tags, so collapse in-between tags w/ a simple text replace*/

  return [s stringByReplacingOccurrencesOfString:
          [NSString stringWithFormat:@"%@ %@",YPWord.endHighlightString,YPWord.startHighlightString] withString:@" "];
}

/*return the scanlocation for the start of the snippet in the original document*/
-(NSUInteger)scanLocation
{
  if (words.count == 0)
    return 0;
  
  YPWord*word = [words objectAtIndex:0];
  return word.scanLocation;
}

/*this defines how "good" a snippet is. we just use how many matches there are. if we cared about getting as many of the search string words
 in a row as possible, here's where we'd insert that logic*/
-(unsigned)matchMetric
{
  return numMatches;
}
-(NSUInteger)length
{
  return length;
}

@end
