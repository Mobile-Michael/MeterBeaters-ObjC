//
//  ParkingInputController.m
//  Practice3
//
//  Created by Mike on 1/21/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "ParkingInputController.h"
#import "MapViewController.h"
#import "UIGlobals.h"
#import "LoginPage.h"
#import "TableParkingView.h"
#import "Toast.h"
#import "meterbeater.pch"
#import "KeyboardStateListener.h"
#import "ParkTimeInfo.h"
#import "ParkingSearchFilters.h"
#import "font_changer.h"

#define TWELVE_HOURS 60*60*12
@interface ParkingInputController ()

@end

@implementation ParkingInputController
@synthesize m_datePickerStart;
@synthesize m_datePickerEndTime;
@synthesize m_bEndDatePickerShowing;
@synthesize m_bStartDatePickerShowing;
@synthesize m_lbStartTime;
@synthesize m_lbEndTime;
@synthesize m_switchUseMyLocation;
@synthesize m_btnFindParking;
@synthesize m_distanceSlider;
@synthesize m_lbSearchDistance;
@synthesize m_textFieldLocation;
@synthesize m_bLocationFieldShowing;
@synthesize m_pDateFormatter;
@synthesize m_pTimer;
@synthesize m_activityIndicator,m_bSearchingForLocation,m_bSearchLimitExceeded,m_bFindCalledWithKeyboardUp;
@synthesize m_bTimeConflict;
@synthesize m_pLastSearchLocation;
@synthesize defaultSession,m_bLoggedIn,m_btn24Hr,m_btn2Hr,m_btn4Hr,m_btn8Hr,m_btnSSHelp,m_btnResetWard;
@synthesize m_btn2hrStart,m_btn4hrStart,m_btn8HrStart, m_btn24hrStart;
@synthesize m_btnFreeParking,m_btnMeterParking,m_btnPermitParking,m_zoneLabel,m_startLabel,m_endLabel,m_btnNow,m_distanceLabel,m_UseMyLocationLabel,permitLatitudes,permitLongitudes,geocoder,m_txtStaticDays;
@synthesize m_txtAlertSetFor,m_txtAddressSS,m_viewDays,m_uiBackgroundView,m_infoEditSS;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle : style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void) updateParkTypeColors
{
    MAP_PARK_TYPE nType = [m_pMyFilters getParkType];
    //deactive all and then simply set the active
    [self.m_btnFreeParking setTitleColor: [UIGlobals ourLightGray] forState:UIControlStateNormal];
    [self.m_btnPermitParking setTitleColor: [UIGlobals ourLightGray] forState:UIControlStateNormal];
    [self.m_btnMeterParking setTitleColor: [UIGlobals ourLightGray] forState:UIControlStateNormal];
    [self.m_btnSSHelp setTitleColor: [UIGlobals ourLightGray] forState:UIControlStateNormal];
    
    //set the active one
    switch( nType)
    {
        case FREE:
        {
            [self.m_btnFreeParking setTitleColor: [UIGlobals getMainBackgroundColor] forState:UIControlStateNormal];
            break;
        }
        case PERMIT :
        {
            [self.m_btnPermitParking setTitleColor: [UIGlobals getMainBackgroundColor] forState:UIControlStateNormal];
            break;
        }
        case METER:
        {
            [self.m_btnMeterParking setTitleColor: [UIGlobals getMainBackgroundColor] forState:UIControlStateNormal];
            break;
        }
        case STREET_CLEANING:
        {
            [self.m_btnSSHelp setTitleColor: [UIGlobals getMainBackgroundColor] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
}

-(void) initColorScheme
{
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.tableView setBackgroundColor: [UIColor blackColor]];
    
    //this is use my location switch
    [self.m_switchUseMyLocation setOnTintColor:[UIGlobals getMainBackgroundColor]];
    [self.m_switchUseMyLocation setTintColor:[UIGlobals ourDarkGray]];
    [self.m_btnNow setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    //this is the Distance control
    [self.m_distanceSlider setMinimumTrackTintColor:[UIGlobals getMainBackgroundColor]];
    CGRect currentFrame = self.m_textFieldLocation.frame;
    currentFrame.size.height = 33.0f;
    self.m_textFieldLocation.frame = currentFrame;
    [self updateParkTypeColors];
    
    //ResetWardButton
    [m_btnResetWard setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    //textView
    m_viewDays.backgroundColor = [UIColor clearColor];
    m_uiBackgroundView.backgroundColor = [UIColor clearColor];
}

/*
 -(void) pushLoginPage
 {
 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
 LoginPage *pLoginPage = [storyboard instantiateViewControllerWithIdentifier:@"LoginPage"];
 [pLoginPage setModalPresentationStyle:UIModalPresentationFullScreen];
 [self presentViewController:pLoginPage animated:NO completion:nil];
 }
 keeping this as a helper funciton to lok back on
 */

-(void) viewDidAppear:(BOOL)animated
{
    [self onViewDidAppearHelper];
}

-(void) onViewDidAppearHelper
{
    self.tabBarController.delegate    = self;
    self.tableView.delegate           = self;
    self.m_textFieldLocation.delegate = self;
    self.m_zoneText.delegate          = self;
    
    m_bLocationFieldShowing = !self.m_switchUseMyLocation.isOn;
    [m_pMyFilters reset: self.m_distanceSlider.value];
    self.tabBarController.title = @"Search";
    self.m_distanceSlider.value = [m_pMyFilters getMilesToQuery];
    self.m_lbSearchDistance.text = [NSString stringWithFormat:@"%.2f miles", self.m_distanceSlider.value];
    [self isReadyToQueryPark];
    [m_pMyFilters setUseMyLocation: [self.m_switchUseMyLocation isOn]];
    [self updateGetParkingBtnState];
    
    if( !self.defaultSession)
        self.defaultSession = [NSURLSession sharedSession];
    
    if(!geocoder)
        geocoder = [[CLGeocoder alloc] init];
    
    [self initColorScheme];
    MAP_PARK_TYPE nType = [m_pMyFilters getParkType];
    if(nType == FREE)
        [self onFreeClickedRowHelper];
    else if(nType == METER)
        [self onMeterClickedRowHelper];
    else if(nType == STREET_CLEANING)
        [self onStreetSweepingHelper];
    else
        [self onPermitClickedRowHelper];
    
    [self updateParkTypeColors];
    [self updateRows];
    [self queryCounter : true];
    
    self.m_datePickerStart.date   = [[m_pMyFilters getParkTimeBegin] getNSDate];
    self.m_datePickerEndTime.date = [[m_pMyFilters getParkTimeEnd] getNSDate];
    [self updateTimeText: YES];
    [self updateTimeText: NO];
    
    if(![[m_pMyFilters getDestString] isEqualToString:@""])
        self.m_textFieldLocation.text = [m_pMyFilters getDestString];
}

-(void) removeLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void) onViewDidLoadHelper
{
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
    
    [KeyboardStateListener sharedInstance];
    m_bStartDatePickerShowing        = FALSE;
    m_bEndDatePickerShowing          = FALSE;
    self.m_bSearchingForLocation     = FALSE;
    self.m_bSearchLimitExceeded      = FALSE;
    self.m_bFindCalledWithKeyboardUp = FALSE;
    self.m_bTimeConflict             = FALSE;
    self.m_bLocationFieldShowing     = TRUE;
    self.m_bLoggedIn                 = TRUE;
    self.m_viewDays.editable         = NO;
    self.m_pLastSearchLocation       = nil;
    self.m_activityIndicator.hidesWhenStopped = YES;
    
    m_pMyFilters = [UIGlobals getSearchFilters];
    m_pDateFormatter = [[NSDateFormatter alloc]init];
    
    UIView *pView = [[UIView alloc] init];
    [pView setBackgroundColor: [UIColor blackColor]];
    [pView setTintColor: [UIColor blackColor]];
    self.tableView.tableFooterView = pView;
    self.tableView.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
    m_pTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(searching) userInfo:nil repeats:YES];
    
    self.m_datePickerEndTime.date = [[m_pMyFilters getParkTimeEnd] getNSDate];
    self.m_datePickerStart.date = [[m_pMyFilters getParkTimeBegin] getNSDate];
    
    [self.m_infoEditSS setBackgroundColor:[UIGlobals ourLightGray]];
    
    [self hideStartDatePickerCell];
    [self hideEndDatePickerCell];
    self.m_distanceSlider.value = [m_pMyFilters getMilesToQuery];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self onViewDidLoadHelper];
}

-(void) searching
{
    if(self.m_bSearchingForLocation)
    {
        [self.m_activityIndicator startAnimating];
    }
    else
    {
        [self.m_activityIndicator stopAnimating];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onFreeClickedRowHelper
{
    self.m_textFieldLocation.delegate   = self;
    
    self.m_startLabel.hidden            = NO;
    self.m_endLabel.hidden              = NO;
    self.m_btn24Hr.hidden               = NO;
    self.m_btn2Hr.hidden                = NO;
    self.m_btn4Hr.hidden                = NO;
    self.m_btn8Hr.hidden                = NO;
    self.m_btnNow.hidden                = NO;
    self.m_btn2hrStart.hidden           = NO;
    self.m_btn4hrStart.hidden           = NO;
    self.m_btn8HrStart.hidden           = NO;
    self.m_btn24hrStart.hidden          = NO;
    self.m_lbEndTime.hidden             = NO;
    self.m_lbStartTime.hidden           = NO;
    self.m_distanceSlider.hidden        = NO;
    self.m_lbSearchDistance.hidden      = NO;
    self.m_distanceLabel.hidden         = NO;
    self.m_switchUseMyLocation.hidden   = NO;
    self.m_textFieldLocation.hidden     = NO;
    self.m_UseMyLocationLabel.hidden    = NO;
    self.m_btnFindParking.hidden        = NO;
    
    self.m_viewDays.hidden              = YES;
    self.m_txtAddressSS.hidden          = YES;
    self.m_txtAlertSetFor.hidden        = YES;
    self.m_btnResetWard.hidden          = YES;
    self.m_zoneText.hidden              = YES;
    self.m_zoneLabel.hidden             = YES;
    self.m_txtStaticDays.hidden         = YES;
    self.m_uiBackgroundView.hidden      = YES;
    self.m_infoEditSS.hidden            = YES;
    
    if([self->m_pMyFilters useMyLocation])
    {
        [self hideLocationTextCell];
    }
    else
    {
        if(!self.m_bLocationFieldShowing)
        {
            [self showLocationTextCell];
        }
    }
}

-(void) onMeterClickedRowHelper
{
    self.m_zoneText.hidden            = YES;
    self.m_zoneLabel.hidden           = YES;
    self.m_startLabel.hidden          = YES;
    self.m_endLabel.hidden            = YES;
    self.m_btn24Hr.hidden             = YES;
    self.m_btn2Hr.hidden              = YES;
    self.m_btn4Hr.hidden              = YES;
    self.m_btn8Hr.hidden              = YES;
    self.m_btnNow.hidden              = YES;
    self.m_btn2hrStart.hidden         = YES;
    self.m_btn4hrStart.hidden         = YES;
    self.m_btn8HrStart.hidden         = YES;
    self.m_btn24hrStart.hidden        = YES;
    self.m_lbEndTime.hidden           = YES;
    self.m_lbStartTime.hidden         = YES;
    self.m_btnResetWard.hidden        = YES;
    self.m_viewDays.hidden            = YES;
    self.m_txtAddressSS.hidden        = YES;
    self.m_txtAlertSetFor.hidden      = YES;
    self.m_txtStaticDays.hidden       = YES;
    self.m_uiBackgroundView.hidden    = YES;
    self.m_infoEditSS.hidden          = YES;
    
    self.m_distanceSlider.hidden      = NO;
    self.m_lbSearchDistance.hidden    = NO;
    self.m_distanceLabel.hidden       = NO;
    self.m_switchUseMyLocation.hidden = NO;
    self.m_textFieldLocation.hidden   = NO;
    self.m_UseMyLocationLabel.hidden  = NO;
    self.m_btnFindParking.hidden      = NO;
    
    
    if([self->m_pMyFilters useMyLocation])
        [self hideLocationTextCell];
    else
        [self showLocationTextCell];
    
    [self tryCloseDatePickers];
}

-(void) onPermitClickedRowHelper
{
    self.m_zoneText.hidden                = NO;
    self.m_zoneLabel.hidden               = NO;
    self.m_btnFindParking.hidden          = NO;
    
    self.m_startLabel.hidden              = YES;
    self.m_endLabel.hidden                = YES;
    self.m_btn24Hr.hidden                 = YES;
    self.m_btn2Hr.hidden                  = YES;
    self.m_btn4Hr.hidden                  = YES;
    self.m_btn8Hr.hidden                  = YES;
    self.m_btnNow.hidden                  = YES;
    self.m_btn2hrStart.hidden             = YES;
    self.m_btn4hrStart.hidden             = YES;
    self.m_btn8HrStart.hidden             = YES;
    self.m_btn24hrStart.hidden            = YES;
    self.m_lbEndTime.hidden               = YES;
    self.m_lbStartTime.hidden             = YES;
    self.m_distanceSlider.hidden          = YES;
    self.m_lbSearchDistance.hidden        = YES;
    self.m_distanceLabel.hidden           = YES;
    self.m_switchUseMyLocation.hidden     = YES;
    self.m_textFieldLocation.hidden       = YES;
    self.m_UseMyLocationLabel.hidden      = YES;
    self.m_btnResetWard.hidden            = YES;
    self.m_viewDays.hidden                = YES;
    self.m_txtAddressSS.hidden            = YES;
    self.m_txtAlertSetFor.hidden          = YES;
    self.m_txtStaticDays.hidden           = YES;
    self.m_uiBackgroundView.hidden        = YES;
    self.m_infoEditSS.hidden              = YES;
    
    LoginPage *pView=[[self.tabBarController viewControllers] objectAtIndex:LOGIN_INDEX];
    NSMutableDictionary *pDict = [pView zones];
    if(!pDict.count)
        [pView getPermitZonage];
    
    [self hideLocationTextCell];
    [self tryCloseDatePickers];
}

-(void) onStreetSweepingHelper
{
    self.m_textFieldLocation.delegate = self;
    self.m_zoneText.hidden            = YES;
    self.m_zoneLabel.hidden           = YES;
    self.m_startLabel.hidden          = YES;
    self.m_endLabel.hidden            = YES;
    self.m_btn24Hr.hidden             = YES;
    self.m_btn2Hr.hidden              = YES;
    self.m_btn4Hr.hidden              = YES;
    self.m_btn8Hr.hidden              = YES;
    self.m_btn2hrStart.hidden         = YES;
    self.m_btn4hrStart.hidden         = YES;
    self.m_btn8HrStart.hidden         = YES;
    self.m_btn24hrStart.hidden        = YES;
    self.m_btnNow.hidden              = YES;
    self.m_lbEndTime.hidden           = YES;
    self.m_lbStartTime.hidden         = YES;
    self.m_UseMyLocationLabel.hidden  = YES;
    self.m_switchUseMyLocation.hidden = YES;
    self.m_btnFindParking.hidden      = YES;
    self.m_distanceSlider.hidden      = YES;
    self.m_lbSearchDistance.hidden    = YES;
    self.m_distanceLabel.hidden       = YES;
    
    self.m_btnResetWard.hidden        = NO;
    self.m_viewDays.hidden            = NO;
    self.m_txtAddressSS.hidden        = NO;
    self.m_txtAlertSetFor.hidden      = NO;
    self.m_txtStaticDays.hidden       = NO;
    self.m_uiBackgroundView.hidden    = NO;
    self.m_infoEditSS.hidden          = NO;
    
    if([self->m_pMyFilters useMyLocation]||[self.m_textFieldLocation isHidden])
    {
        [self showLocationTextCell];
    }
    
    self.m_textFieldLocation.hidden   = NO;
    [self tryCloseDatePickers];
    
    NSString *pWard = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_ward"];
    if(!pWard || [pWard integerValue] == -1)
    {
        [self resetStreetSweepInfo];
    }
    else
    {
        NSString *pAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"address_ss"];
        NSString *pDates = [[NSUserDefaults standardUserDefaults] objectForKey:@"dates_ss"];
        NSString *pWardInfo  = [[NSString alloc] initWithFormat:@"%@",pWard];
        [self setZoneAndWardFromResult: pWardInfo : pAddress : pDates];
    }
}

-(void) setZoneAndWardFromResult : (NSString*) pWardInfo : (NSString*) pAddress : (NSString*)pAlertDates
{
    m_txtAddressSS.text = pAddress ? pAddress : @"";
    m_viewDays.text = pAlertDates ? pAlertDates : @"N/A";
}

-(void) tryCloseDatePickers
{
    if(self.m_bEndDatePickerShowing)
    {
        [self hideEndDatePickerCell];
    }
    
    if(self.m_bStartDatePickerShowing)
    {
        [self hideStartDatePickerCell];
    }
}

-(CGFloat) getHeightForPermitParking:(NSInteger)row
{
    if(row == kTypeOfParking)
        return 32.0f;
    else if(row == kTitleBar)
        return 44.0f;
    else if(row == kZoneRow || row == kQueryRow)
        return 44.0f;
    else
        return 0.0f;
}

-(CGFloat) getHeightForMeteredParking:(NSInteger)row
{
    if( row == kUseMyLocationRow||
       row == kDistanceRow     ||
       row == kQueryRow)
    {
        return 44.0f;
    }
    else if( row == kDistancePlaceHolder)
        return 1.0f;
    else if( row == kTypeOfParking)
        return 32.0f;
    else if( row == kTitleBar)
        return  44.0f;
    else if( row == kLocationRow)
    {
        if( self.m_switchUseMyLocation.isOn)
            return 0.0f;
        else
            return 44.0f;
    }
    
    return  0.0f;
}

-(CGFloat) getHeightForFreeParking:(NSInteger)row
{
    CGFloat height = 44.0f;
    if( row == kStartTimeDatePickerRow)
        height = self.m_bStartDatePickerShowing ? kDatePickerHeight : 0.0f;
    else if( row == kEndTimeDatePickerRow)
        height = self.m_bEndDatePickerShowing ? kDatePickerHeight : 0.0f;
    else if( row == kLocationRow)
    {
        height = self.m_bLocationFieldShowing ? kStandardRowHeight : 0.0f;
    }
    else if( row == kDistancePlaceHolder ||
            row == kSpacer1 ||
            row == kSpacer2)
    {
        height = 1.0f;
    }
    /*else if((row == kStartTimeLabelRow ||
     row == kEndTimeLabelRow   ||
     row == kHelperButtons) && nType == METER)//DEVTEST why would this ever happen
     {
     height = 0.0f;
     }*/
    else if( row == kHelperButtons || row == kStartHelperButtons)
        height = 22.0f;
    else if( row == kTypeOfParking)
        height = 32.0f;
    else if( row == kTitleBar)
        height = 44.0f;
    else if( row == kZoneRow)
    {
        height = 0.0f;
        self.m_zoneText.hidden = YES;
        self.m_zoneLabel.hidden = YES;
    }
    else if( row == kSpacer3             ||
            row == kAlertSetForRow      ||
            row == kAddressForSS        ||
            row == kInfoTextForSS       ||
            row == kDaysPlaceHolderText ||
            row == kDaysForSS           ||
            row == kResetWardRow)
    {
        //These are the street sweeping rows
        height = 0.0f;
    }
    
    return height;
}

-(CGFloat) getHeightForStreetCleaningParking:(NSInteger)row
{
    CGFloat height = 44.0f;
    switch( row)
    {
        case kLocationRow:
            height = 48.0f;
            break;
        case kTitleBar:
        case kResetWardRow:
            height = 44.0f;
            break;
        case kAlertSetForRow:
        case kAddressForSS:
        case kDaysPlaceHolderText:
            height = 27.0f;
            break;
        case kTypeOfParking:
            height = 32.0f;
            break;
        case kDaysForSS:
            height = 80.0f;
            break;
        case kInfoTextForSS:
            height = 86.0f;
            break;
        case kSpacer3:
            height = 1.0f;
            break;
        default:
            height = 0.0f;
            break;
    }
    
    return height;
}


#pragma mark - Table view data source
-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    MAP_PARK_TYPE nType = [m_pMyFilters getParkType];
    if( nType == FREE)
        height = [self getHeightForFreeParking: indexPath.row];
    else if( nType == PERMIT)
        height = [self getHeightForPermitParking: indexPath.row];
    else if( nType == METER)
        height = [self getHeightForMeteredParking: indexPath.row];
    else if( nType == STREET_CLEANING)
    {
        height = [self getHeightForStreetCleaningParking: indexPath.row];
    }
    else
    {
        ErrorBeater(@"Unhandled parking type: %u", nType);
    }
    
    //LogBeater(@"Row: %ld Height: %.2f parking type: %d", (long)indexPath.row, height, nType);
    if( height < 0)
    {
        ErrorBeater(@"BAD HEIGHT! Row: %ld Height: %.2f parking type: %d", (long)indexPath.row, height, nType);
        return 44.0f;
    }
    
    return height;
}

-(NSString*) getInfoFromJSONbyKey : (NSDictionary*) dict : (NSString*) key : (NSString*) defaultVal
{
    NSString *value = [[NSString alloc] init];
    value = [dict objectForKey:key];
    if( ![value isKindOfClass:[NSNull class]])
    {
        if(value)
            return value;
        else
            return defaultVal;
    }
    else
        return defaultVal;
}

-(void) tryUpdateWard : (BOOL) bReset __deprecated
{
#warning implement your own back end;
    return;
    
    NSString *pToken=  [[NSUserDefaults standardUserDefaults] valueForKey:@"token_encoded"];
    
    // POST parameters
    NSURL *url = nil;
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params=nil;
    CGFloat fLat=0.0f;
    CGFloat fLong=0.0f;
    fLat  = [m_pMyFilters getBaseCoordinate].latitude;
    fLong = [m_pMyFilters getBaseCoordinate].longitude;
    if(!pToken)
        pToken = @"NOT_SET";
    
    params = [NSString stringWithFormat:@"long=%.8f&lat=%.8f&token=%@&reset=%d",fLong,fLat,pToken,bReset];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         // Remove progress window
                                         if(error == nil)
                                         {
                                             // Parse out the JSON data
                                             NSError *jsonError;
                                             NSDictionary *info;
                                             info  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                       error:&jsonError];
                                             if(info && info.count)
                                             {
                                                 NSString *pWardInfo   = [self getInfoFromJSONbyKey:info :@"ward" :@"-1"];
                                                 NSString *pAlertDates = [self getInfoFromJSONbyKey:info :@"dates" : @"Data From City Not Provided."];
                                                 NSString *pResult     = [self getInfoFromJSONbyKey:info :@"test" : @"-1"];
                                                 
                                                 NSInteger nRetVal = [pWardInfo integerValue];
                                                 NSInteger nTestResult = [pResult integerValue];
                                                 [[NSUserDefaults standardUserDefaults] setInteger:nRetVal forKey: @"current_ward"];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setObject:self->m_textFieldLocation.text forKey: @"address_ss"];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setObject:pAlertDates forKey: @"dates_ss"];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 if(nRetVal != -1)
                                                 {
                                                     NSString *pAlertDates = [[NSString alloc] init];
                                                     pAlertDates = [info objectForKey:@"dates"];
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^
                                                                    {
                                                                        [self setZoneAndWardFromResult : pWardInfo : self->m_textFieldLocation.text : pAlertDates];
                                                                    });
                                                 }
                                                 else
                                                 {
                                                     //4 == reset
                                                     //3 == out of zone
                                                     //2 ==
                                                     NSString *pErrorMsg = nil;
                                                     if(nTestResult == 2)
                                                     {
                                                         pErrorMsg = @"No street sweeping currently scheduled for this ward";
                                                     }
                                                     else if(nTestResult == 3)
                                                     {
                                                         pErrorMsg = @"Search was outside city wards";
                                                     }
                                                     else if(nTestResult == 4)
                                                     {
                                                         //do nothin succesful reeset
                                                     }
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^
                                                                    {
                                                                        if( pErrorMsg)
                                                                        {
                                                                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Ward Info!" message: pErrorMsg preferredStyle:UIAlertControllerStyleAlert];
                                                                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" ) style:UIAlertActionStyleCancel handler:nil];
                                                                            [alertController addAction:cancelAction];
                                                                            [self presentViewController: alertController animated:YES completion:nil];
                                                                        }
                                                                        
                                                                        [self resetStreetSweepInfo];
                                                                    });
                                                 }
                                             }
                                             else
                                             {
                                                 
                                             }
                                         }
                                         else
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^
                                                            {
                                                                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Connection Error!" message: @"Street Sweeping Server Timeout" preferredStyle:UIAlertControllerStyleAlert];
                                                                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" ) style:UIAlertActionStyleCancel handler:nil];
                                                                [alertController addAction:cancelAction];
                                                                [self presentViewController: alertController animated:YES completion:nil];
                                                            });
                                         }
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^
                                                        {
                                                            [self onStreetSweepingHelper];
                                                        });
                                     }];
    
    if(dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"datask is nil");
    }
    return;
}

-(void) resetStreetSweepInfo
{
    m_txtAddressSS.text = @"---";
    m_viewDays.text = @"N/A";
    m_textFieldLocation.text = @"";
}

-(void)handleTextFieldUpdate
{
    NSString *pDestination=[self.m_textFieldLocation.text lowercaseString];
    if([pDestination isEqualToString:[m_pMyFilters getDestString]])
    {
        if(self.m_bFindCalledWithKeyboardUp)
        {
            if([self isReadyToQueryPark])
            {
                [self findparkingCLickedHelper];
            }
            
            self.m_bFindCalledWithKeyboardUp=false;
        }
        return;
    }
    else if([pDestination isEqualToString:@"my location"])
    {
        [self onUseMyLocationChanged:YES];
        [self.m_switchUseMyLocation setOn:YES animated:YES];
    }
    else
    {
        [m_pMyFilters setUseMyLocation:FALSE];
        [m_pMyFilters setString: self.m_textFieldLocation.text];
    }
    
    if(!m_pMyFilters.useMyLocation)
    {
        if([pDestination isEqualToString:@""])
        {
            [m_pMyFilters setParkLocationValid:FALSE];
            [self updateGetParkingBtnState];
            return;
        }
        
        self.m_bSearchingForLocation = YES;
        pDestination = [pDestination stringByAppendingString:@",Chicago, IL"];
        
        [geocoder geocodeAddressString:pDestination completionHandler:^(NSArray *placemarks, NSError *error)
         {
             self.m_bSearchingForLocation = NO;
             if([placemarks count])
             {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 CLLocation *location = placemark.location;
                 if([self->m_pMyFilters getParkType] == STREET_CLEANING)
                 {
                     [self->m_pMyFilters setBaseCoordinate:location.coordinate];
                     [self tryUpdateWard : FALSE];
                 }
                 else
                 {
                     [self->m_pMyFilters setBaseCoordinate:location.coordinate];
                     LogBeater(@"location is %@",location);
                     //[self.mapView setCenterCoordinate:coordinate animated:YES];
                     [self->m_pMyFilters setParkLocationValid:TRUE];
                     self.m_bSearchingForLocation = NO;
                 }
             }
             else
             {
                 NSString *pErrorString=[[NSString alloc]initWithFormat:@"Could not Find Location %@",self.m_textFieldLocation.text];
                 LogBeater(@"Geocoding error: %@", [error localizedDescription]);
                 [self->m_pMyFilters setParkLocationValid:FALSE];
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Location Error!" message: pErrorString preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" ) style:UIAlertActionStyleCancel handler:nil];
                 [alertController addAction:cancelAction];
                 [self presentViewController: alertController animated:YES completion:nil];
             }
             
             if(self.m_bFindCalledWithKeyboardUp)
             {
                 if([self isReadyToQueryPark])
                     [self findparkingCLickedHelper];
                 
                 self.m_bFindCalledWithKeyboardUp=false;
             }
             
             [self updateGetParkingBtnState];
         }];
    }
    
    LogBeater(@"the destination is %@",pDestination);
    [self updateGetParkingBtnState];
}

- (IBAction)textFinishedEditing:(id)sender
{
    [self handleTextFieldUpdate];
}

- (IBAction)distanceSliderChanged:(id)sender
{
    [m_pMyFilters setMilesToQuery: self.m_distanceSlider.value];
    self.m_lbSearchDistance.text = [NSString stringWithFormat:@"%.2f miles",[m_pMyFilters getMilesToQuery]];
}

//mpmfind make this a class
-(void) resetCounter __deprecated
{
    return;
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    // POST parameters
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *newID = [LoginPage uuid];
    NSString *params = [NSString stringWithFormat:@"device_id=%@&admin=1&newID=%@", uniqueIdentifier,newID];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         // Remove progress window
                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                         NSInteger statusCode = [httpResponse statusCode];
                                         if(error == nil)
                                         {
                                             if (statusCode==401)
                                             {
                                                 self.m_bSearchLimitExceeded=true;
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^
                                                                {
                                                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Request Failed" message: @"Admin has been notified, Sorry for this delay" preferredStyle:UIAlertControllerStyleAlert];
                                                                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" ) style:UIAlertActionStyleCancel handler:nil];
                                                                    [alertController addAction:cancelAction];
                                                                    [self presentViewController: alertController animated:YES completion:nil];
                                                                });
                                             }
                                             else if (statusCode == 200)
                                             {
                                                 self.m_bSearchLimitExceeded=false;
                                             }
                                             else
                                             {
                                                 
                                             }
                                         }
                                         else
                                         {
                                             
                                         }
                                     }];
    
    [dataTask resume];
    return;
}

#warning code is duplicated here and in mapviewcontroller
-(void) queryCounter : (bool) bStartUp __deprecated
{
    return;
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    NSString *newID = [LoginPage uuid];
    // POST parameters
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params=nil;
    if(!bStartUp)
    {
        CGFloat fLat=0.0f;
        CGFloat fLong=0.0f;
        if([m_pMyFilters useMyLocation])
        {
            fLat  = [m_pMyFilters getMyLocationCoordinate].latitude;
            fLong = [m_pMyFilters getMyLocationCoordinate].longitude;
        }
        else
        {
            fLat  = [m_pMyFilters getBaseCoordinate].latitude;
            fLong = [m_pMyFilters getBaseCoordinate].longitude;
        }
        
        CGFloat fDistance=[m_pMyFilters getMilesToQuery];
        NSInteger nDay=[[m_pMyFilters getParkTimeBegin] getDay];//mpmfind
        NSInteger nStartTime = [[m_pMyFilters getParkTimeBegin] getDatabaseFormatted];
        NSInteger nEndTime = [[m_pMyFilters getParkTimeEnd] getDatabaseFormatted];
        NSString *pEmail=  [UIGlobals getEmail];
        
        params = [NSString stringWithFormat:@"device_id=%@&email=%@&start_time=%ld&end_time=%ld&longitude=%.8f&latitude=%.8f&day=%ld&distance=%.4f&newID=%@", uniqueIdentifier,pEmail,(long)nStartTime,(long)nEndTime,fLong,fLat,(long)nDay,fDistance,newID];
    }
    else
    {
        params = [NSString stringWithFormat:@"device_id=%@&startup=1&newID=%@", uniqueIdentifier,newID];
    }
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         // Remove progress window
                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                         NSInteger statusCode = [httpResponse statusCode];
                                         if(error == nil)
                                         {
                                             if (statusCode == 400 || statusCode==401)
                                             {
                                                 self.m_bSearchLimitExceeded=true;
                                             }
                                             else if (statusCode == 200)
                                             {
                                                 // Parse out the JSON data
                                                 //NSError *jsonError;
                                                 //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                                                 //error:&jsonError];
                                                 
                                                 //NSString* unlockCode = [json objectForKey:@"unlock_code"];
                                                 // JSON data parsed, continue handling response
                                                 self.m_bSearchLimitExceeded=false;
                                             }
                                             else
                                             {
                                                 self.m_bSearchLimitExceeded=false;
                                             }
                                         }
                                         else
                                         {
                                             
                                         }}];
    
    if(dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"datatask is nil");
    }
    
    return;
}

-(void) checkParametersSet
{
    NSString *pErrorMsg = nil;
    NSString *pTitleMsg = nil;
    if(self.m_bTimeConflict == TIME_CONFLICT)
    {
        pTitleMsg = @"Time Conflict";
        pErrorMsg = @"End time earlier than start time";
    }
    else if(self.m_bTimeConflict == SEVEN_DAY_LIMIT)
    {
        pTitleMsg = @"Time Conflict";
        pErrorMsg = @"Chicago ordinance 9-80-110 does not allow for parking more than 7 days.";
    }
    else
    {
        NSInteger nCounter=1;
        NSString *pErrorString= [[NSString alloc] init];
        if(!m_pMyFilters.isParkLocationValid)
        {
            pErrorString = [pErrorString stringByAppendingFormat:@"%ld.) %@\n",(long)nCounter++,@"Bad or No Location"];
        }
        
        if(![pErrorString isEqualToString:@""])
        {
            pTitleMsg = @"Parameter Error(s)";
            pErrorMsg = pErrorString;
        }
    }
    
    if( pErrorMsg && pTitleMsg)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: pTitleMsg message: pErrorMsg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
}

-(void) findparkingCLickedHelper
{
    if([[KeyboardStateListener sharedInstance] isVisible])
    {
        if([m_pMyFilters getParkType] == PERMIT)
            [self.m_zoneText resignFirstResponder];
        else
        {
            [self.m_textFieldLocation resignFirstResponder];
            return;
        }
    }
    
    if([m_pMyFilters getParkType]==FREE)
    {
        if(!self.m_bOkayToContinueToMap)
        {
            [self checkParametersSet];
            return;
        }
        else //if(!self.m_bSearchLimitExceeded)
            [self transitionToMapView];
    }
    else if([m_pMyFilters getParkType] == PERMIT)
    {
        if([self isReadyToQueryPark])
            [self transitionToMapView];
    }
    else if([m_pMyFilters getParkType] == METER)
    {
        if([self isReadyToQueryPark])
            [self transitionToMapView];
    }
    
    self.m_bFindCalledWithKeyboardUp=false;
}

-(void) transitionToMyAccount
{
    UIViewController *pView = [[self.tabBarController viewControllers] objectAtIndex:LOGIN_INDEX];
    LoginPage *pPage = (LoginPage*)pView;
    
    if([self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:pView])
    {
        [pPage setInAppPurchaseFromSearchPage];
        [self.tabBarController setSelectedIndex:LOGIN_INDEX];
    }
}

-(void) transitionToMapView
{
    if([self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex:MAP_INDEX]])
    {
        [self.tabBarController setSelectedIndex:MAP_INDEX];
    }
}

- (IBAction)findParkingClicked:(id)sender
{
    if([[KeyboardStateListener sharedInstance] isVisible])
        self.m_bFindCalledWithKeyboardUp=true;
    [self findparkingCLickedHelper];
}

- (IBAction)startTimeValueChanged:(id)sender
{
    [self updateTimeText:YES];
    [self presetButtonClicked:nil];
}

- (IBAction)endTimeValueChanged:(id)sender
{
    [self updateTimeText:NO];
    [self presetButtonClicked:nil];
}

- (IBAction)resetWardClicked:(id)sender
{
    NSString *pWard = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_ward"];
    if(pWard)
    {
        [self tryUpdateWard: true];
    }
}

- (IBAction)streetSweepClicked:(id)sender
{
    if([m_pMyFilters getParkType] != STREET_CLEANING)
    {
        [m_pMyFilters SetParkType:STREET_CLEANING];
        //[self updateGetParkingBtnState];
        [self updateParkTypeColors];
        [self onStreetSweepingHelper];
        [self updateRows];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


- (IBAction)onZoneUpdate:(id)sender
{
    if([self.m_zoneText.text isEqualToString:@""])
        [m_pMyFilters setParkingZone:-1];
    else
        [m_pMyFilters setParkingZone:[self.m_zoneText.text intValue]];
    
    [self updateGetParkingBtnState];
}

- (IBAction)useMyLocationValueChanged:(id)sender
{
    if(!self.m_switchUseMyLocation.isOn)
    {
        [self showLocationTextCell];
        [self handleTextFieldUpdate];
    }
    else
    {
        [self.m_textFieldLocation.delegate textFieldShouldReturn:self.m_textFieldLocation];
        [self hideLocationTextCell];
        [self->m_pMyFilters setUseMyLocation:TRUE];
        [self updateGetParkingBtnState];
    }
}

-(void) onUseMyLocationChanged : (BOOL) bON
{
    if(!bON)
    {
        [self showLocationTextCell];
        [self handleTextFieldUpdate];
    }
    else
    {
        [self hideLocationTextCell];
        [self.m_textFieldLocation.delegate textFieldShouldReturn:self.m_textFieldLocation];
        [self->m_pMyFilters setUseMyLocation:TRUE];
        [self updateGetParkingBtnState];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row)
    {
        case kStartTimeLabelRow:
        {
            if(self.m_bStartDatePickerShowing)
                [self hideStartDatePickerCell];
            else
                [self showStartDatePickerCell];
            break;
        }
        case kEndTimeLabelRow:
        {
            if(self.m_bEndDatePickerShowing)
                [self hideEndDatePickerCell];
            else
                [self showEndDatePickerCell];
            
            break;
        }
        default:
        {
            //LogBeater(@"row: %d",(int)indexPath.row);
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) showLocationTextCell
{
    self.m_bLocationFieldShowing=YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.m_textFieldLocation.hidden=NO;
    self.m_textFieldLocation.alpha=0.0f;
    
    [UIView animateWithDuration:.25 animations:
     ^{
         self.m_textFieldLocation.alpha=1.0f;
     }];
    
}

-(void) hideLocationTextCell
{
    self.m_bLocationFieldShowing=NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.m_textFieldLocation.alpha=0.0f;
    [UIView animateWithDuration:.25
                     animations:
     ^{
         self.m_textFieldLocation.alpha=0.0f;
     }
     
                     completion:^(BOOL finished)
     {
         self.m_textFieldLocation.hidden =YES;
     }
     ];
}

-(void) showStartDatePickerCell
{
    self.m_bStartDatePickerShowing=YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.m_datePickerStart.hidden=NO;
    self.m_datePickerStart.alpha=0.0f;
    [UIView animateWithDuration:.25 animations:^{
        self.m_datePickerStart.alpha=1.0f;}
     ];
}

-(void) showEndDatePickerCell
{
    self.m_bEndDatePickerShowing=YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.m_datePickerEndTime.hidden=NO;
    self.m_datePickerEndTime.alpha=0.0f;
    [UIView animateWithDuration:.25 animations:^{
        self.m_datePickerEndTime.alpha=1.0f;}
     ];
}

-(void) updateTimeText : (bool) isStartTime
{
    NSDate *pDate = isStartTime ? self.m_datePickerStart.date : self.m_datePickerEndTime.date;
    UILabel *lbLabel= isStartTime ? self.m_lbStartTime : self.m_lbEndTime;
    [m_pDateFormatter setDateFormat:@"EEEE, MMM dd  h:mm a"];
    
    NSString *pLabelText = [m_pDateFormatter stringFromDate: pDate];
    if(isStartTime)
    {
        [[m_pMyFilters getParkTimeBegin] setFromNSDate: pDate];
    }
    else
    {
        [[m_pMyFilters getParkTimeEnd] setFromNSDate: pDate];
    }
    m_bTimeConflict = [[m_pMyFilters getParkTimeBegin] conflictsWithBeginTime:[m_pMyFilters getParkTimeEnd]];
    lbLabel.text = pLabelText;
    self.m_lbEndTime.textColor = m_bTimeConflict ? [UIColor redColor] : [UIColor blackColor];
    [self updateGetParkingBtnState];
}

-(void) hideStartDatePickerCell
{
    self.m_bStartDatePickerShowing=NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.m_datePickerStart.alpha=0.0f;
    [UIView animateWithDuration:.25
                     animations:
     ^{
         self.m_datePickerStart.alpha=0.0f;
     }
     
                     completion:^(BOOL finished)
     {
         self.m_datePickerStart.hidden =YES;
     }
     ];
    
    [self updateTimeText:YES ];
}

-(void) hideEndDatePickerCell
{
    self.m_bEndDatePickerShowing = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.m_datePickerEndTime.alpha = 0.0f;
    [UIView animateWithDuration:.25
                     animations:
     ^{
         self.m_datePickerEndTime.alpha = 0.0f;
     }
     
                     completion:^(BOOL finished)
     {
         self.m_datePickerEndTime.hidden  = YES;
     }
     ];
    
    [self updateTimeText : NO];
}

- (bool) isReadyToQueryPark
{
    if( !m_pMyFilters)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Unable to proceed" message: @"Notify support parking filters in null" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" )
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        
        [self presentViewController: alertController animated:YES completion:nil];
        return false;
    }
    
    if([m_pMyFilters getParkType] == FREE)
    {
        self.m_bOkayToContinueToMap = [m_pMyFilters isParkLocationValid] && !self.m_bTimeConflict;
        return self.m_bOkayToContinueToMap;
    }
    else if([m_pMyFilters getParkType] == METER)
        return [m_pMyFilters isParkLocationValid];
    else if([m_pMyFilters getParkType] == PERMIT)
        return [m_pMyFilters getZone] != -1 ?  true :  false;
    else
        return false;
}

- (void) updateGetParkingBtnState
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        if([self isReadyToQueryPark])
        {
            [self.m_btnFindParking setBackgroundColor:[UIGlobals getMainBoldBackgroundColor]];
            [self.m_btnFindParking setTitleColor:[UIGlobals getMainBoldBackgroundColor] forState:UIControlStateNormal];
        }
        else
        {
            [self.m_btnFindParking setBackgroundColor:[UIColor lightGrayColor]];
            [self.m_btnFindParking setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
    else
    {
        m_btnFindParking.layer.cornerRadius = 5;
        m_btnFindParking.layer.borderWidth = 1;
        m_btnFindParking.layer.borderColor = [UIGlobals ourDarkGray].CGColor;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kQueryRow inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if(cell)
        {
            if([self isReadyToQueryPark])
            {
                [self.m_btnFindParking setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [self.m_btnFindParking setBackgroundColor:[UIGlobals getMainBackgroundColor]];
                //cell.backgroundColor=[UIColor lightGrayColor];
            }
            else
            {
                [self.m_btnFindParking setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [self.m_btnFindParking setBackgroundColor:[UIColor lightGrayColor]];
                //cell.backgroundColor=[UIColor lightGrayColor];
            }
        }
    }
}

-(BOOL) shouldPerformTransition
{
    if([m_pMyFilters getParkType] == FREE)
    {
        if(self.m_bOkayToContinueToMap && ![[KeyboardStateListener sharedInstance] isVisible])
        {
            if(self.m_bSearchLimitExceeded)
            {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Free Daily Searches Exceeded" message: @"Request a Parking Pass (100 Non-Expiring, Search Credits) for $0.99?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"NO", @"Dismiss" )
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"YES", @"Go to purchase more" )
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction* action)
                                            {
                                                [self transitionToMyAccount];
                                            }];
                [alertController addAction:cancelAction];
                [alertController addAction:yesAction];
                
                [self presentViewController: alertController animated:YES completion:nil];
                return NO;
            }
            else
                return YES;
        }
        else
            return NO;
    }
    else
        return YES;
}


-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Set the background color of our header/footer.
    header.contentView.backgroundColor = [UIColor blackColor];
    
    // You can also do this to set the background color of our header/footer,
    //    but the gradients/other effects will be retained.
    // view.tintColor = [UIColor blackColor];
}

- (IBAction)ClearClicked:(id)sender
{
    self.m_textFieldLocation.text=@"";
    [self->m_pMyFilters setParkLocationValid:NO];
    [self->m_pMyFilters setString:@""];
    [self updateGetParkingBtnState];
}

-(void)timeNowHelper
{
    self.m_datePickerStart.date = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [[m_pMyFilters getParkTimeBegin] setFromNSDate:self.m_datePickerStart.date];
    [self updateTimeText : YES];
    
    if(self.m_bStartDatePickerShowing)
    {
        [self hideStartDatePickerCell];
    }
}

-(void) presetButtonClicked : (UIButton*) btnClicked
{
    UIColor *pClickedColor = [UIColor blackColor];
    //UIColor *pUnclickedColor= [UIGlobals presetButtonGray];
    UIColor *pUnclickedColor = [UIColor lightGrayColor];
    
    if(self.m_btnNow == btnClicked){
        [self.m_btnNow setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btnNow setTitleColor:pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn2Hr == btnClicked){
        [self.m_btn2Hr setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn2Hr setTitleColor:pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn4Hr == btnClicked){
        [self.m_btn4Hr setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn4Hr setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn8Hr == btnClicked){
        [self.m_btn8Hr setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn8Hr setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn24Hr == btnClicked){
        [self.m_btn24Hr setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn24Hr setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn2hrStart == btnClicked){
        [self.m_btn2hrStart setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn2hrStart setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn4hrStart == btnClicked){
        [self.m_btn4hrStart setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn4hrStart setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn8HrStart == btnClicked){
        [self.m_btn8HrStart setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn8HrStart setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
    
    if(self.m_btn24hrStart == btnClicked){
        [self.m_btn24hrStart setTitleColor: pClickedColor forState:UIControlStateNormal];
    }
    else{
        [self.m_btn24hrStart setTitleColor: pUnclickedColor forState:UIControlStateNormal];
    }
}

- (IBAction)startPark2Hours:(id)sender
{
    [self parkForAmountOfTimeHelper: 2 andMinutes: 0 andIsStart: YES];
    [self presetButtonClicked:self.m_btn2hrStart];
}

- (IBAction)startPark4Hours:(id)sender
{
    [self parkForAmountOfTimeHelper: 4 andMinutes: 0 andIsStart: YES];
    [self presetButtonClicked:self.m_btn4hrStart];
}

- (IBAction)startPark8Hours:(id)sender
{
    [self parkForAmountOfTimeHelper: 8 andMinutes: 0 andIsStart: YES];
    [self presetButtonClicked:self.m_btn8HrStart];
}

- (IBAction)startPark24Hours:(id)sender
{
    [self parkForAmountOfTimeHelper:24 andMinutes:0 andIsStart: YES];
    [self presetButtonClicked:self.m_btn24hrStart];
}

- (IBAction)timeNowClicked:(id)sender
{
    [self timeNowHelper];
    [self presetButtonClicked: self.m_btnNow];
}

- (IBAction)parkFor2HoursClicked:(id)sender
{
    [self parkForAmountOfTimeHelper : 2 andMinutes: 0 andIsStart: NO];
    [self presetButtonClicked:self.m_btn2Hr];
}

- (IBAction)parkFor4HoursClicked:(id)sender
{
    [self parkForAmountOfTimeHelper: 4 andMinutes:0 andIsStart: NO];
    [self presetButtonClicked:self.m_btn4Hr];
}

- (IBAction)parkFor8HoursClicked:(id)sender
{
    [self parkForAmountOfTimeHelper: 8 andMinutes:0 andIsStart: NO];
    [self presetButtonClicked : self.m_btn8Hr];
}

- (IBAction)parkFor24HoursClicked:(id)sender
{
    [self parkForAmountOfTimeHelper: 24 andMinutes:0 andIsStart: NO];
    [self presetButtonClicked:self.m_btn24Hr];
}

-(void) parkForAmountOfTimeHelper:(NSInteger)nHoursToPark andMinutes:(NSInteger) nMinutesToPark andIsStart:(BOOL) isStart
{
    if(isStart)
    {
        NSDate *pDate = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
        [[m_pMyFilters getParkTimeBegin] setFromNSDate: pDate];
        [[m_pMyFilters getParkTimeBegin] addTime: nHoursToPark : nMinutesToPark];
        self.m_datePickerStart.date = [[m_pMyFilters getParkTimeBegin] getNSDate];
    }
    else
    {
        NSDate *pBegin = [[m_pMyFilters getParkTimeBegin] getNSDate];
        ParkTimeInfo *ptemp = [[ParkTimeInfo alloc] init];
        [ptemp setFromNSDate:pBegin];
        [ptemp addTime: nHoursToPark : nMinutesToPark];
        
        [[m_pMyFilters getParkTimeEnd] setFromNSDate: [ptemp getNSDate]];
        self.m_datePickerEndTime.date = [[m_pMyFilters getParkTimeEnd] getNSDate];
        
    }
    
    [self updateTimeText : isStart];
    if(self.m_bEndDatePickerShowing)
    {
        [self hideEndDatePickerCell];
    }
    
    if(self.m_bStartDatePickerShowing)
    {
        [self hideStartDatePickerCell];
    }
}

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if(viewController == [tabBarController.viewControllers objectAtIndex:MAP_INDEX])
    {
        if([self shouldPerformTransition])
        {
            MapViewController *mapView = (MapViewController*)viewController;
            [mapView setParkingFiltersPointer:self->m_pMyFilters];
            
            NSString *pCurrentSearchString=nil;
            if([m_pMyFilters getParkType] == FREE)
            {
                pCurrentSearchString= [self->m_pMyFilters getLastSearchStringFull];
            }
            else if([m_pMyFilters getParkType] == PERMIT)
            {
                pCurrentSearchString = [[NSString alloc] initWithFormat: @"%ld",(long)[m_pMyFilters getZone]];
            }
            else
            {
                pCurrentSearchString = [[NSString alloc] initWithFormat: @"%@_%.2f",[m_pMyFilters getDestString],[m_pMyFilters getMilesToQuery]];
            }
            
            if([m_pLastSearchLocation isEqualToString: pCurrentSearchString])
            {
                [UIGlobals getSearchFilters].m_bParkingQueryChanged = NO;
            }
            else
            {
                [UIGlobals getSearchFilters].m_bParkingQueryChanged = YES;
            }
            
            if(([UIGlobals getSearchFilters].m_bParkingQueryChanged || [m_pMyFilters useMyLocation]) && [m_pMyFilters getParkType] == FREE)
            {
            }
            
            [mapView setLastIndex: true];
            m_pLastSearchLocation = pCurrentSearchString;
            return YES;
        }
        else
        {
            if(self.m_bLoggedIn)
            {
                [self checkParametersSet];
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Search Page Errord" message: @"Please login before you search." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss" )
                                                                       style:UIAlertActionStyleCancel
                                                                     handler:nil];
                [alertController addAction:cancelAction];
                
                [self presentViewController: alertController animated:YES completion:nil];
            }
            
            return NO;
        }
    }
    else if(viewController == [tabBarController.viewControllers objectAtIndex:TABLE_VIEW_INDEX])
    {
        if([self shouldPerformTransition])
        {
            TableParkingView*tableViewController=(TableParkingView*)viewController;
            tableViewController.m_bReloadTable  = YES;
            
            return YES;
        }
        else
            return NO;
    }
    else if(viewController == [tabBarController.viewControllers objectAtIndex:LOGIN_INDEX])
    {
        return YES;
    }
    else if(viewController == [tabBarController.viewControllers objectAtIndex:SOCIAL_INDEX ]  )
    {
        return YES;
    }
    else
        return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIGlobals getColorForRowParkingInput:indexPath.row : self.m_bOkayToContinueToMap];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

//Deprecated
- (IBAction)parkThruTodayClickedDeprecated:(id)sender
{
    [self timeNowHelper];
    [[m_pMyFilters getParkTimeBegin] copy:[m_pMyFilters getParkTimeEnd]];
    
    NSInteger nHoursTillMidnight = 24 - [[m_pMyFilters getParkTimeBegin] getHour] - 1;
    NSInteger nMinutesLeftInHour = 60 - [[m_pMyFilters getParkTimeBegin] getMinute];
    
    if(nMinutesLeftInHour > 0)
    {
        nMinutesLeftInHour--;
    }
    
    [self parkForAmountOfTimeHelper:nHoursTillMidnight andMinutes: nMinutesLeftInHour andIsStart: NO];
}

-(void) hideStartandEndRows
{
    [self hideStartDatePickerCell];
    [self hideEndDatePickerCell];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
};

-(void) updateRows
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void) setLoggedIn : (BOOL) bLoggedOn
{
    self.m_bLoggedIn=bLoggedOn;
}

- (IBAction)freeParkingTypeClicked:(id)sender
{
    if([m_pMyFilters getParkType]==PERMIT)
        [self.m_zoneText resignFirstResponder];
    
    if([m_pMyFilters getParkType]  != FREE)
    {
        [m_pMyFilters SetParkType:FREE];
        [self updateGetParkingBtnState];
        [self updateParkTypeColors];
        [self onFreeClickedRowHelper];
        [self updateRows];
    }
}

- (IBAction)meterParkingTypeClicked:(id)sender
{
    if([m_pMyFilters getParkType]==PERMIT)
        [self.m_zoneText resignFirstResponder];
    
    if([m_pMyFilters getParkType] != METER)
    {
        [m_pMyFilters SetParkType:METER];
        [self updateGetParkingBtnState];
        [self onMeterClickedRowHelper];
        [self updateParkTypeColors];
        [self updateRows];
    }
}

- (IBAction)permitParkingTypeClicked:(id)sender
{
    if([m_pMyFilters getParkType] != PERMIT)
    {
        [m_pMyFilters SetParkType:PERMIT];
        [self updateGetParkingBtnState];
        [self updateParkTypeColors];
        [self onPermitClickedRowHelper];
        [self updateRows];
    }
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row)
    {
        case kTitleBar:
            return NO;
        case kTypeOfParking:
            return NO;
        case kStartHelperButtons:
        case kHelperButtons:
            return NO;
        case kQueryRow:
            return NO;
        case kUseMyLocationRow:
            return NO;
        case kDistancePlaceHolder:
        case kDistanceRow:
            return NO;
        case kLocationRow:
            return NO;
        case kZoneRow:
            return NO;
        case kResetWardRow:
            return NO;
        default:
            return YES;
            
    }
}


@end
