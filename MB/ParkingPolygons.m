//
//  ParkingPolygons.m
//  Practice3
//
//  Created by Mike on 10/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ParkingPolygons.h"

@implementation ParkingPolygons

@synthesize beginPointLatitude,beginPointLongitude,endPointLatitude,endPointLongtitude,streetName,streetNum,startTime,stopTime,parkingInsurance,schoolZone,permitNum,dataBaseID,areaName,exceptionText,streetDirection,distanceFromLocation,meterCost;

-(CLLocationCoordinate2D) getBeginPoint
{
    return CLLocationCoordinate2DMake([beginPointLatitude doubleValue], [beginPointLongitude doubleValue]);
}

-(CLLocationCoordinate2D) getEndPoint
{
    return  CLLocationCoordinate2DMake([endPointLatitude  doubleValue], [endPointLongtitude doubleValue]);
}

- (id) initWithBeginLat:
(NSString *) cBeginLat
            andBeginLon: (NSString *) cBeginLong
              andEndLat: (NSString *) cEndLat
             andEndLong: (NSString *) cEndLong
          andStreetName: (NSString *) cStreetName
           andStreetNum: (NSString *) cStreetNum
           andStartTime: (NSString *) cStartTime
            andStopTime: (NSString *) cStopTime
             andParkIns: (NSString *) cParkIns
          andSchoolZone: (NSString *) cSchoolZone
           andPermitNum: (NSString *) cPermitNum
            andAreaName: (NSString *) cAreaName
                  andID: (NSString *) cID
       andExceptionText: (NSString *) cExcText
     andStreetDirection: (NSString *) cStreetDirection
            andParkType: (NSString *) cParkType
           andMeterCost: (NSString *) cMeterCost
          andLocationID: (NSString *) cLocID;

{
    self = [self init];
    if(self)
    {
        self.beginPointLongitude = cBeginLong;
        self.beginPointLatitude  = cBeginLat;
        self.endPointLongtitude  = cEndLong;
        self.endPointLatitude    = cEndLat;
        self.streetName          = cStreetName;
        self.streetNum           = cStreetNum;
        self.stopTime            = cStopTime;
        self.startTime           = cStartTime;
        self.parkingInsurance    = cParkIns;
        self.schoolZone          = cSchoolZone;
        self.permitNum           = cPermitNum;
        self.areaName            = cAreaName;
        self.dataBaseID          = cLocID;//switched this for the location id
        self.exceptionText       = cExcText;
        self.streetDirection     = cStreetDirection;
        self.parkType            = cParkType;
        self.meterCost           = cMeterCost;
    }
    
    return self;
}

#define NOON_TIME_ENCODED 1200
#define USE_METERS 0
#define FEET_IN_METER 3.28084

enum
{
    NO_PARKING               = 0,
    FREE_PARKING             = 1,
    METER_NOT_ENFORCED       = 2,
    PERMIT_NOT_ENFORCED      = 3,
    LOADING_STANDING_ZONE_NE = 4,
    METER_LOADING_NE         = 5,
    LOADING_AND_PERMIT_NE    = 6,
    METER_AND_PERMIT_NE      = 7,
};

-(NSString *) getParkingTypeString
{
    NSInteger nType = [self.parkType integerValue];
    NSString *pType = [[NSString alloc]init];
    if(nType == NO_PARKING)
        pType= @"No Parking";
    else if(nType==FREE_PARKING)
        pType = @"Free Parking";
    else if(nType==METER_NOT_ENFORCED)
        pType = @"Meter (Not Enforced)";
    else if(nType==PERMIT_NOT_ENFORCED)
        pType = @"Permit (Not Enforced)";
    else if(nType==LOADING_STANDING_ZONE_NE)
        pType = @"Loading/Standing (Not Enforced)";
    else if(nType==METER_LOADING_NE)
        pType = @"Meter & Loading (Not Enforced)";
    else if(nType==LOADING_AND_PERMIT_NE)
        pType = @"Loading & Permit (Not Enforced)";
    else if(nType==METER_AND_PERMIT_NE)
        pType = @"Meter & Permit (Not Enforced)";
    else
        pType = @"Unknown type";
    
    return pType;
}

-(NSString*) getParkingTypeStringWithDistance
{
    NSString *pType = [[NSString alloc]init];
    pType = [self getParkingTypeString];
    

    NSString *pTimeRange=nil;
    if(distanceFromLocation >= 0.0f)
    {
        if(USE_METERS)
        {
            pTimeRange=[[NSString alloc] initWithFormat:@"%@\r\nDistance: %.0f meters", pType, distanceFromLocation];
        }
        else
        {
            pTimeRange=[[NSString alloc] initWithFormat:@"%@\r\nDistance: %.02f miles", pType, distanceFromLocation*3.28084 / 5280];
        }
    }
    else
        pTimeRange=[[NSString alloc] initWithFormat:@"%@",pType];
    
    return pTimeRange;
}

-(NSString*) getParkTimeRange_HHMM : (NSString*) pTimeRange :(double) distance;
{
    const NSInteger nStartTimeRaw = [startTime intValue];
    const NSInteger nEndTimeRaw   = [stopTime intValue];
    
    const NSInteger nStartTimeMinutes = nStartTimeRaw % 100;
    const NSInteger nStartTimeHour    = nStartTimeRaw / 100;
    const NSInteger nStopTimeHour     = nEndTimeRaw / 100;
    const NSInteger nStopTimeMinutes  = nEndTimeRaw % 100;
    
    NSString *startTimeAM_PM = [[NSString alloc] init];
    NSString *endTimeAM_PM   = [[NSString alloc] init];
    
    if( nStartTimeRaw >= NOON_TIME_ENCODED)
    {
        startTimeAM_PM = @"PM";
        //DEVTESTnStartTimeHour = nStartTimeHour - 12;
    }
    else
    {
        startTimeAM_PM=@"AM";
    }
    
    if( nEndTimeRaw >= NOON_TIME_ENCODED)
    {
        endTimeAM_PM = nStopTimeHour - 12 == 12 ? @"AM" : @"PM";
    }
    else
    {
        endTimeAM_PM = @"AM";
    }
    
    if(!USE_METERS)
    {
        distance = distance * FEET_IN_METER;
        pTimeRange = [pTimeRange stringByAppendingFormat:@"%2ld:%02ld %@-%2ld:%02ld %@: %.0f ft", (long)nStartTimeHour, (long)nStartTimeMinutes,startTimeAM_PM, (long)nStopTimeHour, (long)nStopTimeMinutes,endTimeAM_PM, distance];
    }
    else
    {
        pTimeRange = [pTimeRange stringByAppendingFormat:@"%2ld:%02ld %@-%2ld:%02ld %@: %.0f meters",(long)nStartTimeHour,(long)nStartTimeMinutes,startTimeAM_PM, (long)nStopTimeHour,(long)nStopTimeMinutes, endTimeAM_PM, distance];
        
    }
    
    
    
    return pTimeRange;
}

-(CGFloat) getParkingInsurance
{
    return [parkingInsurance floatValue];
}

-(NSComparisonResult) compare:(ParkingPolygons*)otherObject
{
    return otherObject.distanceFromLocation > distanceFromLocation;
}

-(CLLocationCoordinate2D) getParkingSpotMidPoNSInteger : (BOOL) withOffset
{
    double dBeginLat  = [beginPointLatitude doubleValue];
    double dEndLat    = [endPointLatitude doubleValue ];
    double dBeginLong = [beginPointLongitude doubleValue];
    double dEndLong   = [endPointLongtitude doubleValue];
    
    double longDiff = fabs(dEndLong - dBeginLong);
    double latDiff  = fabs(dEndLat - dBeginLat);
    
    CLLocationCoordinate2D myMid;
    myMid.latitude  = (dBeginLat + dEndLat) / 2.0f;
    myMid.longitude = (dBeginLong + dEndLong) / 2.0f;
    
    if(withOffset)
    {
        if(longDiff > latDiff)//eastwest
        {
            myMid.latitude += .00035;
        }
        else//nortsouth
        {
            myMid.longitude += .0003;
        }
    }
    
    return myMid;
}

-(CLLocation*) convertCoordinate2DtoCLLocation : (CLLocationCoordinate2D) point
{
    CLLocation *pRet = [[CLLocation alloc] initWithLatitude : (CLLocationDegrees)point.latitude longitude:(CLLocationDegrees)point.longitude];
    return pRet;
}

-(CLLocation*) getMidPointAsCLLocation
{
    CLLocationCoordinate2D midpoint = [self getParkingSpotMidPoNSInteger : NO];
    return [self convertCoordinate2DtoCLLocation: midpoint];
}

-(CLLocation*) getBeginPointAsCLLocation
{
    CLLocationCoordinate2D point = [self getBeginPoint];
    return [self convertCoordinate2DtoCLLocation: point];
}

-(CLLocation*) getEndPointAsCLLocation
{
    CLLocationCoordinate2D point = [self getEndPoint];
    return [self convertCoordinate2DtoCLLocation: point];
}

-(void) setDistance : (double) distance
{
    self->distanceFromLocation = distance;
}

-(NSString *) getLocationAddress
{
    NSString *address = [[NSString alloc]initWithFormat:@"%@ %@ %@", streetNum, streetDirection, streetName];
    return address;
}

@end
