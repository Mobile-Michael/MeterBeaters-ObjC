//
//  ParkingSearchFilters.m
//  Practice3
//
//  Created by Mike on 9/8/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ParkingSearchFilters.h"
#import "ParkTimeInfo.h"
@interface ParkingSearchFilters()
@property (nonatomic) BOOL m_bUseMyLocation;
@end


@implementation ParkingSearchFilters

@synthesize m_clMyLocationCoordinate;
@synthesize m_clCoordinate, m_bParkingQueryChanged;
@synthesize m_bUseMyLocation;
//mutator functions

-(void) setMilesToQuery:(CGFloat) fValue
{
    m_fMilesToQueryValue = fValue;
}

-(void) setBaseCoordinate: (CLLocationCoordinate2D)pCoordinate
{
    m_clCoordinate = pCoordinate;
}

-(void) setMyLocationCoordinate: (CLLocationCoordinate2D)pCoordinate
{
    self.m_clMyLocationCoordinate = pCoordinate;
}

-(void) reset:(CGFloat) fMilesToQuery
{
    [self setMilesToQuery : fMilesToQuery];
    [self setUseMyLocation : FALSE];
}

-(void) setUseMyLocation:(BOOL)bValue
{
    m_bUseMyLocation = bValue;
    if(m_bUseMyLocation == YES)
    {
        m_bParkLocationGood = YES;
    }
}


-(void) setString : (NSString*) sValue
{
    if(m_pDestString == nil)
    {
        m_pDestString=[[NSString alloc]init];
    }
    
    m_pDestString = sValue;
}

-(int) isTodayOrTomorrow : (NSDate *) pDateToCompare
{
    NSInteger components = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components: components fromDate: pDateToCompare];
    NSDateComponents *today    = [[NSCalendar currentCalendar] components: components fromDate:[NSDate date]];
    
    if([today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era])
    {
        if([today day] == [otherDay day])
        {
            return 1;
        }
        else if([today day] + 1 == [otherDay day])
        {
            return 2;
        }
        else
        {
            return 0;
        }
    }
    
    return 0;
}

-(NSString*) getTimeFormattedForMap
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *pTimeStringBegin = [[NSString alloc] init];
    NSString *pTimeStringEnd = [[NSString alloc] init];
    NSDate *pBegin = [self->m_pParkTimeInfoBegin getNSDate];
    NSDate *pEnd = [self->m_pParkTimeInfoEnd getNSDate];
    NSInteger timeValue = [self isTodayOrTomorrow: pBegin];
    if(timeValue == 1)//TODAY
    {
        pTimeStringBegin = @"Today: ";
    }
    else if(timeValue == 2)//TOMORROW
    {
        pTimeStringBegin = @"Tomorrow ";
    }
    else
    {
        [formatter setDateFormat:@"M/d/yy "];
        pTimeStringBegin = [pTimeStringBegin stringByAppendingString: [formatter stringFromDate: pBegin]];
    }
    
    [formatter setDateFormat:@"h:mm a"];
    pTimeStringBegin = [pTimeStringBegin stringByAppendingString:[formatter stringFromDate:pBegin]];
    
    timeValue = [self isTodayOrTomorrow: pEnd];
    if(timeValue == 1)//TODAY
    {
        pTimeStringEnd = @"Today: ";
    }
    else if(timeValue == 2)//TOMORROW
    {
        pTimeStringEnd = @"Tomorrow: ";
    }
    else
    {
        [formatter setDateFormat:@"M/d/yy "];
        pTimeStringEnd = [pTimeStringEnd stringByAppendingString: [formatter stringFromDate: pEnd]];
    }
    
    
    [formatter setDateFormat:@"h:mm a"];
    pTimeStringEnd = [pTimeStringEnd stringByAppendingString:[formatter stringFromDate:pEnd]];
    
    pTimeStringBegin = [pTimeStringBegin stringByAppendingFormat:@" to %@",pTimeStringEnd];
    return pTimeStringBegin;
}

-(NSString*) getSpotInfoAsString : (NSString*) spotInfoText
{
    if([self getParkType] == PERMIT)
    {
        NSString *zoneText = [[NSString alloc] initWithFormat:@"Permit Number: %ld \n (Tap to change)", (long)m_nParkingZone];
        return zoneText;
    }
    else
    {
        if( spotInfoText == nil)
        {
            return [[NSString alloc] initWithFormat:@"%@\n%@\n (Tap to change)", m_pDestString
                    , [self getTimeFormattedForMap]];
        }
        else
        {
            return [[NSString alloc] initWithFormat:@"%@\n%@", m_pDestString
                    , spotInfoText];
        }
    }
}

-(void) initMembers
{
    self->m_bUseMyLocation = NO;
    self->m_bParkLocationGood = YES;
    self->m_fMilesToQueryValue = .30f;
    self->m_pParkTimeInfoBegin = [[ParkTimeInfo alloc] init];
    self->m_pParkTimeInfoEnd = [[ParkTimeInfo alloc] init];
    NSDate *now =[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [self->m_pParkTimeInfoBegin setFromNSDate: now];
    [self->m_pParkTimeInfoEnd setFromNSDate: now];
    self->m_pDestString = @"233 S Wacker Chicago, IL";
    self->m_nParkingZone = -1;
    self->m_nParkType = FREE;
    
    CLLocationCoordinate2D defaultLoc = CLLocationCoordinate2DMake(41.878905, -87.636201);
    [self setBaseCoordinate : defaultLoc];
    self->m_bParkingQueryChanged = YES;
    [self->m_pParkTimeInfoEnd addTime: 2 : 0];
}

-(id) init
{
    if(self)
    {
        [self initMembers];
    }
    
    return self;
}

-(void) setDestString : (NSString*) pDest
{
    m_pDestString = pDest;
}

-(void) setParkLocationValid: (BOOL) bIsValid
{
    m_bParkLocationGood = bIsValid;
}

- (NSString *) getLastSearchStringFull
{
    if(m_pDestString)
    {
        NSString *pFullSerachString=
        [[NSString alloc] initWithFormat:@"%@,%li%li,%li%li,%.2f",m_pDestString,(long)[m_pParkTimeInfoBegin getDatabaseFormatted],(long)[m_pParkTimeInfoBegin getDayOfMonth],(long)[m_pParkTimeInfoEnd getDatabaseFormatted],(long)[m_pParkTimeInfoEnd getDayOfMonth],m_fMilesToQueryValue];
        
        return pFullSerachString;
    }
    else
    {
        return nil;
    }
}

//accessor functions
-(NSInteger) getZone                               {return m_nParkingZone;}
-(CGFloat) getMilesToQuery                         {return m_fMilesToQueryValue;}
-(BOOL) useMyLocation                              {return m_bUseMyLocation;}
-(BOOL)  isParkLocationValid                       {return m_bParkLocationGood;}
-(CLLocationCoordinate2D) getBaseCoordinate        {return m_clCoordinate;}
-(ParkTimeInfo*) getParkTimeBegin                  {return m_pParkTimeInfoBegin;}
-(ParkTimeInfo*) getParkTimeEnd                    {return m_pParkTimeInfoEnd;}
-(NSString *) getDestString                        {return m_pDestString;}
-(CLLocationCoordinate2D)getMyLocationCoordinate   {return self.m_clMyLocationCoordinate;}
-(void) setParkingZone : (int) nParkingZone        {m_nParkingZone = nParkingZone;};
-(MAP_PARK_TYPE) getParkType                       {return m_nParkType;}
-(void) SetParkType:(MAP_PARK_TYPE)type            {m_nParkType = type;}


@end
