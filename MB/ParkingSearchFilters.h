//
//  ParkingSearchFilters.h
//  Practice3
//
//  Created by Mike on 9/8/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

@class ParkTimeInfo;
typedef enum
{
    FREE = 0,
    METER,
    PERMIT,
    STREET_CLEANING,
}MAP_PARK_TYPE;

@interface ParkingSearchFilters : NSObject
{
    BOOL m_bParkLocationGood;
    CGFloat m_fMilesToQueryValue;
    ParkTimeInfo *m_pParkTimeInfoBegin;
    ParkTimeInfo *m_pParkTimeInfoEnd;
    NSString *m_pDestString;
    NSInteger m_nParkingZone;
    MAP_PARK_TYPE m_nParkType;
}

@property CLLocationCoordinate2D m_clMyLocationCoordinate;
@property CLLocationCoordinate2D m_clCoordinate;
@property bool m_bParkingQueryChanged;


-(id) init;
-(void) initMembers;
-(void) setMilesToQuery : (CGFloat) fValue;
-(void) setString : (NSString*) sValue;
-(NSString *) getDestString;
-(NSString *) getLastSearchStringFull;
-(void) setUseMyLocation : (BOOL) bValue;
-(void) reset : (CGFloat) fMilesToQuery;
-(void) setBaseCoordinate: (CLLocationCoordinate2D)pCoordinate;
-(void) setMyLocationCoordinate: (CLLocationCoordinate2D)pCoordinate;
-(void) setParkLocationValid: (BOOL) bIsValid;
-(void) setParkingZone : (int) nParkingZone;
-(void) setDestString : (NSString*) pDest;

-(ParkTimeInfo*) getParkTimeBegin;
-(ParkTimeInfo*) getParkTimeEnd;
-(CGFloat) getMilesToQuery;
-(BOOL)  useMyLocation;
-(BOOL)  isParkLocationValid;

-(CLLocationCoordinate2D) getBaseCoordinate;
-(CLLocationCoordinate2D) getMyLocationCoordinate;

-(NSInteger) getZone;
-(MAP_PARK_TYPE) getParkType;
-(void)SetParkType : (MAP_PARK_TYPE) type;
-(NSString*) getSpotInfoAsString : (NSString*)spotInfoText;


@end
