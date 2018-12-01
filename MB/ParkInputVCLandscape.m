 //
//  ParkInputVCLandscape.m
//  Practice3
//
//  Created by Mike on 12/3/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ParkInputVCLandscape.h"
#import "MapViewController.h"
#import "SharedVCFunctions.h"
#import "ViewControllerPortrait.h"

@interface ParkInputVCLandscape ()

@end


@implementation ParkInputVCLandscape
@synthesize m_btnUseMyLocation;
@synthesize sliderLabel,mileSlider;
@synthesize timePicker,timePickView;
@synthesize m_lbEndTimeLabel,m_lbStartTimeLabel;
@synthesize m_btnGetParking;
@synthesize m_uiDestinationTextField;
@synthesize m_uiToolbarHeader;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.navigationItem.hidesBackButton=TRUE;
  self.title=@"Parking Inputs";
  //constructor()
  {
    m_bInStartTime=FALSE;
    [m_pMyFilters setParkLocationValid:FALSE];
    self.m_uiDestinationTextField.delegate=self;
    m_bKeyboardOnScreen=FALSE;
    m_pDateFormatter = [[NSDateFormatter alloc]init];
    m_uiToolbarHeader.enabled=false;
    self.navigationItem.hidesBackButton=TRUE;
    [self updateGUIwithParkingFilters];
    UIImage *sliderIcon = [UIImage imageNamed:@"iOS6_walk.png"];
    [mileSlider setThumbImage:sliderIcon forState:UIControlStateNormal];
  }
  
  [self popTimePickerHelper:FALSE];
  
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
  {
    UIImage *sliderIcon = [UIImage imageNamed:@"iOS6_walk.png"];
    [mileSlider setThumbImage:sliderIcon forState:UIControlStateNormal];
    
    NSLog(@"Width: %.2f Height: %.2f",self.view.bounds.size.width,self.view.bounds.size.height);
  }
  else
  {
    NSLog(@"Width: %.2f Height: %.2f",self.view.bounds.size.width,self.view.bounds.size.height);
    
    [mileSlider setThumbImage:[UIImage imageNamed:@"iOS6_walk.png"] forState:UIControlStateNormal];
    
    timePicker.backgroundColor=[UIColor whiteColor];
    m_btnGetParking.layer.borderWidth=1.0f;
    m_btnGetParking.layer.borderColor=[[UIColor blackColor]
                                       CGColor];
    m_btnGetParking.layer.masksToBounds=YES;
  }

  [self updateGetParkingBtnState];
//DEVTEST do not commit this arning dont commit this
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  [SharedVCFunctions logBounds:screenRect andName:@"Screen"];
  [SharedVCFunctions logBounds:timePicker.bounds andName:@"TimePicker"];
  [SharedVCFunctions logBounds:timePickView.bounds andName:@"Landscape:TimePickView"];
	// Do any additional setup after loading the view.
}

-(void) updateGUIwithParkingFilters
{
  mileSlider.value=[m_pMyFilters getMilesToQuery];
  sliderLabel.text = [NSString stringWithFormat:@"Search Distance: %.1f miles", mileSlider.value];
  [self isReadyToQueryPark];
  
  if([[m_pMyFilters getParkTimeBegin] isTimeInited])
  {
    NSString *pAMpm=[[NSString alloc]init];
    pAMpm=[[m_pMyFilters getParkTimeBegin] getHour]>=12?@"PM":@"AM";
    int nDisplayHour=[[m_pMyFilters getParkTimeBegin] getHour]%12;
    
    NSString *pStartTime=[[NSString alloc] initWithFormat:@"%02d:%02d %@",nDisplayHour,[[m_pMyFilters getParkTimeBegin]getMinute],pAMpm];
    m_lbStartTimeLabel.text = pStartTime;
  }
  else
    m_lbStartTimeLabel.text = @"---";
  
  if([[m_pMyFilters getParkTimeEnd] isTimeInited])
  {
    NSString *pAMpm=[[NSString alloc]init];
    pAMpm=[[m_pMyFilters getParkTimeEnd] getHour]>=12?@"PM":@"AM";
    int nDisplayHour=[[m_pMyFilters getParkTimeEnd] getHour]%12;
    
    NSString *pEndTime=[[NSString alloc] initWithFormat:@"%02d:%02d %@",nDisplayHour,[[m_pMyFilters getParkTimeEnd]getMinute],pAMpm];
    m_lbEndTimeLabel.text = pEndTime;
  }
  else
    m_lbEndTimeLabel.text = @"---";
  
  if(![m_pMyFilters useMyLocation])
  {
    m_uiDestinationTextField.enabled=TRUE;
    [m_pMyFilters setUseMyLocation:FALSE];
    [m_btnUseMyLocation setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
    m_uiDestinationTextField.text=[m_pMyFilters getDestString];
    if([m_pMyFilters getBaseCoordinate].latitude!=0.0)
      [m_pMyFilters setParkLocationValid:TRUE];
    else
      [m_pMyFilters setParkLocationValid:FALSE];
  }
  else
  {
    m_uiDestinationTextField.text=@"my location";
    m_uiDestinationTextField.enabled=FALSE;
    [m_pMyFilters setUseMyLocation:TRUE];
    [m_pMyFilters setParkLocationValid:TRUE];
    [m_btnUseMyLocation setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  if(UIDeviceOrientationIsPortrait(deviceOrientation))
    [self performSegueWithIdentifier:@"pushToPortrait" sender:self];
}

- (IBAction)milesChanged:(id)sender
{
  [m_pMyFilters setMilesToQuery:mileSlider.value];
  sliderLabel.text= sliderLabel.text = [NSString stringWithFormat:@"Search Distance: %.1f miles",[m_pMyFilters getMilesToQuery]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  m_bKeyboardOnScreen=FALSE;
  m_btnGetParking.hidden=FALSE;
  m_bInStartTime=FALSE;
  return NO;
}

- (IBAction)useMyLocationClicked:(id)sender
{
  if(m_bKeyboardOnScreen)
    return;
  
  if(m_pMyFilters.useMyLocation)
  {
    m_uiDestinationTextField.enabled=TRUE;
    [m_pMyFilters setUseMyLocation:FALSE];
    [m_btnUseMyLocation setImage:[UIImage imageNamed:@"checkbox_unchecked.png"] forState:UIControlStateNormal];
  }
  else
  {
    m_uiDestinationTextField.text=@"my location";
    m_uiDestinationTextField.enabled=FALSE;
    [m_pMyFilters setUseMyLocation:TRUE];
    [m_pMyFilters setParkLocationValid:TRUE];
    [m_btnUseMyLocation setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
  }
  
  [self updateGetParkingBtnState];
}

- (void) updateGetParkingBtnState
{
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
  {
    if(self.isReadyToQueryPark)
    {
      [m_btnGetParking setBackgroundColor:[UIColor greenColor]];
      [m_btnGetParking setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    else
    {
      [m_btnGetParking setBackgroundColor:[UIColor redColor]];
      [m_btnGetParking setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
  }
  else
  {
    m_btnGetParking.layer.borderWidth=1.0f;
    m_btnGetParking.layer.borderColor=[[UIColor blackColor]
                                       CGColor];
    m_btnGetParking.layer.masksToBounds=YES;
    if(self.isReadyToQueryPark)
      [m_btnGetParking setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    else
      [m_btnGetParking setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
  }
}

- (IBAction)startTimeClicked:(id)sender
{
  if(m_bInStartTime==END_TIME_POP || m_bKeyboardOnScreen)
    return;
  
  if(!m_bInStartTime)
  {
    m_uiToolbarHeader.title=@"Start Time";
    m_bInStartTime=START_TIME_POP;
    [self popTimePickerHelper:TRUE];
  }
  else
  {
    [self hideTimePicker:nil];
    return;
  }
}

- (IBAction)endTimeClicked:(id)sender
{
  if(m_bInStartTime==START_TIME_POP || m_bKeyboardOnScreen)
    return;
  
  if(!m_bInStartTime)
  {
    m_uiToolbarHeader.title=@"End Time";
    m_bInStartTime=END_TIME_POP;
    [self popTimePickerHelper:TRUE];
  }
  else
  {
    [self hideTimePicker:nil];
    return;
  }
}

- (IBAction)hideTimePicker:(id)sender
{
  //close the datepicker and update the appropriate text field
  [self popTimePickerHelper:FALSE];
  
  [m_pDateFormatter setDateFormat:@"hh:mm a"];
  NSString *pDateText=[[NSString alloc] init];
  pDateText=[m_pDateFormatter stringFromDate:self.timePicker.date];
  
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
  NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate: self.timePicker.date];
  NSInteger nHour=[components hour];
  NSInteger nMinute=[components minute];
  
  if(m_bInStartTime==START_TIME_POP)
  {
    m_lbStartTimeLabel.text = pDateText;
    [[m_pMyFilters getParkTimeBegin] setHourAndTime:nHour :nMinute];
    
    if([[m_pMyFilters getParkTimeEnd] isTimeInited] && [[m_pMyFilters getParkTimeBegin] conflictsWithBeginTime: [m_pMyFilters getParkTimeEnd]])
    {
      [[m_pMyFilters getParkTimeEnd] resetTimeInfo];
      m_lbEndTimeLabel.text = @"---";
    }
  }
  else
  {
    [[m_pMyFilters getParkTimeEnd] setHourAndTime:nHour :nMinute];
    
    bool bTimeConflict=[[m_pMyFilters getParkTimeBegin] conflictsWithBeginTime:[m_pMyFilters getParkTimeEnd]];
    
    if(bTimeConflict)
    {
      UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Time Conflict"message:@"End Time Earlier Than Start Time" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
      [pAlert show];
      
      [[m_pMyFilters getParkTimeEnd] resetTimeInfo];
      pDateText=@"---";
    }
    
    m_lbEndTimeLabel.text = pDateText;
  }
  
  m_bInStartTime=FALSE;
  [self updateGetParkingBtnState];
}

-(void) popTimePickerHelper : (bool) bPop
{
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3f];
  
  CGFloat viewHeight=timePickView.frame.size.height;
  CGFloat viewWidth=timePickView.frame.size.width;
  CGFloat screenHeight = self.view.frame.size.height;
  m_btnGetParking.hidden=bPop;
//DEVTEST mpmfind can we figure out the size of the phone it is
  if(bPop)
  {
    viewHeight=170;
    timePickView.frame = CGRectMake(0,screenHeight-viewHeight,viewWidth,viewHeight);
  }
  else
    timePickView.frame = CGRectMake(0,screenHeight,viewWidth,viewHeight);
  
  [UIView commitAnimations];
}


- (IBAction)editingDidEnd:(UITextField *)sender
{
  [m_pMyFilters setString:m_uiDestinationTextField.text];
  NSString *pDestination=[m_uiDestinationTextField.text lowercaseString];
  if([pDestination isEqualToString:@"my location"])
  {
    m_uiDestinationTextField.text=@"my location";
    m_uiDestinationTextField.enabled=FALSE;
    [m_pMyFilters setUseMyLocation:TRUE];
    [m_btnUseMyLocation setImage:[UIImage imageNamed:@"checkbox_checked.png"] forState:UIControlStateNormal];
  }
  else
  {
    [m_pMyFilters setUseMyLocation:FALSE];
  }
  
  if([m_pMyFilters useMyLocation])
    [m_pMyFilters setParkLocationValid:TRUE];
  else
  {
    pDestination=m_uiDestinationTextField.text;
    if([pDestination isEqualToString:@""])
    {
      [m_pMyFilters setParkLocationValid:FALSE];
      return;
    }
    
    pDestination=[self addChicagoILText: pDestination];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:pDestination completionHandler:^(NSArray *placemarks, NSError *error)
     {
       if([placemarks count])
       {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         CLLocation *location = placemark.location;
         [m_pMyFilters setBaseCoordinate:location.coordinate];
         NSLog(@"location is %@",location);
         //[self.mapView setCenterCoordinate:coordinate animated:YES];
         [m_pMyFilters setParkLocationValid:TRUE];
       }
       else
       {
         NSLog(@"Geocoding error: %@", [error localizedDescription]);
         [m_pMyFilters setParkLocationValid:FALSE];
         UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Location Error"message:@"Could Not Find Location. Try Narrowing Search" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
         [pAlert show];
       }
       
       [self updateGetParkingBtnState];
     }];
  }
  
  NSLog(@"the destination is %@",pDestination);
  [self updateGetParkingBtnState];
}

- (IBAction)getParkingClicked:(id)sender
{
  if(!m_bOkayToContinueToMap)
  {
    int nCounter=1;
    NSString *pErrorString=[[NSString alloc]init];
    if(!m_pMyFilters.isParkLocationValid)
    {
      pErrorString=[pErrorString stringByAppendingFormat:@"%d.) %@\n",nCounter++,@"Bad or No Location"];
    }
    
    if(![[m_pMyFilters getParkTimeBegin] isTimeInited])
    {
      pErrorString=[pErrorString stringByAppendingFormat:@"%d.) %@\n",nCounter++,@"Begin Time Not Set"];
    }
    
    if(![[m_pMyFilters getParkTimeEnd] isTimeInited])
    {
      pErrorString=[pErrorString stringByAppendingFormat:@"%d.) %@\n",nCounter++,@"End  Time Not Set"];
    }
    
    UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Parameter Error(s)"message:pErrorString delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
    [pAlert show];
    
    return;
  }
}

- (IBAction)destinationTouchDown:(UITextField *)sender
{
  m_bKeyboardOnScreen=TRUE;
}

- (NSString*) addChicagoILText : (NSString *)stringToAppend
{
  stringToAppend=[stringToAppend stringByAppendingString:@" ,Chicago, IL"];
  return stringToAppend;
}


- (bool) isReadyToQueryPark
{
  if(!m_pMyFilters)
  {
    UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"NULL OBJECT" message:@"ParkFIlters Object is NULL" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
    [pAlert show];
    return false;
  }
  
  if([[m_pMyFilters getParkTimeBegin] isTimeInited] && [[m_pMyFilters getParkTimeEnd] isTimeInited]
     && m_pMyFilters.isParkLocationValid)
  {
    m_bOkayToContinueToMap=true;
    return true;
  }
  else
  {
    m_bOkayToContinueToMap=false;
    return false;
  }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
  if([identifier isEqualToString:@"MapViewSegueLandscape"])
  {
    if(m_bOkayToContinueToMap)
      return YES;
    else
      return NO;
  }
  else
  {
    NSLog(@"This should not get hit");
    return false;
  }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  id destinationController=[segue destinationViewController];
  if([destinationController isKindOfClass:[MapViewController class]])
  {
    MapViewController *targetController = [segue destinationViewController];
    [targetController setParkingFiltersPointer:m_pMyFilters];
  }
  else if([destinationController isKindOfClass:[ViewControllerPortrait class]])
  {
    ViewControllerPortrait *portraitView=destinationController;
    [portraitView setParkingFiltersPointer:m_pMyFilters];
  }
  else
  {
    NSLog(@"Should not get here");
  }
}

-(void) setParkingFiltersPointer : (ParkingSearchFilters *) pParkFilters
{
  m_pMyFilters=pParkFilters;
  [m_pMyFilters setString:[pParkFilters getDestString]];
}


@end
