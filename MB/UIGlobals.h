//
//  UIGlobals.h
//  Practice3
//
//  Created by Mike on 3/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class ParkingSearchFilters;
typedef NS_ENUM(NSInteger, SEARCH_INPUT_ROWS)
{
    kTitleBar = 0,
    kTypeOfParking,
    kStartTimeLabelRow      ,
    kStartTimeDatePickerRow ,
    kStartHelperButtons     ,
    kSpacer2                ,
    kEndTimeLabelRow        ,
    kEndTimeDatePickerRow   ,
    kHelperButtons          ,
    kSpacer1                ,
    kUseMyLocationRow       ,
    kLocationRow            ,
    kDistancePlaceHolder    ,
    kDistanceRow            ,
    kZoneRow                ,
    kQueryRow               ,
    kSpacer3                ,
    kAlertSetForRow         ,
    kAddressForSS           ,
    kInfoTextForSS          ,
    kDaysPlaceHolderText    ,
    kDaysForSS              ,
    kResetWardRow,
    NUM_SEARCH_INPUT_ROWS//NEEDS TO BE LAST
};



#define kDatePickerHeight 162.0f
#define kStandardRowHeight 44.0f

//TabBarIndices
typedef NS_ENUM(NSInteger, TAB_INDICIES)
{
    LOGIN_INDEX = 0,
    SEARCH_INDEX,
    MAP_INDEX,
    TABLE_VIEW_INDEX,
    SOCIAL_INDEX,
    NUM_PAGE_INDEXES
};

@interface UIGlobals : NSObject
{
    ParkingSearchFilters *m_pSearchInputs;
}

-(id) init;

+(UIColor*) getColorForRowParkingInput : (NSInteger) nRow : (BOOL) bOkayToMap;

+(UIColor*) getNavBarColor;
+(UIColor*) getNavBarTextColor;
+(UIColor*) getMainBackgroundColor;
+(UIColor*) getMainBoldBackgroundColor;
+(UIColor*) ourDarkGray;
+(UIColor*) ourLightGray;
+(UIColor*) presetButtonGray;
+(UIColor*) presetParkingType;
+(NSString *) uuid;
+(void) showOutRangeError:(UIViewController*)viewController;
+(UIGlobals*) getInstance;
+(ParkingSearchFilters*) getSearchFilters;
+(NSString*)  getEmail;
+(void) saveEmail : (NSString*) pEmail;


@end
