//
//  ParkingInputController.h
//  Practice3
//
//  Created by Mike on 1/21/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <StoreKit/StoreKit.h>

@class ParkingSearchFilters;

@interface ParkingInputController : UITableViewController<UITextFieldDelegate,UITabBarControllerDelegate>
{
    NSMutableData *responseData;
    ParkingSearchFilters *m_pMyFilters;//grab from uiglobals
}
- (IBAction)startPark2Hours:(id)sender;
- (IBAction)startPark4Hours:(id)sender;
- (IBAction)startPark8Hours:(id)sender;
- (IBAction)startPark24Hours:(id)sender;

- (IBAction)timeNowClicked:(id)sender;
- (IBAction)parkFor24HoursClicked:(id)sender;
- (IBAction)parkFor2HoursClicked:(id)sender;
- (IBAction)parkFor4HoursClicked:(id)sender;
- (IBAction)parkFor8HoursClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btn2hrStart;
@property (weak, nonatomic) IBOutlet UIButton *m_btn4hrStart;
@property (weak, nonatomic) IBOutlet UIButton *m_btn8HrStart;
@property (weak, nonatomic) IBOutlet UIButton *m_btn24hrStart;

@property (weak, nonatomic) IBOutlet UIButton *m_btnPermitParking;
@property (nonatomic,strong) NSDictionary *permitLatitudes;
@property (nonatomic,strong) NSDictionary *permitLongitudes;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFreeParking;
@property (weak, nonatomic) IBOutlet UIButton *m_btnMeterParking;
@property (weak,nonatomic) NSURLSession *defaultSession;
@property (strong,nonatomic) CLGeocoder *geocoder;
@property BOOL m_bLoggedIn;

@property (weak, nonatomic) IBOutlet UIButton *m_btn2Hr;
@property (weak, nonatomic) IBOutlet UIButton *m_btn4Hr;
@property (weak, nonatomic) IBOutlet UIButton *m_btn8Hr;
@property (weak, nonatomic) IBOutlet UIButton *m_btn24Hr;
@property (weak, nonatomic) IBOutlet UITextField *m_zoneText;
@property (weak, nonatomic) IBOutlet UILabel *m_lbStartTime;
@property (weak, nonatomic) IBOutlet UILabel *m_lbEndTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *m_datePickerStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *m_datePickerEndTime;
@property (weak, nonatomic) IBOutlet UILabel *m_lbSearchDistance;
@property (weak, nonatomic) IBOutlet UISlider *m_distanceSlider;
@property (weak, nonatomic) IBOutlet UISwitch *m_switchUseMyLocation;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFindParking;
@property (weak, nonatomic) IBOutlet UITextField *m_textFieldLocation;
@property (strong,nonatomic) NSDateFormatter *m_pDateFormatter;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *m_zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_startLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_endLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_btnNow;
@property (weak, nonatomic) IBOutlet UILabel *m_UseMyLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_distanceLabel;

@property bool m_bStartDatePickerShowing;
@property bool m_bEndDatePickerShowing;
@property bool m_bLocationFieldShowing;
@property bool m_bSearchingForLocation;
@property NSString *m_pLastSearchLocation;
@property NSTimer *m_pTimer;
@property bool m_bOkayToContinueToMap;
@property bool m_bSearchLimitExceeded;
@property bool m_bFindCalledWithKeyboardUp;
@property NSInteger m_bTimeConflict;

//Street Cleaning related
@property (weak, nonatomic) IBOutlet UIButton   *m_btnSSHelp;
@property (weak, nonatomic) IBOutlet UIButton   *m_btnResetWard;
@property (weak, nonatomic) IBOutlet UILabel    *m_txtAlertSetFor;
@property (weak, nonatomic) IBOutlet UILabel    *m_txtAddressSS;
@property (weak, nonatomic) IBOutlet UITextView *m_viewDays;
@property (weak, nonatomic) IBOutlet UILabel    *m_txtStaticDays;

@property (weak, nonatomic) IBOutlet UITextView *m_infoEditSS;

- (IBAction)streetSweepClicked:(id)sender;
- (IBAction)onZoneUpdate:(id)sender;
- (IBAction)freeParkingTypeClicked:(id)sender;
- (IBAction)meterParkingTypeClicked:(id)sender;
- (IBAction)permitParkingTypeClicked:(id)sender;
- (IBAction)useMyLocationValueChanged:(id)sender;
- (IBAction)textFinishedEditing:(id)sender;
- (IBAction)distanceSliderChanged:(id)sender;
- (IBAction)findParkingClicked:(id)sender;
- (IBAction)startTimeValueChanged:(id)sender;
- (IBAction)endTimeValueChanged:(id)sender;
- (IBAction)resetWardClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *m_uiBackgroundView;

//helpers
-(void) updateTimeText : (bool) isStartTime;
-(void) parkForAmountOfTimeHelper:(NSInteger)nHoursToPark andMinutes:(NSInteger) nMinutesToPark andIsStart:(BOOL) isStart;
-(void) setLoggedIn : (BOOL) bLoggedOn;

@end
