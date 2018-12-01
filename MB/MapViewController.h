//
//  MapViewController.h
//  Practice3
//
//  Created by Mike on 9/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

@class ParkingPolygons;
@class ParkingSearchFilters;

@interface MapViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>
{
    ParkingSearchFilters *m_pSearchFilters;
    ParkingPolygons *m_pCurrentPP;
}


//server data
@property (nonatomic,strong) NSMutableArray *jsonArray;
@property (nonatomic,strong) NSMutableArray *parkingArray;
//

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRefreshSearch;

//bottom UIview
@property (weak, nonatomic) IBOutlet UIView *m_uiViewSpotData;
@property (weak, nonatomic) IBOutlet UILabel *m_txtSpotInfo;
//

//map data
@property (weak, nonatomic)   IBOutlet UIView *m_viewSearchInfo;
@property (weak, nonatomic)   IBOutlet UILabel *m_spotInfo;
@property (nonatomic,retain)  IBOutlet MKMapView *mapview;
@property (strong, nonatomic) IBOutlet CLLocationManager *parkinglocationManager;
@property (weak, nonatomic)   IBOutlet UIButton *m_myLocationBtn;

@property (weak,nonatomic) NSURLSessionConfiguration *defaultConfigObject;
@property (weak,nonatomic) NSURLSession *defaultSession;
@property bool m_bRefreshUserLocation;
@property bool m_bWaitingForLocationToRetrieve;
@property NSInteger m_nCurrentSpot;
@property bool m_bWasFromSearchIndex;
@property bool m_bLocationServicesEnabled;
@property NSTimer *m_pTimer;
@property NSTimer *m_pOpenSpotTimer;
@property bool m_bSearching;
@property bool m_bLocationServicesAlert;
@property bool m_bReportDialogUp;
@property NSInteger m_nCallGetOpenSpots;//0 nothing, 1 waiting for async to return, 2, callget

@property NSInteger m_nTotalSpots;

- (IBAction)GetMyLocation:(id)sender;
- (IBAction)onHelpMeterBeaters:(id)sender;
- (IBAction)refreshClicked:(id)sender;


-(void) onViewDidAppear;

//LOGIC HELPERS
-(BOOL) retrieveParkingData;//gets data from our database
-(void) setParkingFiltersPointer : (ParkingSearchFilters *) pParkFilters;
-(void) setSelectedParkingSpot : (ParkingPolygons*) pSpot;
-(void) setLastIndex : (bool) bFromSearch;
-(void) updateTopViewSearchInfoBox;
-(void) drawOpenSpotInfo : (NSString *) spot : (ParkingPolygons*) pParkInfo;
-(void) recalcTotalSpots;

@end
