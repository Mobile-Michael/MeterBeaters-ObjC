//
//  SharedVCFunctions.m
//  Practice3
//
//  Created by Mike on 12/8/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "SharedVCFunctions.h"

@implementation SharedVCFunctions

+(void) logBounds : (CGRect) rect andName : (NSString *) pName
{
  NSLog(@"[%@]width %.2f height: %.2f Origin [%.2f,%.2f]",pName,rect.size.width,rect.size.height,rect.origin.x,rect.origin.y);
}

+ (NSString*) addChicagoILText : (NSString *)stringToAppend
{
  stringToAppend=[stringToAppend stringByAppendingString:@" ,Chicago, IL"];
  return stringToAppend;
}

@end
