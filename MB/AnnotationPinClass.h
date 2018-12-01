//
//  AnnotationPinClass.h
//  Practice3
//
//  Created by Mike on 9/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface AnnotationPinClass : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subTitle;
    
    NSInteger m_nOpenSpots;
    NSInteger m_nDBID;
}

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy)   NSString *title;
@property (nonatomic,copy)   NSString *subTitle;
@property (nonatomic,assign) NSInteger  m_nOpenSpots;
@property (nonatomic,assign) NSInteger  m_nDBID;

-(BOOL) isOpenSpotPin;

@end
