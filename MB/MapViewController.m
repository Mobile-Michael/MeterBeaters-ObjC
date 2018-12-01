//
//  MapViewController.m
//  Practice3
//
//  Created by Mike on 9/21/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "MapViewController.h"
#import "AnnotationPinClass.h"
#import "ParkingPolygons.h"
#import "TableParkingView.h"
#import "UIGlobals.h"
#import "LoginPage.h"
#import "AppDelegate.h"
#import "OpenSpotCluster.h"
#import "Toast.h"
#import "meterbeater.pch"
#import "ParkTimeInfo.h"
#import "ParkingSearchFilters.h"
#import "font_changer.h"
//define USE_CUSTOM_OVERLAY 0

#define dbStartTime @"StartTime"
#define dbEndTime @"EndTime"
#define dbCenterLong @"Longitude"
#define dbCenterLat @"Latitude"
#define dbDistance @"Distance"
#define dbDay @"Day"

//for when you click the open spots button and want to immediately reflect the gui
#define NO_WAIT 0
#define WAITING_FOR_ASYNC_RETURN 1
#define REQUEST_OPEN_SPOTS 2
#define USE_IMAGE_OF_OPEN_SPOTS 1

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize m_spotInfo,m_viewSearchInfo;
@synthesize mapview,parkinglocationManager;
@synthesize jsonArray,parkingArray;
@synthesize m_bRefreshUserLocation;
@synthesize m_bWaitingForLocationToRetrieve;
@synthesize m_nCurrentSpot, m_txtSpotInfo;
@synthesize m_myLocationBtn;
@synthesize m_bLocationServicesEnabled;
@synthesize m_bWasFromSearchIndex;
@synthesize m_bReportDialogUp;
@synthesize m_bSearching,m_activityIndicator,m_pTimer,defaultConfigObject,defaultSession,m_bLocationServicesAlert;
@synthesize m_pOpenSpotTimer,m_nCallGetOpenSpots;

- (CGFloat) convertMilesToDegrees: (CGFloat) fMiles
{
    return fMiles/69.0f;
}

- (BOOL) removeLocationPin
{
    BOOL bResult=FALSE;
    for(MKAnnotationView *pPin in mapview.annotations)
    {
        if (![pPin isKindOfClass:[MKPointAnnotation class]])
        {
            continue;
        }
        
        MKPointAnnotation *pSpot = (MKPointAnnotation*)pPin;
        [mapview removeAnnotation:pSpot];
        bResult= TRUE;
    }
    
    return bResult;
}

- (BOOL) removeParkingSpots : (BOOL) bDeleteOpenSpots
{
    BOOL bResult=FALSE;
    for(MKAnnotationView *pPin in mapview.annotations)
    {
        if (![pPin isKindOfClass: [AnnotationPinClass class]])
        {
            continue;
        }
        
        AnnotationPinClass *pOurPin = (AnnotationPinClass*)pPin;
        if (!bDeleteOpenSpots)
        {
            if ([pOurPin isOpenSpotPin])//this is an open spot pin
            {
                continue;
            }
            
            if (!pOurPin.title || [pOurPin.title hasPrefix:@"$"])
            {
                [mapview removeAnnotation : pOurPin];
                bResult= TRUE;
            }
        }
        else
        {
            if (!pOurPin.title || [pOurPin.title hasPrefix:@"$"])
            {
                [mapview removeAnnotation : pOurPin];
                bResult= TRUE;
            }
        }
    }
    
    return bResult;
}

- (void) zoomToPermitStartingPoNSInteger : (NSInteger) nZone
{
    MKCoordinateRegion region= {{0.0,0.0},{0.0,0.0}};
    
    NSString *pZone = [[NSString alloc] initWithFormat:@"%ld",(long)nZone];
    LoginPage *pView = [[self.tabBarController viewControllers] objectAtIndex:LOGIN_INDEX];
    NSMutableDictionary *pDict = [pView zones];
    CLLocation *pLocation = [pDict objectForKey:pZone];
    
    if (pLocation)
    {
        region.center.latitude=pLocation.coordinate.latitude;
        region.center.longitude=pLocation.coordinate.longitude;
    }
    else
    {
        if (pDict.count)
        {
            NSString *msg = [[NSString alloc]initWithFormat:@"No Zone %@ or not yet supported",pZone];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss OK button" ) style:UIAlertActionStyleCancel handler:nil];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Error" message: msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction: cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        region.center.latitude=41.91411;
        region.center.longitude = -87.637492;
    }
    
    CGFloat fResult = [self convertMilesToDegrees: 2.0f];
    region.span.latitudeDelta  = fResult;
    region.span.longitudeDelta = fResult;
    [self.mapview setRegion:region animated:YES];
}

- (void) zoomToDestination : (BOOL) dropPinOnDestination : (BOOL) useMyLocation
{
    MKCoordinateRegion region= {{0.0,0.0},{0.0,0.0}};
    
    if (!useMyLocation)
    {
        region.center.latitude  = [m_pSearchFilters getBaseCoordinate].latitude;
        region.center.longitude = [m_pSearchFilters getBaseCoordinate].longitude;
    }
    else
    {
        region.center.latitude  = [m_pSearchFilters getMyLocationCoordinate].latitude;
        region.center.longitude = [m_pSearchFilters getMyLocationCoordinate].longitude;
    }
    
    CGFloat fResult=[self convertMilesToDegrees:[m_pSearchFilters getMilesToQuery]];
    //LogBeater(@"long: %.5f lat: %.5f miles to query %.3f in degrees",region.center.longitude,region.center.latitude,fResult);
    region.span.latitudeDelta =fResult;
    region.span.longitudeDelta=fResult;
    [self.mapview setRegion:region animated:YES];
    
    if (dropPinOnDestination)
    {
        [self dropLocationPin : region.center];
    }
}

- (void) dropLocationPin : (CLLocationCoordinate2D) point
{
    MKPointAnnotation *pPinTest = [[MKPointAnnotation alloc] init];
    [pPinTest setCoordinate: point];
    [self.mapview addAnnotation: pPinTest];
}

- (void) locationUpdate
{
    if ([m_pSearchFilters getParkType] == FREE ||
       [m_pSearchFilters getParkType] == METER)
    {
        //remove the destination only poin
        [self removeLocationPin];
        
        //center on location
        [self zoomToDestination : YES : NO];
    }
}

- (void) goToMyLocation
{
    [self zoomToDestination:NO :YES];
    self.m_bRefreshUserLocation = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [parkinglocationManager stopUpdatingLocation];
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    
    [self onViewDidAppear];
}

- (void)handleSpotInfoViewClick :(UITapGestureRecognizer *)gestureRecognizer
{
    if ( [self.m_viewSearchInfo isEqual: gestureRecognizer.view])
    {
        [self transitionToNewPage: SEARCH_INDEX];
    }
}

- (void) onViewDidLoad
{
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
    self.view.backgroundColor = [UIColor blackColor];
    self.m_bWaitingForLocationToRetrieve = true;
    self.parkinglocationManager.delegate = self;
    self.mapview.delegate = self;
    self.m_nTotalSpots = 0;
    
    m_viewSearchInfo.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: .6f];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.25; //
    [self.mapview addGestureRecognizer:lpgr];
    
    UITapGestureRecognizer *touchOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSpotInfoViewClick:)];
    [touchOnView setNumberOfTapsRequired:1];
    [self.m_viewSearchInfo addGestureRecognizer : touchOnView];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedScreen:)];
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight);
    
    [self.m_uiViewSpotData addGestureRecognizer:swipeGesture];
    
    // Set required taps and number of touches
    [touchOnView setNumberOfTapsRequired : 1];
    [touchOnView setNumberOfTouchesRequired : 1];
    
    // Add the gesture to the view
    [self.m_viewSearchInfo addGestureRecognizer:touchOnView];
    
    [self.navigationController.navigationBar.backItem setHidesBackButton:YES animated:YES];
    self->m_pSearchFilters = [UIGlobals getSearchFilters];
    self.m_bLocationServicesEnabled = true;
    self.m_bRefreshUserLocation = false;
    self.m_bSearching = NO;
    self.parkinglocationManager = [[CLLocationManager alloc]init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self.parkinglocationManager requestWhenInUseAuthorization];
        [self.parkinglocationManager startMonitoringSignificantLocationChanges];
    }
    
    self.m_nCurrentSpot = -1;
    self.m_bLocationServicesAlert = false;
    self->m_pCurrentPP = nil;
    
    self.defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.defaultSession = [NSURLSession sharedSession];
    
    m_pTimer=[NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(searching) userInfo:nil repeats:YES];
    
    m_pOpenSpotTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(checkOpenSpot) userInfo:nil repeats:YES];
    
    
    UIImage *pLocationImage = [UIImage imageNamed:@"myLocColor2@2x.png"];
    [self.m_myLocationBtn setImage:pLocationImage forState:UIControlStateNormal];
    [self.m_myLocationBtn setImage:pLocationImage forState:UIControlStateSelected];
    
    parkinglocationManager.distanceFilter = kCLDistanceFilterNone;
    parkinglocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [mapview setMapType : MKMapTypeStandard];
    [mapview setZoomEnabled : YES];
    [mapview setScrollEnabled : YES];
}

- (void) checkOpenSpot
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ( [app m_bRedrawAnnotations])
    {
        app.m_bRedrawAnnotations = false;
        [self.mapview  removeOverlays:self.mapview.overlays];
        [self removeParkingSpots: TRUE];
        [self drawAllPolylines];
        if ( m_pCurrentPP)
        {
            [self drawBottomUIView];
        }
    }
    else
    {
    }
}

- (void) swipedScreen : (UISwipeGestureRecognizer*)gesture
{
    [self handleSpotClicked: nil : NO : TRUE];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapview];
    CLLocationCoordinate2D touch =
    [self.mapview convertPoint : touchPoint toCoordinateFromView: self.mapview];
    
    CLLocationDistance bestDistance = 10000;
    ParkingPolygons *pBestSpot = nil;
    
    for(ParkingPolygons *pSpot in parkingArray)
    {
        CLLocation *begin = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)touch.latitude longitude:(CLLocationDegrees)touch.longitude];
        
        CLLocationDistance metersToMiddle = [begin distanceFromLocation : [pSpot getMidPointAsCLLocation]];
        CLLocationDistance metersToEnd    = [begin distanceFromLocation : [pSpot getBeginPointAsCLLocation]];
        CLLocationDistance metersToBegin  = [begin distanceFromLocation : [pSpot getEndPointAsCLLocation]];
        CLLocationDistance  bestDist;
        bestDist = metersToMiddle < metersToEnd ? metersToMiddle : metersToEnd;
        bestDist = metersToBegin < bestDist ? metersToBegin : bestDist;
        
        if ( bestDist < bestDistance)
        {
            pBestSpot = pSpot;
            bestDistance = bestDist;
        }
    }
    
    if ( pBestSpot)
    {
        [self handleSpotClicked: pBestSpot : NO : NO];
    }
}

- (void) updateTitleBar : (NSString *) pMapTitle
{
    self.tabBarController.title = pMapTitle;
    self.title = pMapTitle;
}

- (void) onViewDidAppear
{
    if (m_pSearchFilters.m_bParkingQueryChanged || [m_pSearchFilters useMyLocation])
    {
        [self removeParkingSpots : TRUE];
    }
    
    self.m_bReportDialogUp = false;
    self.mapview.showsUserLocation = YES;
    
    self.tabBarController.delegate = self;
    [self.navigationController.navigationBar.backItem setHidesBackButton:YES animated:YES];
    
    const MAP_PARK_TYPE nType = [m_pSearchFilters getParkType];
    if ( nType == FREE)
    {
        [self updateTitleBar: @"Free Map"];
        if (![m_pSearchFilters useMyLocation])
        {
            [self locationUpdate];
        }
    }
    else if ( nType == PERMIT)
    {
        [self updateTitleBar: @"Permit Map"];
        [self zoomToPermitStartingPoNSInteger :[m_pSearchFilters getZone]];
        [self removeParkingSpots : TRUE];
        [self removeLocationPin];
    }
    else if (nType == METER)
    {
        [self updateTitleBar: @"Meter Map"];
        if (![m_pSearchFilters useMyLocation])
        {
            [self locationUpdate];
        }
    }
    else if (nType == STREET_CLEANING)
    {
        return;
    }
    else
    {
        LogBeater(@"This should not be hit current type is: %u", nType);
    }
    
    if (m_pSearchFilters.m_bParkingQueryChanged || [m_pSearchFilters useMyLocation])
    {
        CLLocationCoordinate2D spotCoords;
        if ([m_pSearchFilters useMyLocation])
        {
            spotCoords = m_pSearchFilters.m_clMyLocationCoordinate;
            m_pSearchFilters.m_clMyLocationCoordinate = m_pSearchFilters.m_clMyLocationCoordinate;
            [self.parkinglocationManager startUpdatingLocation];
        }
        else
        {
            spotCoords = m_pSearchFilters.m_clCoordinate;
        }
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:(CLLocationDegrees)spotCoords.latitude longitude:(CLLocationDegrees)spotCoords.longitude];
        [self geocodeLocation : location];
        self.m_nCurrentSpot = -1;
        [self.mapview  removeOverlays:self.mapview.overlays];
        
        if (![m_pSearchFilters useMyLocation]      ||
           !self.m_bWaitingForLocationToRetrieve  ||
           nType == PERMIT)
        {
            bool bSuccess = [self retrieveParkingData];
            if (!bSuccess)
            {
                //mpmfind do something here, possibly add ENUMS for error cases
                //mpmfind how cna we check to see if the internet is connected before the user
                //does anything
            }
        }
    }
    else if ( m_pCurrentPP)
    {
        [self handleSpotClicked: m_pCurrentPP : YES : YES];
    }
    
    [UIGlobals getSearchFilters].m_bParkingQueryChanged = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeActiveAgain)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self onViewDidLoad];
}

- (void) onDidBecomeActiveAgain
{
    if ( [UIGlobals getSearchFilters].m_bParkingQueryChanged)
    {
        [[UIGlobals getSearchFilters] initMembers];
        [self onViewDidAppear];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.mapview.showsUserLocation = YES;
    [parkinglocationManager stopUpdatingLocation];
    
    m_pSearchFilters.m_clMyLocationCoordinate = self.parkinglocationManager.location.coordinate;
    if ([m_pSearchFilters useMyLocation])
    {
        m_pSearchFilters.m_clCoordinate = m_pSearchFilters.m_clMyLocationCoordinate;
    }
    
    if ([m_pSearchFilters getParkType] != PERMIT)
    {
        if ([m_pSearchFilters useMyLocation] && self.m_bWaitingForLocationToRetrieve)
        {
            m_bWasFromSearchIndex = false;
            [m_pSearchFilters setBaseCoordinate:self.parkinglocationManager.location.coordinate];
            if ([self retrieveParkingData])
            {
                //mpmfind do something here, possibly add ENUMS for error cases
                //mpmfind how cna we check to see if the internet is connected before the user
                //does anything
            }
            
            if (!self.m_bRefreshUserLocation)
            {
                [self locationUpdate];
            }
        }
    }
    
    self.m_bWaitingForLocationToRetrieve = false;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [parkinglocationManager stopUpdatingLocation];
    m_pSearchFilters.m_clMyLocationCoordinate = self.parkinglocationManager.location.coordinate;
    //LogBeater(@"Long is %.5f lat is %.5f",self.parkinglocationManager.location.coordinate.longitude,self.parkinglocationManager.location.coordinate.latitude);
    self.m_bLocationServicesEnabled = true;
    if ([m_pSearchFilters getParkType] != PERMIT)
    {
        if ([m_pSearchFilters useMyLocation] && m_bWasFromSearchIndex)
        {
            m_bWasFromSearchIndex = false;
            [m_pSearchFilters setBaseCoordinate:self.parkinglocationManager.location.coordinate];
            if (self.m_bWaitingForLocationToRetrieve)
            {
                self.m_bWaitingForLocationToRetrieve = false;
                if ([self retrieveParkingData])
                {
                    //mpmfind do something here, possibly add ENUMS for error cases
                    //mpmfind how cna we check to see if the internet is connected before the user
                    //does anything
                }
            }
            
            if (!self.m_bRefreshUserLocation)
            {
                [self locationUpdate];
            }
        }
        
        if (self.m_bRefreshUserLocation)
        {
            [self goToMyLocation];
        }
        // else
        // [self locationUpdate];
    }
    else
    {
        [self locationUpdate];
    }
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied)
    {
        static BOOL bOnce = false;
        if (!bOnce || [m_pSearchFilters useMyLocation])
        {
            m_bLocationServicesEnabled = false;
            NSString *msg = @"Location Services Disabled! You will not be able to use your location. Use actual addresses to access the parking data.";
            
            UIAlertAction *dismissaction   = [UIAlertAction
                                              actionWithTitle: NSLocalizedString( @"OK", @"OK button" )
                                              style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *action)
                                              {
                                                  
                                              }];
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Error" message: msg preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction: dismissaction];
            [self presentViewController:alertController animated:YES completion:nil];
            
            m_bLocationServicesAlert = true;
            bOnce = true;
        }
    }
    else
    {
        NSString *msg = @"Error obtaining location";
        UIAlertAction *dismissaction   = [UIAlertAction
                                          actionWithTitle: NSLocalizedString( @"OK", @"OK button" )
                                          style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *action)
                                          {
                                              
                                          }];
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Error" message: msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction: dismissaction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void) setParkingFiltersPointer : (ParkingSearchFilters *) pParkFilters
{
    m_pSearchFilters = pParkFilters;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    CGFloat R = 0.0f;
    CGFloat G = 139/255.0f;
    CGFloat B = 69/255.0f;
    UIColor *uiDarkGreen =[UIColor colorWithRed:R green:G blue:B alpha:1.0f];
    //UIColor *uiDarkGreen =[UIGlobals getMainBackgroundColor];
    
    MKOverlayRenderer *pRenderer = nil;
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon : overlay];
        renderer.fillColor = uiDarkGreen;
        
        pRenderer = renderer;
    }
    else if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircle* circle = overlay;
        OpenSpotClusterRenderer *renderer = [[OpenSpotClusterRenderer alloc] initWithCircle:circle];
        if ([circle.title compare: @"Outside"] != NSOrderedSame)
        {
            //renderer.fillColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50];
            UIColor *uiDG =[UIColor colorWithRed:R green:G blue:B alpha:1.0f];
            renderer.fillColor = uiDG;
            renderer.strokeColor = uiDG;
        }
        else
        {
            //renderer.fillColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.25];
            UIColor *uiDG =[UIColor colorWithRed:R green:G blue:B alpha:.25f];
            renderer.fillColor = uiDG;
            renderer.strokeColor = [UIColor whiteColor];
        }
        
        renderer.lineWidth = 2.0;
        
        pRenderer = renderer;
    }
    else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline : overlay];
        
        renderer.fillColor = uiDarkGreen;
        renderer.lineWidth = 2.5f;
        renderer.strokeColor = uiDarkGreen;
        pRenderer = renderer;
    }
    else if ([overlay isKindOfClass:[MKGeodesicPolyline class]])
    {
        MKPolylineRenderer *renderer=[[MKPolylineRenderer alloc] initWithPolyline : overlay];
        
        renderer.fillColor = uiDarkGreen;
        renderer.lineWidth = 2.5f;
        renderer.strokeColor = uiDarkGreen;
        pRenderer = renderer;
    }
    
    return pRenderer;
}


- (void) logQueryDataOnServer __deprecated //implement this if youd like
{
#ifndef UNDEPRECATED
    return;
#endif
    

    return;
    //first log the data on the server for what query we wanted
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    // POST parameters
    NSURL *url = nil;
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    
    CGFloat fLat=0.0f;
    CGFloat fLong=0.0f;
    if ([m_pSearchFilters useMyLocation])
    {
        fLat  = [m_pSearchFilters getMyLocationCoordinate].latitude;
        fLong = [m_pSearchFilters getMyLocationCoordinate].longitude;
    }
    else
    {
        fLat  = [m_pSearchFilters getBaseCoordinate].latitude;
        fLong = [m_pSearchFilters getBaseCoordinate].longitude;
    }
    
    CGFloat fDistance      = [self convertMilesToDegrees:[m_pSearchFilters getMilesToQuery]];
    NSInteger nDay       = [[m_pSearchFilters getParkTimeBegin] getDay];//mpmfind
    NSInteger nStartTime = [[m_pSearchFilters getParkTimeBegin] getDatabaseFormatted];
    NSInteger nEndTime   = [[m_pSearchFilters getParkTimeEnd] getDatabaseFormatted];
    NSString *pEmail     = [UIGlobals getEmail];
    NSString *newID      = [LoginPage uuid];
    NSString *params = [NSString stringWithFormat:@"log=1&device_id=%@&email=%@&start_time=%ld&end_time=%ld&longitude=%.8f&latitude=%.8f&day=%ld&distance=%.4f&parkType=%d&zone=%ld&newID=%@", uniqueIdentifier,pEmail,(long)nStartTime,(long)nEndTime,fLong,fLat,(long)nDay,fDistance,[m_pSearchFilters getParkType],(long)[m_pSearchFilters getZone],newID];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {                                      //no handling needed, jsut posting blindly
                                     }];
    
    if (dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"datatask is nil");
    }
    
    return;
}

- (BOOL) handleJsonArray : (NSError*)errorCatch
{
    self.m_bSearching=NO;
    if (self.parkingArray)
    {
        [self.parkingArray removeAllObjects];
    }
    
    if (!jsonArray)
    {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           NSString *pTitle = @"Park Info";
                           [[self.tabBarController.tabBar.items objectAtIndex : TABLE_VIEW_INDEX] setTitle : pTitle];
                       });
        
        return false;
    }
    
    bool bCubsHomeGame = false;
    
    //LogBeater(@"the parking array is size %ld",(long)jsonArray.count);
    parkingArray = [[NSMutableArray alloc]init];
    CLLocation *destinationLocation = nil;
    if (m_pSearchFilters.useMyLocation)
    {
        destinationLocation = [[CLLocation alloc]initWithLatitude : m_pSearchFilters.m_clMyLocationCoordinate.latitude longitude : [m_pSearchFilters getMyLocationCoordinate].longitude];
    }
    else
    {
        destinationLocation = [[CLLocation alloc]initWithLatitude :[m_pSearchFilters getBaseCoordinate].latitude longitude : [m_pSearchFilters getBaseCoordinate].longitude];
    }
    
    
    for(NSInteger i=0;i<jsonArray.count;i++)
    {
        NSMutableSet *pSet=[[NSMutableSet alloc]init];
        
        // NSString *cID=[[json objectAtIndex:i] objectForKey:@"id"]; mpmfind add id?
        //keys need to be case sensitive
        NSString *cBeginLong=[[jsonArray objectAtIndex:i] objectForKey:@"BeginLong"];
        if (!cBeginLong)
            [pSet addObject: @"BeginLong,"];
        
        NSString *cBeginLat=[[jsonArray objectAtIndex:i] objectForKey:@"BeginLat"];
        if (!cBeginLat)
            [pSet addObject: @"BeginLat,"];
        
        NSString *cEndLong=[[jsonArray objectAtIndex:i] objectForKey:@"EndLong"];
        if (!cEndLong)
            [pSet addObject: @"EndLong,"];
        
        NSString *cEndLat=[[jsonArray objectAtIndex:i] objectForKey:@"EndLat"];
        if (!cEndLat)
            [pSet addObject: @"EndLat,"];
        
        NSString *cStreetName=[[jsonArray objectAtIndex:i] objectForKey:@"StreetName"];
        if (!cStreetName)
            [pSet addObject: @"StreetName,"];
        
        NSString *cStreetNum=[[jsonArray objectAtIndex:i] objectForKey:@"StreetNum"];
        if (!cStreetNum)
            [pSet addObject: @"StreetNum,"];
        
        NSString *cStartTime=[[jsonArray objectAtIndex:i] objectForKey:@"Start"];
        if (!cStartTime)
            [pSet addObject: @"Start,"];
        
        NSString *cStopTime=[[jsonArray objectAtIndex:i] objectForKey:@"End"];
        if (!cStopTime)
            [pSet addObject: @"End,"];
        
        NSString *cParkIns=[[jsonArray objectAtIndex:i] objectForKey:@"ParkInsurance"];//DEVTEST get rid of this shit
        if (!cParkIns)
            [pSet addObject: @"ParkInsurance,"];
        
        NSString *cPermitNum=[[jsonArray objectAtIndex:i] objectForKey:@"PermitNum"];
        if (!cPermitNum)
            [pSet addObject: @"PermitNum,"];
        
        NSString *cSchoolZone=[[jsonArray objectAtIndex:i] objectForKey:@"SchoolZone"];
        if (!cSchoolZone)
            [pSet addObject: @"SchoolZone,"];
        
        NSString *cID=[[jsonArray objectAtIndex:i] objectForKey:@"ID"];
        if (!cID)
            [pSet addObject: @"ID,"];
        
        NSString *cExcTxt=[[jsonArray objectAtIndex:i] objectForKey:@"ExceptionTxt"];
        if (!cExcTxt)
            [pSet addObject: @"ExceptionTxt,"];
        
        NSString *cAreaTxt=[[jsonArray objectAtIndex:i] objectForKey:@"AreaName"];
        if (!cAreaTxt)
            [pSet addObject: @"AreaName,"];
        
        NSString *cStreetDir=[[jsonArray objectAtIndex:i] objectForKey:@"Direction"];
        if (!cStreetDir)
            [pSet addObject: @"Direction,"];
        
        NSString *cParkType=[[jsonArray objectAtIndex:i] objectForKey:@"ParkType"];
        if (!cParkType)
            [pSet addObject: @"ParkType,"];
        
        NSString *cLocID=[[jsonArray objectAtIndex:i] objectForKey:@"locationid"];
        if (!cLocID)
            [pSet addObject: @"locationid,"];
        
        if (!bCubsHomeGame)
        {
            NSString *cSportsRestriction=[[jsonArray objectAtIndex:i] objectForKey:@"SportsRest"];
            if (cSportsRestriction)
            {
                NSInteger nValue = [cSportsRestriction intValue];
                if (nValue > 1)
                    bCubsHomeGame = true;
            }
        }
        
        NSString *cMeterCost=[[jsonArray objectAtIndex:i] objectForKey:@"MeterCost"];
        
        NSInteger nBadKeys=[pSet count];
        if (nBadKeys>0)
        {
            /*NSString *pNewString=[[NSString alloc] init];
             pNewString=@"Bad Keys are: ";
             for(NSString *item in pSet)
             {
             pNewString= [pNewString stringByAppendingString:item];
             }
             
             LogBeater(@"%@",pNewString);
             //UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Bad Keys"message:pNewString delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
             //[pAlert show];
             */
            return false;
        }
        
        ParkingPolygons *myParkingPoly = [[ParkingPolygons alloc] initWithBeginLat:cBeginLat
                                                                       andBeginLon:cBeginLong
                                                                         andEndLat:cEndLat
                                                                        andEndLong:cEndLong
                                                                     andStreetName:cStreetName
                                                                      andStreetNum:cStreetNum
                                                                      andStartTime:cStartTime
                                                                       andStopTime:cStopTime
                                                                        andParkIns:cParkIns
                                                                     andSchoolZone:cSchoolZone
                                                                      andPermitNum:cPermitNum
                                                                       andAreaName:cAreaTxt
                                                                             andID:cID
                                                                  andExceptionText:cExcTxt
                                                                andStreetDirection:cStreetDir
                                                                       andParkType:cParkType
                                                                      andMeterCost:cMeterCost
                                                                     andLocationID:cLocID];
        
        
        double dLat1  = [cBeginLat doubleValue];
        double dLong1 = [cBeginLong doubleValue];
        double dLat2  = [cEndLat doubleValue];
        double dLong2 = [cEndLong doubleValue];
        double dMidpointLat  = (dLat1+dLat2) / 2.0f;
        double dMidpointLong = (dLong1+dLong2) / 2.0f;
        
        //Get distance from the search spot so we can accurately sort
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude: (dMidpointLat) longitude : dMidpointLong ];
        CLLocationDistance distance = [location1 distanceFromLocation : destinationLocation];
        myParkingPoly.distanceFromLocation = distance;
        
        //add to parking polygon array
        [parkingArray addObject : myParkingPoly];
    }
    
    [self reorderParkingArray];
    
    //only do this if you want to display total number of open spots
    //[self recalcTotalSpots];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (!self->jsonArray.count)
                       {
                           if ([self->m_pSearchFilters getParkType] == FREE)
                           {
                               NSString *pMessage = @"No Free Parking. Search same location for meter parking?";
                               UIAlertAction *yesAction   = [UIAlertAction
                                                             actionWithTitle: NSLocalizedString( @"YES", @"Yes button" )
                                                             style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                                             {
                                                                 if ([self->m_pSearchFilters getParkType] == FREE)
                                                                 {
                                                                     if ([self->m_pSearchFilters useMyLocation] && !self.m_bLocationServicesEnabled)
                                                                     {
                                                                         return;
                                                                     }
                                                                     
                                                                     NSString *pMapTitle = @"Meter Map";
                                                                     self.tabBarController.title = pMapTitle;
                                                                     self.title = pMapTitle;
                                                                     [self->m_pSearchFilters SetParkType: METER];
                                                                     [self retrieveParkingData];
                                                                     
                                                                     self.m_bSearching = NO;
                                                                 }
                                                                 
                                                             }];
                               
                               UIAlertAction *noAction     = [UIAlertAction
                                                              actionWithTitle: NSLocalizedString( @"NO", @"No button" )
                                                              style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action)
                                                              {
                                                                  if ([self->m_pSearchFilters getParkType] == FREE)
                                                                  {
                                                                      if ([self->m_pSearchFilters useMyLocation] && !self.m_bLocationServicesEnabled)
                                                                      {
                                                                          return;
                                                                      }
                                                                      
                                                                      self.m_bSearching = NO;
                                                                  }
                                                              }];
                               
                               
                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Parking Alert" message: pMessage preferredStyle:UIAlertControllerStyleAlert];
                               [alertController addAction: yesAction];
                               [alertController addAction: noAction];
                               
                               [self presentViewController:alertController animated:YES completion:nil];
                               
                           }
                           else if ([self->m_pSearchFilters getParkType] == METER)
                           {
                               NSString *pMessage = @"No meter parking found";
                               UIAlertAction *dismissaction   = [UIAlertAction
                                                                 actionWithTitle: NSLocalizedString( @"OK", @"OK button" )
                                                                 style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action)
                                                                 {
                                                                     
                                                                 }];
                               
                               
                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Parking Alert" message: pMessage preferredStyle:UIAlertControllerStyleAlert];
                               [alertController addAction: dismissaction];
                               [self presentViewController:alertController animated:YES completion:nil];
                           }
                           else
                           {
                               
                           }
                       }
                       else
                       {
                           [self drawAllPolylines];
                           ParkingPolygons *pSpot = [self->parkingArray objectAtIndex: 0];
                           [self handleSpotClicked: pSpot : YES : NO];
                           
                           //only do this if you want to show total open spots
                           //[self drawRangeRings: [pSpot getBeginPoint] :self.m_nTotalSpots];
                       }
                   });
    
    
    self.m_bSearching = NO;
    
    return TRUE;
}

- (void) handleSpotClicked : (ParkingPolygons *) pSpot : (BOOL) bZoomToSpot : (BOOL) bForce
{
    if (pSpot != m_pCurrentPP || bForce)
    {
        if (m_pCurrentPP)
        {
            [self removeParkingSpots : FALSE];
        }
        
        m_pCurrentPP = pSpot;
        
        if (pSpot)
        {
            self.m_uiViewSpotData.hidden = NO;
            [self drawParkingPin: pSpot  : bZoomToSpot];
            [self drawBottomUIView];
            
            /*
             CLLocationCoordinate2D spotCoords = m_pSearchFilters.m_clCoordinate;
             CLLocation *location = [[CLLocation alloc]initWithLatitude:(CLLocationDegrees)spotCoords.latitude longitude:(CLLocationDegrees)spotCoords.longitude];
             [self geocodeLocation: location];*/
        }
        else
        {
            self.m_uiViewSpotData.hidden = YES;
        }
    }
}

- (void) drawBottomUIView
{
    //address
    //type
    //distance  .. moving to oen spots
    //cost
    //swipe to remove
    if (m_pCurrentPP)
    {
        NSString *type = [[NSString alloc] init];
        
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSInteger nOpenSpots = [app getSpotsForID: m_pCurrentPP.dataBaseID];
        
        NSString *distance = nil;
        if ( nOpenSpots > 1)
        {
            distance = [[NSString alloc] initWithFormat:@"%ld open spots reported", (long)nOpenSpots ];
        }
        else if ( nOpenSpots == 1)
        {
            distance = @"1 open spot reported";
        }
        else
        {
            distance = @"No open spots reported";
        }
        
        // NSString *distance = [[NSString alloc] initWithFormat:@"Distance: %.2f miles", m_pCurrentPP.distanceFromLocation* 3.28084 / 5280];
        NSString *cost = [[NSString alloc] init];
        
        NSString *address = [[NSString alloc]initWithFormat:@"%@ %@ %@", m_pCurrentPP.streetNum, m_pCurrentPP.streetDirection, m_pCurrentPP.streetName];
        
        if ([m_pSearchFilters getParkType] == FREE)
        {
            cost = @"Cost: it's Free";
            type = [m_pCurrentPP getParkingTypeString];
            m_txtSpotInfo.text = [[NSString alloc] initWithFormat:
                                  @"%@\n%@\n%@\n%@\n(Swipe to remove)", address,
                                  type, distance, cost ];
        }
        else
        {
            
            //[m_txtSpotInfo setFont:<#(UIFont *)#>
            m_txtSpotInfo.text = [[NSString alloc] initWithFormat:
                                  @"%@\n%@\n(Swipe to remove)", address,distance];
        }
    }
}

- (void) drawAllPolylines
{
    //[self recalcTotalSpots];
    for(ParkingPolygons *pParkSpot in parkingArray)
    {
        CLLocationCoordinate2D polyLineCoords[2]=
        {
            [pParkSpot getBeginPoint],
            [pParkSpot getEndPoint]
        };
        
        MKPolyline *pParkingLine = [MKPolyline polylineWithCoordinates:polyLineCoords count:2];
        [self.mapview addOverlay : pParkingLine];
        
        //check for open spot info to draw
        [self drawOpenSpotInfo: [pParkSpot dataBaseID] : pParkSpot];
    }
}

- (void) drawOpenSpotInfo : (NSString *) spot : (ParkingPolygons*) pParkInfo
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSInteger nOpenSpots = [app getSpotsForID: spot];
    if ( nOpenSpots)
    {
        if ( USE_IMAGE_OF_OPEN_SPOTS)
        {
            AnnotationPinClass *myPin = [[AnnotationPinClass alloc] init];
            myPin.coordinate = [pParkInfo getMidPointAsCLLocation].coordinate;
            myPin.subTitle = @"";
            myPin.m_nOpenSpots = nOpenSpots;
            myPin.m_nDBID = [[pParkInfo dataBaseID] integerValue];
            
            [self.mapview addAnnotation:myPin];
        }
        else
        {
            //deprecated for now [self drawSingleRing: [pParkInfo getParkingSpotMidPoint: NO] : nOpenSpots];
        }
    }
}

- (BOOL) retrieveParkingData
{
    [self.mapview  removeOverlays:self.mapview.overlays];
    if ([m_pSearchFilters getParkType] == FREE)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"checkSearches"] ;
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self logQueryDataOnServer];//this is superfilous mpmfind, you can do this with post version
    }
    
    [self getParkingDataPOST];
    
    return TRUE;
}

- (IBAction)RefreshLocation:(id)sender
{
    [self locationUpdate];
}

- (IBAction)GetMyLocation:(id)sender
{
    [parkinglocationManager startUpdatingLocation];//mpmfind this is very expensive
    self.m_bRefreshUserLocation = true;
    [self goToMyLocation];
}

- (NSInteger) getNumDayBetweenEndandBeginDate
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *componentStart=[[NSDateComponents alloc]init];
    componentStart.month = [[m_pSearchFilters getParkTimeBegin] getMonth];
    componentStart.year  = [[m_pSearchFilters getParkTimeBegin] getYear];
    componentStart.day   = [[m_pSearchFilters getParkTimeBegin] getDayOfMonth];
    NSDate *startDate= [cal dateFromComponents:componentStart];
    
    NSDateComponents *componentEnd=[[NSDateComponents alloc]init];
    componentEnd.month = [[m_pSearchFilters getParkTimeEnd] getMonth];
    componentEnd.year  = [[m_pSearchFilters getParkTimeEnd] getYear];
    componentEnd.day   = [[m_pSearchFilters getParkTimeEnd] getDayOfMonth];
    NSDate *endDate = [cal dateFromComponents:componentEnd];
    
    NSInteger flags = NSCalendarUnitDay;
    NSDateComponents *difference = [[NSCalendar currentCalendar] components:flags fromDate:startDate toDate:endDate options:0];
    
    NSInteger numDays = [difference day];
    return numDays;
}

- (void) getParkingDataPOST
{
#warning need to implement your own back end
    return;
    self.m_bSearching = YES;
    
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params=nil;
    if ([m_pSearchFilters getParkType] == FREE)
    {
        CGFloat fLat=0.0f;
        CGFloat fLong=0.0f;
        if ([m_pSearchFilters useMyLocation])
        {
            fLat =[m_pSearchFilters getMyLocationCoordinate].latitude;
            fLong=[m_pSearchFilters getMyLocationCoordinate].longitude;
        }
        else
        {
            fLat =[m_pSearchFilters getBaseCoordinate].latitude;
            fLong=[m_pSearchFilters getBaseCoordinate].longitude;
        }
        
        CGFloat fDistance=[self convertMilesToDegrees:[m_pSearchFilters getMilesToQuery]];
        
        //ActualDates so we can check against the cubs
        NSString *pDateStart = [[m_pSearchFilters getParkTimeBegin] getYYYYMMDD];
        NSInteger nStartDay  = [[m_pSearchFilters getParkTimeBegin] getDay];
        NSInteger nEndDay    = [[m_pSearchFilters getParkTimeEnd] getDay];
        NSInteger nStartTime = [[m_pSearchFilters getParkTimeBegin] getDatabaseFormatted];
        NSInteger nEndTime   = [[m_pSearchFilters getParkTimeEnd] getDatabaseFormatted];
        NSInteger nNumDays   = [self getNumDayBetweenEndandBeginDate];
        NSString *pEmail     =  [UIGlobals getEmail];
        if (!pEmail)
        {
            pEmail = @"not set";
        }
        
        params = [NSString stringWithFormat:@"StartTime=%ld&EndTime=%ld&Longitude=%.8f&Latitude=%.8f&Distance=%.8f&startDay=%li&endDay=%li&numDays=%li&email=%@&YMDstring=%@&parkType=%d&Type=1", (long)nStartTime,(long)nEndTime,fLong,fLat,fDistance,(long)nStartDay,(long)nEndDay,(long)nNumDays,pEmail,pDateStart,
                  [m_pSearchFilters getParkType]];
    }
    else if ([m_pSearchFilters getParkType] == PERMIT)
    {
        params = [NSString stringWithFormat:@"zone=%ld&parkType=%d",(long)[m_pSearchFilters getZone],[m_pSearchFilters getParkType]];
    }
    else
    {
        CGFloat fLat=0.0f;
        CGFloat fLong=0.0f;
        if ([m_pSearchFilters useMyLocation])
        {
            fLat =[m_pSearchFilters getMyLocationCoordinate].latitude;
            fLong=[m_pSearchFilters getMyLocationCoordinate].longitude;
        }
        else
        {
            fLat =[m_pSearchFilters getBaseCoordinate].latitude;
            fLong=[m_pSearchFilters getBaseCoordinate].longitude;
        }
        
        CGFloat fDistance=[self convertMilesToDegrees:[m_pSearchFilters getMilesToQuery]];
        
        params = [NSString stringWithFormat:@"parkType=%d&Longitude=%.8f&Latitude=%.8f&Distance=%.8f",[m_pSearchFilters getParkType],fLong,fLat,fDistance];
    }
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    // NSURLSessionDataTask returns data, response, and error
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                      {
                                          if (error == nil)
                                          {
                                              
                                              // Parse out the JSON data
                                              NSError *jsonError=nil;
                                              self.jsonArray  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                                  error:&jsonError];
                                              
                                              if ([self.jsonArray isKindOfClass:[NSDictionary class]])
                                              {
                                                  NSDictionary *pConverted = (NSDictionary*)self.jsonArray;
                                                  NSString *pTest = [pConverted objectForKey:@"success"];
                                                  if (pTest && [pTest isEqualToString:@"0"])
                                                  {
                                                      //kind of misnomer actually means it failed;
                                                      dispatch_async(dispatch_get_main_queue(), ^
                                                                     {
                                                                         [UIGlobals showOutRangeError : self];
                                                                     });
                                                  }
                                                  
                                                  self.jsonArray = nil;
                                              }
                                              
                                              [self handleJsonArray:jsonError];
                                          }
                                          else
                                          {
                                              LogBeater(@"NSERROR Error is: %@", error);
                                          }
                                          
                                          self.m_bSearching = NO;
                                      }];
    
    if (!dataTask)
    {
        LogBeater(@"datatask is nil");
    }
    else
    {
        [dataTask resume];
    }
}

- (void) updateTopViewSearchInfoBox
{
    [self.m_spotInfo setNumberOfLines: 0];
    self.m_spotInfo.text = [m_pSearchFilters getSpotInfoAsString : nil];
    //LogBeater(@"AddressSpecial: %@", self.m_spotInfo.text);
}

- (void)geocodeLocation:(CLLocation*)location
{
    CLGeocoder *geocoder = nil;
    if (!geocoder)
    {
        geocoder = [[CLGeocoder alloc] init];
    }
    
    [geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray* placemarks, NSError* error)
     {
         if ([placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             NSString *street = [placemark thoroughfare];
             NSString *streetnum = [placemark subThoroughfare];
             if (street && streetnum)
             {
                 [self->m_pSearchFilters setDestString:[NSString stringWithFormat:@"%@ %@", streetnum , street]];
             }
             else
             {
                 
                 NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
                 if ([placemarks count] == 4)
                 {
                     NSString *address = [lines objectAtIndex: 1];
                     [self->m_pSearchFilters setDestString:[NSString stringWithFormat:@"%@", address]];
                 }
                 else
                 {
                     NSString *address = [lines objectAtIndex: 0];
                     [self->m_pSearchFilters setDestString:[NSString stringWithFormat:@"%@", address]];
                 }
             }
             
             [self updateTopViewSearchInfoBox];
         }
     }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([m_pSearchFilters getParkType] == METER)
    {
        return;
    }
    
    if ([view.annotation isKindOfClass:[AnnotationPinClass class]])
    {
        AnnotationPinClass *pMyPin = (AnnotationPinClass*)view.annotation;
        if ( [pMyPin isOpenSpotPin])
        {
            ParkingPolygons *pInstance = nil;
            for(ParkingPolygons* item in parkingArray)
            {
                if ( [item.dataBaseID integerValue] == pMyPin.m_nDBID)
                {
                    [self setSelectedParkingSpot: item];
                    pInstance = item;
                }
            }
            
            if ( pInstance)
            {
                [self handleSpotClicked: pInstance : FALSE : TRUE];
                [self.mapview deselectAnnotation: pMyPin animated:YES];
            }
        }
    }
}

- (void) reorderParkingArray
{
    [parkingArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
     {
         ParkingPolygons *p1 = (ParkingPolygons*)obj1;
         ParkingPolygons *p2 = (ParkingPolygons*)obj2;
         if (p1.distanceFromLocation>p2.distanceFromLocation)
             return NSOrderedDescending;
         else
             return NSOrderedAscending;
     }];
    
    NSInteger nIndex=0;
    bool bFound=false;
    for(ParkingPolygons* item in parkingArray)
    {
        NSInteger nDBID=[item.dataBaseID intValue];
        if (nDBID==self.m_nCurrentSpot)
        {
            bFound=true;
            break;
        }
        
        nIndex++;
    }
    
    if (bFound)
    {
        if (nIndex != 0)//check to see if its already at the smallest index
        {
            id tmp = [self.parkingArray objectAtIndex:nIndex];
            [self.parkingArray removeObjectAtIndex:nIndex];
            [self.parkingArray insertObject:tmp atIndex:0];
        }
        
        m_pCurrentPP = [self.parkingArray objectAtIndex: 0];
    }
}

- (void) transitionToNewPage : (NSInteger) pageIndex
{
    if (pageIndex > 0 && pageIndex < NUM_PAGE_INDEXES)
    {
        [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex : pageIndex]];
        [self.tabBarController setSelectedIndex : pageIndex];
    }
}

- (UIImage*) getOpenSpotImage : (NSInteger) nSpots
{
    if ( nSpots < 0)
    {
        return nil;
    }
    else if (nSpots == 10)
    {
        nSpots = 10;
    }
    else if ( nSpots > 10)
    {
        nSpots = 11;
    }
    else
    {
        //do nothing
    }
    
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0)
    {
        NSString *imageName = [[NSString alloc] initWithFormat:@"OpenSpotBig_%li@2x.png", (long)nSpots];
        UIImage *pImage = [UIImage imageNamed: imageName];
        return pImage;
    }
    else
    {
        NSString *imageName = [[NSString alloc] initWithFormat:@"OpenSpotBig_%li@2x.png", (long)nSpots];
        UIImage *pImage = [UIImage imageNamed: imageName];
        
        CGSize newsize = CGSizeMake(50.0f, 50.0f);
        UIGraphicsBeginImageContext( newsize );
        [pImage drawInRect:CGRectMake(0,0,newsize.width,newsize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[AnnotationPinClass class]])
    {
        AnnotationPinClass *myPinClass = (AnnotationPinClass*)annotation;
        MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: nil];
        
        //if this is true then we have an open marker
        if ([myPinClass isOpenSpotPin])
        {
            UIImage *pImage = [self getOpenSpotImage: myPinClass.m_nOpenSpots];
            if ( pImage)
            {
                annView.canShowCallout = NO;
                [annView setImage: pImage];
            }
        }
        else
        {
            NSString *pTitle=[annotation title];
            UIImage *pImage=[UIImage imageNamed:@"pin-2-30x35@2x.png"];
            
            annView.calloutOffset = CGPointMake(-5,5);
            if ([m_pSearchFilters getParkType] == METER)
            {
                //DEVTEST what is this tomfoolery
                if ([pTitle hasPrefix:@"$"])
                {
                    [annView setImage:pImage];
                }
                
                //annView.animatesDrop = NO;
                annView.canShowCallout = YES;
#define USE_DISCLOSURE_PIN 1
                if (USE_DISCLOSURE_PIN)
                {
                    UIImageView *leftIconView = [[UIImageView alloc] initWithImage:pImage];
                    annView.rightCalloutAccessoryView = leftIconView;
                }
            }
            else
            {
                if (pTitle)
                {
                    //annView.animatesDrop  = YES;
                    annView.canShowCallout= YES;
                }
                else
                {
                    //annView.animatesDrop   = NO;
                    annView.canShowCallout = NO;
                    [annView setImage:pImage];
                }
            }
        }
        
        return annView;
    }
    else if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[MKCircle class]])
    {
        //MKCircle* circle = (MKCircle*)annotation;
    }
    else
    {
        MKPinAnnotationView *annView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        
        annView.animatesDrop = YES;
        annView.canShowCallout = NO;
        return  annView;
    }
    
    return nil;
}

- (void)drawParkingPin : (ParkingPolygons*) pSpot : (BOOL) zoomToLocation
{
    CLLocationCoordinate2D myMid = [pSpot getMidPointAsCLLocation].coordinate;
    
    AnnotationPinClass *myPin = [[AnnotationPinClass alloc] init];
    myPin.coordinate = myMid;
    myPin.subTitle = pSpot.dataBaseID;
    myPin.m_nOpenSpots = -1;
    
    if ([m_pSearchFilters getParkType] == METER)
    {
        CGFloat fMeterPrice = 0.0f;
        if (pSpot.meterCost)
        {
            fMeterPrice = [pSpot.meterCost floatValue];
        }
        
        NSString *pPrice= [[NSString alloc]initWithFormat : @"$%.2f/hr", [pSpot.meterCost floatValue]];
        if (fMeterPrice > 0.0f)
        {
            myPin.title = pPrice;
        }
    }
    
    [self.mapview addAnnotation : myPin];
    
    
    MKCoordinateRegion region = [self.mapview region];
    region.center.latitude  = myMid.latitude;
    region.center.longitude = myMid.longitude;
    
    if (zoomToLocation)
    {
        CGFloat fResult = [self convertMilesToDegrees:[m_pSearchFilters getMilesToQuery]];
        region.span.latitudeDelta = fResult;
        region.span.longitudeDelta= fResult;
        [self.mapview setRegion:region animated: zoomToLocation];
    }
}

/*
 for(ParkingPolygons* item in parkingArray)
 {
 [self drawParkingPin:item : NO];
 }
 */

- (void) setSelectedParkingSpot : (ParkingPolygons*) pSpot
{
    m_pCurrentPP = pSpot;
    self.m_nCurrentSpot = [pSpot.dataBaseID intValue];
}

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:TABLE_VIEW_INDEX])
    {
        [self reorderParkingArray];
        TableParkingView *tableViewController = (TableParkingView*)viewController;
        [tableViewController setParkingArray : parkingArray : self.m_nCurrentSpot : YES];
        [tableViewController setMapViewController : self];
        tableViewController.m_bReloadTable  = YES;
        
        return YES;
    }
    else
    {
        return YES;
    }
}

- (void) sharedInfoToServer : (NSString*) sURL : (NSString*) pHackedInfo : (NSString*) paramInfo
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *pEmail= [[NSString alloc] init];
    if ([pHackedInfo isEqualToString:@""])
    {
        pEmail =  [UIGlobals getEmail];
        if (!pEmail)
        {
            pEmail = @"NOT_SET";
        }
    }
    else
    {
        pEmail = pHackedInfo;
    }
    
    NSURL *url = [NSURL URLWithString: sURL];
    
    NSString *newID = [LoginPage uuid];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    NSString *params = nil;
    if ( paramInfo != nil)
    {
        params = paramInfo;
    }
    else
    {
        params=[NSString stringWithFormat:@"device_id=%@&db_id=%@&start_time=%@&end_time=%@&email=%@&newID=%@", uniqueIdentifier,m_pCurrentPP.dataBaseID,m_pCurrentPP.startTime,m_pCurrentPP.stopTime,pEmail,newID];
    }
    // Create url connection and fire request
    // Start NSURLSession
    if (!defaultConfigObject)
    {
        defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    if (!defaultSession)
    {
        defaultSession = [NSURLSession sharedSession];
    }
    
    // POST parameters
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL: url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                      {
                                          if (self.m_nCallGetOpenSpots == WAITING_FOR_ASYNC_RETURN)
                                          {
                                              //now that it returned, lets go back to the server and get the new open spot
                                              //we could also just blindly update, but nah lets go to the server
                                              self.m_nCallGetOpenSpots = REQUEST_OPEN_SPOTS;
                                          }
                                          // Remove progress window
                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                          NSInteger statusCode = [httpResponse statusCode];
                                          if (error == nil)
                                          {
                                              if (statusCode == 200)
                                              {
                                              }
                                          }
                                          else
                                          {
                                              
                                          }}];
    
    if (dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"data task is nil");
    }
    return;
}



- (void) searching
{
    if (self.m_bSearching)
    {
        [self.m_activityIndicator startAnimating];
    }
    else
    {
        [self.m_activityIndicator stopAnimating];
    }
    
    if ( self.m_nCallGetOpenSpots == REQUEST_OPEN_SPOTS)
    {
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [app getOpenSpotInfo];
        self.m_nCallGetOpenSpots = NO_WAIT;
    }
}

- (void) setLastIndex : (bool) bFromSearch
{
    m_bWasFromSearchIndex = bFromSearch;
}

- (IBAction)onHelpMeterBeaters:(id)sender
{
    m_bReportDialogUp = true;
    [self showReportDialog];
}

- (IBAction)refreshClicked:(id)sender
{
    self.m_nCallGetOpenSpots = REQUEST_OPEN_SPOTS;
    [self removeParkingSpots : TRUE];
    [self removeLocationPin];
    
    CLLocationCoordinate2D center =  mapview.centerCoordinate;
    [m_pSearchFilters setUseMyLocation: NO];
    [m_pSearchFilters setBaseCoordinate : center];
    [self dropLocationPin: center];
    [self retrieveParkingData];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:(CLLocationDegrees)center.latitude longitude:(CLLocationDegrees)center.longitude];
    
    [self geocodeLocation: location];
}

- (void)alertViewClickedAtButtonIndex : (NSInteger)buttonIndex
{
    if (m_bLocationServicesAlert)
    {
        m_bLocationServicesAlert = false;
        return;
    }
    else if (m_bReportDialogUp)
    {
        m_bReportDialogUp = false;
        
#warning implement your own back end
        NSString *pParked    = @"url_is_nil_fill_in_your_own_scripts";
        NSString *pOpenSpots = @"url_is_nil_fill_in_your_own_scripts";
        NSString *pBadData   = @"url_is_nil_fill_in_your_own_scripts";
        switch(buttonIndex)
        {
            case 0://Parked
            {
                if ( m_pCurrentPP)
                {
                    NSString *db_id = [m_pCurrentPP dataBaseID];
                    NSString *params = [[NSString alloc] initWithFormat:@"device_id=%@&db_id=%@&num_spots=%d", [LoginPage uuid], db_id, -1];
                    [self sharedInfoToServer : pOpenSpots : @"PARKED" : params];
                    m_nCallGetOpenSpots = WAITING_FOR_ASYNC_RETURN;
                    [self showToast: @"THANKS!"];
                }
                
                [self sharedInfoToServer : pParked : @"" : nil];
                break;
            }
            case 1://Left Spot
            {
                if ( m_pCurrentPP)
                {
                    NSString *db_id = [m_pCurrentPP dataBaseID];
                    NSString *params = [[NSString alloc] initWithFormat:@"device_id=%@&db_id=%@&num_spots=%d", [LoginPage uuid], db_id, 1];
                    [self sharedInfoToServer : pOpenSpots : @"LEFT SPOT CLICKED" : params];
                    m_nCallGetOpenSpots = WAITING_FOR_ASYNC_RETURN;
                    [self showToast: @"THANKS!"];
                }
                break;
            }
            case 2://Bad Data;
            {
                [self sharedInfoToServer : pBadData : @"" : nil];
                [self showToast: @"THANKS!"];
                break;
            }
            case 3://Report Opne
            {
                if ( m_pCurrentPP)
                {
                    NSString *db_id = [m_pCurrentPP dataBaseID];
                    NSString *params = [[NSString alloc] initWithFormat:@"device_id=%@&db_id=%@&num_spots=%d", [LoginPage uuid], db_id, 1];
                    [self sharedInfoToServer : pOpenSpots : @"" : params];
                    m_nCallGetOpenSpots = WAITING_FOR_ASYNC_RETURN;
                    [self showToast: @"THANKS!"];
                }
                break;
            }
            case 4: //dismiss;
            {
                break;
            }
            default:
                break;
        }
        
        return;
    }
    
}

- (void) showReportDialog
{
    NSString *pTitle = nil;
    NSString *pSubTitle = nil;
    if ( m_pCurrentPP)
    {
        pTitle = [m_pCurrentPP getLocationAddress];
        pSubTitle = [m_pCurrentPP exceptionText];
    }
    else
    {
        pTitle = [m_pSearchFilters getDestString];
        pSubTitle = @"";
    }
    
    
    UIAlertAction *parkedAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Parked", @"Parked Action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self alertViewClickedAtButtonIndex: 0];
                                   }];
    
    UIAlertAction *leftSpotAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Left Spot", @"Left Spot Action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self alertViewClickedAtButtonIndex: 1];
                                     }];
    
    UIAlertAction *badDataAction  = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Bad Data", @"Bad Data Action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self alertViewClickedAtButtonIndex: 2];
                                     }];
    
    UIAlertAction *reportActions  = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Report Open Spots", @"Report Open Spots Action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self alertViewClickedAtButtonIndex: 3];
                                     }];
    
    UIAlertAction *cancelAction   = [UIAlertAction
                                     actionWithTitle: NSLocalizedString( @"Dismiss", @"Dismiss OK button" )
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self alertViewClickedAtButtonIndex: 4];
                                     }];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: pTitle message: pSubTitle preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction: parkedAction];
    [alertController addAction: leftSpotAction];
    [alertController addAction: badDataAction];
    [alertController addAction: reportActions];
    [alertController addAction: cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//not currently being used, using an image for the annotatin pin
- (void)drawSingleRing: (CLLocationCoordinate2D) center : (NSInteger) nSpots
{
    CGFloat range = 25.0f;
    MKCircle* outerCircle = [MKCircle circleWithCenterCoordinate: center radius: range];
    outerCircle.title = @"Outside";
    MKCircle* innerCircle = [MKCircle circleWithCenterCoordinate: center radius: (range / 1.50f)];
    innerCircle.title = [[NSString alloc] initWithFormat:@"%ld", (long)nSpots];
    
    [mapview addOverlay: outerCircle];
    [mapview addOverlay: innerCircle];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //LogBeater(@"Span is %f, %f", self.mapview.region.span.latitudeDelta, self.mapview.region.span.longitudeDelta);
}

- (void) recalcTotalSpots
{
    self.m_nTotalSpots = 0;
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    for(ParkingPolygons *pSpot in parkingArray)
    {
        NSInteger nOpenSpots = [app getSpotsForID: pSpot.dataBaseID];
        self.m_nTotalSpots += nOpenSpots;
    }
    
    //LogBeater(@"Total Spots calculated = %ld", (long)self.m_nTotalSpots);
}

- (void) showToast : (NSString *) pToastMessage
{
    [ToastView showToastInParentView : self.view withText: pToastMessage withDuaration: 3.0f];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        if ( m_pCurrentPP)
        {
            [self showReportDialog];
        }
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
