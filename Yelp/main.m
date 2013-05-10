//
//  main.m
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "insist.h"
#import "YPSnippet.h"
#import "YPWord.h"

/*
 this is just one simple algorithm so to make it clear just do it in one blob of procedural code. with some helping objects.
 
 i wrote 2 unit tests just as an example, i read the apple docs and know how to do unit tests now for ios/osx. of course i never did
 them before. they are actually sort of a good idea.
 
 the approach is we pick a window size (in characters) and slide a window across the document word-by-word, keeping track of how many
 matches the window has as it goes along. when we've scanned the whole document we go back to the window position that had the most matches and
 print out the window from there. whitespace information is thrown away when the snippet is printed, in other words if the document had
 lots of whitespace formatting or whatever, that's lost.
 
 YPSnippet is the window.
 YPWord is a word, able to deal with punctuation and matching and emitting the highlighting.
 
 matching is case insenstive, and in the "OR" sense, because that's what the
 example, http://www.yelp.com/search?find_desc=deep+dish+pizza&find_loc=sf. seems to do.
 
 "insist" is my own assertion macro, see "insist.h".
 
 to break ties snippets that are longer are selected over snippets that are shorter and snippets earlier on are selected over laters ones.
 
 if no matches at all are found, the snippet is just the start of the document.
 
 */




NSString*highlight_doc (NSString*document, NSString*searchString);

/*swallow the exception that NSFileHandle::readDataToEndOfFile throws*/
NSString*pathToString (char*path)
{
  NSFileHandle*fh = [NSFileHandle fileHandleForReadingAtPath:[[NSString alloc] initWithUTF8String:path]];
  if (!fh)
    return 0;

  NSData*data;
  
  @try
  {
    data = [fh readDataToEndOfFile];
  }
  @catch (NSException*e)
  {
    return 0;
  }
  insist (data);
  return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

void die (char*format,...)
{
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  printf ("\n");
  va_end(args);
  exit (1);
}

int main(int argc, const char * argv[])
{
  if (argc != 3)
    die ("usage :  %s <filename> <search string>", argv [0]);
  
  @autoreleasepool
  {
    /*cast away const to avoid the const virus*/
    NSString*doc = pathToString ((char*)argv [1]);
    if (!doc)
      die ("couldn't read %s", argv [1]);
    
    NSString*searchString = [[NSString alloc] initWithUTF8String:argv [2]];
    insist (searchString);
    
    //NSLog (@"search string is %@", searchString);
    
    NSString*snippet = highlight_doc (doc, searchString);
    insist (snippet);
    
    printf ("%s\n", [snippet UTF8String]);
  }
  return 0;
}

#define MAX_SNIPPET_CHARS 300

NSString*highlight_doc (NSString*document, NSString*searchString)
{
  insist (document && searchString && searchString.length);
  
  /*specify the highlight tags.*/
  YPWord.startHighlightString = @"[[HIGHLIGHT]]";
  YPWord.endHighlightString = @"[[ENDHIGHLIGHT]]";
    
  /*break the search string into separate strings*/
  NSArray*matchStrings = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  insist (matchStrings.count);
  
  /*make a scanner for the document. the default settings will work fine (skip whitespace).*/
  NSScanner*scanner = [NSScanner scannerWithString:document];
  insist (scanner);
  
  /*make an empty snippet. we'll add words to it initially and then slide it over the document by removing words from the
   start and appending to the end*/
  
  YPSnippet*snippet = [[YPSnippet alloc] initWithMaxLength:MAX_SNIPPET_CHARS];
  insist (snippet);
  
  /*we use these to keep track of the previous best snippet*/
  NSUInteger bestScanLocation = 0;
  NSUInteger bestLength = 0;
  NSUInteger bestMatchMetric = 0;
  
  /*find the best snippet in the document*/
  NSString*token;
  
  for (NSUInteger scanLocation = [scanner scanLocation];![scanner isAtEnd]; scanLocation = [scanner scanLocation])
  {
    /*if we are scanning a huge document we have to be sure to free up stuff from time to time*/
    @autoreleasepool
    {
      if (![scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&token])
        break;
            
      insist (token);
      
      if (![snippet appendToken:token slide:YES scanLocation:scanLocation matchStrings:matchStrings ignoreCase:YES])
        continue; //pathological case, token too big
      
      if (snippet.matchMetric == 0)
        continue;
      
      /*if we are improved, remember the details*/
      if (snippet.matchMetric > bestMatchMetric ||
          (snippet.matchMetric == bestMatchMetric && snippet.length <= bestLength))
      {
        bestLength = snippet.length;
        bestScanLocation = snippet.scanLocation;
        bestMatchMetric = snippet.matchMetric;
        
        //NSLog (@"snippet is %@", snippet.stringValue);
      }
    }
  }
  
  /*reset the scanner to the start of the best snippet*/
  [scanner setScanLocation:bestScanLocation];
  
  /*reset the snippet ...*/
  [snippet clear];
  
  /*... and rescan into it*/
  while ([scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&token])
  {
    insist (token);
    if (![snippet appendToken:token slide:NO scanLocation:0 matchStrings:matchStrings ignoreCase:YES])
      break;
  }

  /*done.*/
  return snippet.stringValue;
}

