//
//  ParkInputVCLandscape.h
//  Practice3
//
//  Created by Mike on 12/3/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingSearchFilters.h"
#import "ParkTimeInfo.h"
#import <MapKit/MapKit.h>
enum
{
  START_TIME_POP=1,
  END_TIME_POP,
};

@interface ParkInputVCLandscape : UIViewController<UITextFieldDelegate,MKMapViewDelegate>
{
  BOOL m_bInStartTime;
  BOOL m_bKeyboardOnScreen;
  BOOL m_bOkayToContinueToMap;
  ParkingSearchFilters *m_pMyFilters;
  NSDateFormatter *m_pDateFormatter;
}

@property (weak, nonatomic) IBOutlet UIButton *m_btnUseMyLocation;
@property (weak, nonatomic) IBOutlet UISlider *mileSlider;
@property (weak, nonatomic) IBOutlet UILabel *sliderLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIView *timePickView;
@property (weak, nonatomic) IBOutlet UILabel *m_lbStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *m_lbEndTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *m_btnGetParking;
@property (weak, nonatomic) IBOutlet UITextField *m_uiDestinationTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_uiToolbarHeader;

//GUI actions
- (IBAction)milesChanged:(id)sender;
- (IBAction)useMyLocationClicked:(id)sender;
- (IBAction)startTimeClicked:(id)sender;
- (IBAction)endTimeClicked:(id)sender;
- (IBAction)hideTimePicker:(id)sender;
- (IBAction)editingDidEnd:(UITextField *)sender;
- (IBAction)getParkingClicked:(id)sender;
- (IBAction)destinationTouchDown:(UITextField *)sender;


//Logic helpers
- (void) updateGetParkingBtnState;
- (NSString*) addChicagoILText : (NSString *)stringToAppend;
- (void) popTimePickerHelper:(bool) bPop;
- (bool) isReadyToQueryPark;
- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;
- (void) setParkingFiltersPointer : (ParkingSearchFilters *) pParkFilters;
- (void) updateGUIwithParkingFilters;
@end
