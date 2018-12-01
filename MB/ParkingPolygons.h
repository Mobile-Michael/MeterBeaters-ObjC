//
//  ParkingPolygons.h
//  Practice3
//
//  Created by Mike on 10/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface ParkingPolygons : NSObject


@property (nonatomic,strong) NSString *beginPointLatitude;
@property (nonatomic,strong) NSString *beginPointLongitude;
@property (nonatomic,strong) NSString *endPointLatitude;
@property (nonatomic,strong) NSString *endPointLongtitude;
@property (nonatomic,strong) NSString *streetName;
@property (nonatomic,strong) NSString *streetNum;
@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *stopTime;
@property (nonatomic,strong) NSString *parkingInsurance;
@property (nonatomic,strong) NSString *schoolZone;
@property (nonatomic,strong) NSString *permitNum;
@property (nonatomic,strong) NSString *areaName;
@property (nonatomic,strong) NSString *dataBaseID;
@property (nonatomic,strong) NSString *exceptionText;
@property (nonatomic,strong) NSString *streetDirection;
@property (nonatomic,strong) NSString *parkType;
@property (nonatomic,strong) NSString *meterCost;


@property double distanceFromLocation;

- (id) initWithBeginLat: (NSString *) cBeginLat
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

-(NSString*) getParkTimeRange_HHMM : (NSString*) pTimeRange : (double) distance;
-(CGFloat) getParkingInsurance;
-(NSString *) getParkingTypeString;
-(NSString*) getParkingTypeStringWithDistance;
-(NSComparisonResult) compare :(ParkingPolygons*)otherObject;
-(CLLocationCoordinate2D) getParkingSpotMidPoNSInteger : (BOOL) withOffset;
-(CLLocationCoordinate2D) getBeginPoint;
-(CLLocationCoordinate2D) getEndPoint;
-(CLLocation*) getMidPointAsCLLocation;
-(CLLocation*) getBeginPointAsCLLocation;
-(CLLocation*) getEndPointAsCLLocation;
-(NSString *) getLocationAddress;


@end
