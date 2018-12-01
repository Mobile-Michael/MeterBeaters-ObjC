//
//  Globals.h
//  Practice3
//
//  Created by Mike on 3/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Globals <NSObject>

#define kStartTimeLabelRow 0
#define kStartTimeDatePickerRow 1
#define kEndTimeLabelRow 2
#define kEndTimeDatePickerRow 3
#define kDistanceRow 4
#define kUseMyLocationRow 5
#define kLocationRow 6
#define kQueryRow 7

#define kDatePickerHeight 162.0f
#define kStandardRowHeight 44.0f

-(UIColor*) getColorForRow : (NSInteger) nRow
{
  UIColor *pColor=[UIColor clearColor];
  switch(nRow)
  {
    case kStartTimeLabelRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kStartTimeDatePickerRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kEndTimeLabelRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kEndTimeDatePickerRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kQueryRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kLocationRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    case kUseMyLocationRow:
    {
      pColor=[UIColor blueColor];
      break;
    }
    default:
      break;
  }
  return pColor;
}

@end
