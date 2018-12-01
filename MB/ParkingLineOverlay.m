//
//  ParkingLineOverlay.m
//  Practice3
//
//  Created by Mike on 11/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ParkingLineOverlay.h"
@implementation ParkingLineOverlay
@synthesize coordinate,boundingMapRect,overlayBottomLeftCoordinate,overlayTopLeftCoordinate,overlayTopRightCoordinate;

-(void) setParkingType: (PARKINGTYPES) nType
{
  m_nType=nType;
}

-(void) getLineColor: (UIColor *) pColor
{
  if(m_nType==PERMIT)
  {
    pColor = [UIColor blueColor];
  }
  else if(m_nType==STREET)
  {
    pColor = [UIColor redColor];
  }
  else
  {
    NSString *pErrorString=[[NSString alloc]initWithFormat:@"Unhandled %d in getLineColor()",(int)m_nType];
      
    UIAlertView *pAlert=[[UIAlertView alloc] initWithTitle:@"ERROR" message: pErrorString delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
      [pAlert show];
  }
}

-(id) init : (PARKINGTYPES) withType
                          andBeginLat:(double) dBeginLat
                            andEndLat:(double) dEndLat
                        andBeginLong :(double) dBeginLong
                          andEndLong :(double) dEndLong
{
  self = [self init];
  if(self)
  {
    CLLocationCoordinate2D lineBegin=CLLocationCoordinate2DMake(dBeginLat,dBeginLong);
    CLLocationCoordinate2D lineEnd=CLLocationCoordinate2DMake(dEndLat,dEndLong);
    
    overlayTopLeftCoordinate.longitude=lineBegin.longitude+.01;
    overlayTopLeftCoordinate.latitude=lineBegin.latitude+.01;
    
    overlayTopRightCoordinate.longitude=lineEnd.longitude+.01;
    overlayTopRightCoordinate.latitude=lineBegin.latitude+.01;
    
    overlayBottomLeftCoordinate.longitude=lineBegin.longitude-.01;
    overlayBottomLeftCoordinate.latitude=lineBegin.latitude-.01;
    
    CLLocationCoordinate2D midpoint;
    midpoint.latitude=(dBeginLat + dEndLat)/2.0f;
    midpoint.longitude=(dBeginLong + dEndLong)/2.0f;
    
    m_nType=withType;
    coordinate=midpoint;
    boundingMapRect=[self getBoundingMapRect];
  }
  return self;
}

-(PARKINGTYPES) getParkingType
{
  return m_nType;
}

- (MKMapRect)getBoundingMapRect
{
  MKMapPoint mpUpperLeft=MKMapPointForCoordinate(overlayTopLeftCoordinate);
  MKMapPoint mpUpperRight=MKMapPointForCoordinate(overlayTopRightCoordinate);
  MKMapPoint mpBottomLeft=MKMapPointForCoordinate(overlayBottomLeftCoordinate);
  MKMapRect bounds=MKMapRectMake(mpUpperLeft.x, mpUpperLeft.y, fabs(mpUpperLeft.x - mpUpperRight.x), fabs(mpUpperLeft.y - mpBottomLeft.y));
  
  return bounds;
}

@end
