//
//  ParkingLineOverlay.h
//  Practice3
//
//  Created by Mike on 11/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

enum test
{
  STREET = 0,
  PERMIT = 1
}typedef PARKINGTYPES;

@interface ParkingLineOverlay : MKPolyline
{
  PARKINGTYPES m_nType;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic, readonly) CLLocationCoordinate2D overlayTopLeftCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D overlayTopRightCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D overlayBottomLeftCoordinate;

-(id) init : (PARKINGTYPES) withType
            andBeginLat: (double) dBeginLat
              andEndLat: (double) dEndLat
          andBeginLong : (double) dBeginLong
            andEndLong : (double) dEndLong;

-(void) setParkingType: (PARKINGTYPES) nType;
-(void) getLineColor: (UIColor *) pColor;

-(PARKINGTYPES)  getParkingType;
-(MKMapRect) getBoundingMapRect;

@end
