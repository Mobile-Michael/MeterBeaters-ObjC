//
//  AnnotationPinClass.m
//  Practice3
//
//  Created by Mike on 9/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "AnnotationPinClass.h"
#import <MapKit/MapKit.h>
@implementation AnnotationPinClass

@synthesize title,subTitle,coordinate,m_nOpenSpots,m_nDBID;
-(BOOL) isOpenSpotPin
{
    return m_nOpenSpots >= 0;
}

@end
