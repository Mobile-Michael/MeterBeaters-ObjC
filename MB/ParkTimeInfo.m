//
//  ParkTimeInfo.m
//  Practice3
//
//  Created by Mike on 9/15/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ParkTimeInfo.h"
#import "meterbeater.pch"

@implementation ParkTimeInfo

@synthesize m_nDay;
@synthesize m_nMinute;
@synthesize m_nHour;
@synthesize m_nMonth;
@synthesize m_nDayOfMonth;
@synthesize m_nYear;

-(NSInteger) getHour        {return self.m_nHour;}
-(NSInteger) getDay         {return self.m_nDay;}
-(NSInteger) getMinute      {return self.m_nMinute;}
-(NSInteger) getMonth       {return self.m_nMonth;}
-(NSInteger) getDayOfMonth  {return self.m_nDayOfMonth;}
-(NSInteger) getYear        {return self.m_nYear;}

-(NSInteger) getDatabaseFormatted
{
    return self.m_nHour * 100 + self.m_nMinute;
}

-(NSString *) getYYYYMMDD
{
    return [[NSString alloc] initWithFormat:@"%d-%02d-%02d",(int)self.m_nYear,(int)self.m_nMonth,(int)self.m_nDayOfMonth];
}

-(bool) isTimeInited
{
    return m_nHour != -1;
}

-(CONFLICT_REASONS) conflictsWithBeginTime: (ParkTimeInfo *)pEndTime
{
    NSDate *startDate = [self getNSDate];
    NSDate *endDate   = [pEndTime getNSDate];
    
    const NSInteger flags = NSCalendarUnitDay;
    NSDateComponents *difference = [[NSCalendar currentCalendar] components: flags fromDate:startDate toDate:endDate options:0];
    
    if([difference day] > 7)
        return SEVEN_DAY_LIMIT;
    
    if ([startDate compare: endDate] == NSOrderedAscending)
        return OKAY;
    else
        return TIME_CONFLICT;
}

-(void) copy : (ParkTimeInfo*) other
{
    other.m_nDay        = m_nDay;
    other.m_nDayOfMonth = m_nDayOfMonth;
    other.m_nHour       = m_nHour;
    other.m_nMinute     = m_nMinute;
    other.m_nMonth      = m_nMonth;
    other.m_nYear       = m_nYear;
}

-(void) setFromNSDate : (NSDate*)pDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components=nil;
    components= [gregorian components: NSUIntegerMax fromDate: pDate];
    
    m_nHour       = [components hour];
    m_nMinute     = [components minute];
    m_nDay        = [components weekday];
    m_nDayOfMonth = [components day];
    m_nMonth      = [components month];
    m_nYear       = [components year];
}

-(NSDate*) getNSDate
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:    self->m_nDayOfMonth];
    [comps setMonth:  self->m_nMonth];
    [comps setYear:   self->m_nYear];
    [comps setHour:   self->m_nHour];
    [comps setMinute: self->m_nMinute];
    [comps setWeekday:self->m_nDay];
    [comps setSecond: 0];
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return  [cal dateFromComponents:comps];
}

-(void) addTime : (NSInteger)nHours : (NSInteger) nMinutes
{
    NSInteger nTimeInSeconds=0;
    nTimeInSeconds += nHours   > 0 ? nHours   * 60 * 60 : 0;
    nTimeInSeconds += nMinutes > 0 ? nMinutes * 60 : 0;
    
    NSDate *pCurDate = [self getNSDate];
    NSDate *pNewDate =[[NSDate alloc]initWithTimeInterval:nTimeInSeconds sinceDate: pCurDate];
    [self setFromNSDate: pNewDate];
}

-(void) logMe
{
    NSString *pString=[[NSString alloc] initWithFormat:@"Month: %li Day: %li Hour: %li Minute: %li [DayofMonth: %li] ",(long)m_nMonth,(long)m_nDay,(long)m_nHour,(long)m_nMinute,(long)m_nDayOfMonth];
    LogBeater(@"%@",pString);
}

@end
