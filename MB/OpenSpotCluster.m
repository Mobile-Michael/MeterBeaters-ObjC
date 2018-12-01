//
//  OpenSpotCluster.m
//  MeterBeaters
//
//  Created by Mike on 1/28/15.
//  Copyright (c) 2015 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSpotCluster.h"

@implementation OpenSpotClusterRenderer

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    
    if([[[self overlay] title] isEqualToString:@"Outside"])
    {
        return;
    }
    
    UIGraphicsPushContext(context);
    CGContextSaveGState(context);
    [[UIColor blueColor] set];
    
    CGFloat fTextSize = (5.0f * MKRoadWidthAtZoomScale(zoomScale));
    CGFloat fMinTextSize = MIN( fTextSize, 200.0f);
    NSDictionary *fontAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize: fMinTextSize]};
    
    CGSize size = [[[self overlay] title] sizeWithAttributes:fontAttributes];
    CGFloat height = ceilf(size.height);
    CGFloat width  = ceilf(size.width);
    
    CGRect circleRect = [self rectForMapRect:[self.overlay boundingMapRect]];
    CGPoint center = CGPointMake(circleRect.origin.x + circleRect.size.width /2, circleRect.origin.y + circleRect.size.height /2);
    CGPoint textstart = CGPointMake(center.x - width/2, center.y - height /2 );
    
    //zoom scale  I htink is 0.0 to 1.0 , 1.0 being zoomed in
    //LogBeater(@"zoomscale: %f textSize: %f MinTextSize: %f", zoomScale, fTextSize, fMinTextSize);
    
    [[[self overlay] title] drawAtPoint:textstart withAttributes:fontAttributes];
    
    CGContextRestoreGState(context);
    UIGraphicsPopContext();
}

@end
