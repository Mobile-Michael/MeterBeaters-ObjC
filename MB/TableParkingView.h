//
//  TableParkingView.h
//  Practice3
//
//  Created by Mike on 11/19/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapViewController;

@interface TableParkingView : UITableViewController
{
    NSMutableArray *m_pParkingArray;
    NSInteger m_nCurrentSelectedSpot;
    MapViewController *m_pMapViewPtr;
}

@property BOOL m_bReloadTable;
- (void) setParkingArray : (NSMutableArray *)pParkingArrayAnd : (NSInteger) nSpot : (BOOL) bReloadTable;
- (void) setMapViewController : (MapViewController*)pMap;
//intra gui code
@end
