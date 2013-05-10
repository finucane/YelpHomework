//
//  YPWord.m
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import "YPWord.h"
#import "insist.h"

static NSString*kStartHighlight;
static NSString*kEndHighlight;

@implementation YPWord

+(void)setStartHighlightString:(NSString*)s
{
  kStartHighlight = s;
}
+(void)setEndHighlightString:(NSString*)s
{
  kEndHighlight = s;
}
+(NSString*)startHighlightString
{
  return kStartHighlight;
}
+(NSString*)endHighlightString
{
  return kEndHighlight;
}

/*
 split a string up into an array of strings, where each string is either a punctuation character, or a string that has no punctuation in it.
 */

-(NSArray*)chopPunctuation:(NSString*)string
{
  insist (string);
  
  NSMutableArray*components = [[NSMutableArray alloc] init];
  NSScanner*scanner = [[NSScanner alloc] initWithString:string];
  
  while (![scanner isAtEnd])
  {
    NSString*s;
    if ([scanner scanUpToCharactersFromSet:[NSCharacterSet punctuationCharacterSet] intoString:&s])
      [components addObject:s];
    if ([scanner scanUpToCharactersFromSet:[[NSCharacterSet punctuationCharacterSet]invertedSet] intoString:&s])
      [components addObject:s];
  }
  //NSLog (@"%@", components);
  return components;
}

/*return a string marked up with the highlighting tags, if necessary. here is where we deal with the tricky problem of punctuation once and for all.*/
-(NSString*)stringByMarkingString:(NSString*)string matchStrings:(NSArray*)matchStrings ignoreCase:(BOOL)ignoreCase;
{
  insist (self && string);
  insist (string.length);
  insist (kStartHighlight.length && kEndHighlight.length);
  
  NSMutableString*s = [[NSMutableString alloc] init];
  
  /*chop the word up into substrings separated by punctuation*/
  NSArray*components = [self chopPunctuation:string];
  insist (components && components.count);
  
  NSStringCompareOptions options = ignoreCase ? NSCaseInsensitiveSearch : 0;
  
  /*build a string that has the highlight tags around any substrings that are matches*/
  for (NSString*wordString in components)
  {
    BOOL matched = NO;
    for (NSString*matchString in matchStrings)
    {
      if ([matchString compare:wordString options:options] == NSOrderedSame)
      {
        matched = YES;
        break;
      }
    }
    if (matched)
      [s appendFormat:@"%@%@%@", kStartHighlight, wordString, kEndHighlight];
    else
      [s appendString:wordString];
  }
  return s;
}


/*
 make a word from a token and a list of match words. words can have punctuation in them which is ignored when determining a match.
 */

-(id)initWithToken:(NSString*)token scanLocation:(NSUInteger)aScanLocation matchStrings:(NSArray*)matchStrings ignoreCase:(BOOL)ignoreCase;
{
  if ((self = [super init]))
  {
    insist (token && [token length]);
    insist (matchStrings);
    insist ([token rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location == NSNotFound);
    
    /*save the scanLocation and word*/
    scanLocation = aScanLocation;
    word = token;
    
    /*make the marked up version of the word. we do this because we might need it, but also because doing the markup is as hard as determining if
     the word is a match (because of punctuation) so we might as well do one in terms of the other.*/
    
    prettyWord = [self stringByMarkingString:word matchStrings:matchStrings ignoreCase:ignoreCase];
    insist (prettyWord && prettyWord.length >= word.length);
  }
  return self;
}

-(NSUInteger)length
{
  return [word length];
}
-(NSUInteger)scanLocation
{
  return scanLocation;
}
-(NSString*)stringValue
{
  return prettyWord;
}
-(BOOL)isMatch
{
  return prettyWord.length != word.length;
}

@end
