//
//  insist.h
//  Yelp
//
//  Created by finucane on 4/18/13.
//  Copyright (c) 2013 finucane. All rights reserved.
//

#ifndef Yelp_insist_h
#define Yelp_insist_h


#define insist(e) if(!(e)) [NSException raise: @"assertion failed." format: @"%@:%d (%s)", [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent], __LINE__, #e]

#endif
