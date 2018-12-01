//
//  ParkTimeInfo.h
//  Practice3
//
//  Created by Mike on 9/15/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,CONFLICT_REASONS)
{
    OKAY = 0,
    SEVEN_DAY_LIMIT,
    TIME_CONFLICT,
};

@interface ParkTimeInfo : NSObject

@property NSInteger m_nMonth;
@property NSInteger m_nDay;
@property NSInteger m_nHour;
@property NSInteger m_nMinute;
@property NSInteger m_nDayOfMonth;
@property NSInteger m_nYear;


-(NSInteger) getDatabaseFormatted;
-(NSString*) getYYYYMMDD;
-(NSInteger) getHour;
-(NSInteger) getMinute;
-(NSInteger) getDay;
-(NSInteger) getMonth;
-(NSInteger) getDayOfMonth;
-(NSInteger) getYear;

-(CONFLICT_REASONS) conflictsWithBeginTime: (ParkTimeInfo *)pEndTime;
-(void) copy : (ParkTimeInfo*) other;
-(void) setFromNSDate : (NSDate*)pDate;
-(void) logMe;
-(void) addTime : (NSInteger)nHours : (NSInteger) nMinutes;
-(NSDate*) getNSDate;
@end
