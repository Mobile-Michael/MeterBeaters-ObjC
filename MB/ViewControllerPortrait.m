//
//  ViewController.m
//  Practice3
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ViewControllerPortrait.h"
#import "MapViewController.h"
#import "ParkInputVCLandscape.h"
#import "SharedVCFunctions.h"
//MPMFIND warning figure out how to add specialized error handling to log or email me

@interface ViewControllerPortrait ()

@end

@implementation ViewControllerPortrait

@synthesize m_btnUseMyLocation;
@synthesize sliderLabel,mileSlider;
@synthesize timePicker,timePickView;
@synthesize m_lbEndTimeLabel,m_lbStartTimeLabel;
@synthesize m_btnGetParking;
@synthesize m_uiDestinationTextField;
@synthesize m_uiToolbarHeader;



- (void)viewDidLoad
{
  [super viewDidLoad];
  
  static bool sbInited=false;
  if(!sbInited)
  {
    m_pMyFilters=[[ParkingSearchFilters alloc] init];
    [self isReadyToQueryPark];

    ParkTimeInfo *pBeginTime=[[ParkTimeInfo alloc] init];
    ParkTimeInfo *pEndTime=[[ParkTimeInfo alloc] init];
    [m_pMyFilters setParkTimeInfo:pBeginTime:pEndTime];
    [m_pMyFilters setParkLocationValid:FALSE];
    [m_pMyFilters reset: mileSlider.value];
    m_pDateFormatter = [[NSDateFormatter alloc]init];
    m_uiToolbarHeader.enabled=false;
    sbInited=true;
    m_bInSearch=FALSE;
  }
  
  self.navigationController.navigationBar.translucent = NO;
  self.navigationController.toolbar.translucent = NO;
  
  self.m_uiDestinationTextField.delegate=self;
  m_bKeyboardOnScreen=FALSE;
  m_bInStartTime=FALSE;
  m_pDateFormatter = [[NSDateFormatter alloc]init];
  self.navigationItem.hidesBackButton=TRUE;
  [self updateGUIwithParkingFilters];
  timePickView.backgroundColor=[UIColor whiteColor];
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
  
  [self popTimePickerHelper:FALSE];
  

  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
  {
     [self updateGetParkingBtnState];
//MPFIND #warning dont commit this
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [SharedVCFunctions logBounds:screenRect andName:@"Screen"];
    [SharedVCFunctions logBounds:timePicker.bounds andName:@"TimePicker"];
    [SharedVCFunctions logBounds:timePickView.bounds andName:@"TimePickView"];
  }
  else
  {
    [self performSegueWithIdentifier:@"goToLandscape" sender:self];
  }
  
  m_pTimer=[NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(searching) userInfo:nil repeats:YES];
  self.m_uiFindLocationIndicator.hidesWhenStopped=TRUE;
}

-(void) searching
{
  if(m_bInSearch)
  {
    [self.m_uiFindLocationIndicator startAnimating];
  }
  else
  {
    [self.m_uiFindLocationIndicator stopAnimating];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) popTimePickerHelper : (bool) bPop
{
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3f];
  
  m_btnGetParking.hidden=bPop;
  CGFloat viewHeight;
  CGFloat viewWidth=timePickView.frame.size.width;
  CGFloat screenHeight = self.view.frame.size.height;
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
  {
    viewHeight=timePickView.frame.size.height;
  }
  else
  {
    viewHeight=190;
  }
  
  if(bPop)
    timePickView.frame = CGRectMake(0,screenHeight-viewHeight,viewWidth,viewHeight);
  else
    timePickView.frame = CGRectMake(0,screenHeight,viewWidth,viewHeight);
  
  [UIView commitAnimations];
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

- (IBAction)milesChanged:(id)sender
{
  [m_pMyFilters setMilesToQuery:mileSlider.value];
  sliderLabel.text= sliderLabel.text = [NSString stringWithFormat:@"Search Distance: %.1f miles",[m_pMyFilters getMilesToQuery]];
}

- (IBAction)startTimeClicked:(id)sender
{
  if(m_bInStartTime==END_TIME_POP || m_bKeyboardOnScreen)
    return;
    
  if(!m_bInStartTime)
  {
    m_uiToolbarHeader.title=@"Start Time";
    [m_uiToolbarHeader setTintColor:[UIColor blackColor]];
    m_bInStartTime=START_TIME_POP;
    [self popTimePickerHelper:TRUE];
  }
  else
  {
    [self hideTimePicker:nil];//mpmfind name hideTimePicker to setTimeandHidePicker
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

- (bool) isReadyToQueryPark
{
  if(!m_pMyFilters)
  {
    UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"NULL OBJECT" message:@"ParkFIlters Object is NULL" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
    [pAlert show];
    return false;
  }
  
  if([[m_pMyFilters getParkTimeBegin] isTimeInited] && [[m_pMyFilters getParkTimeEnd] isTimeInited]
       && [m_pMyFilters isParkLocationValid])
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
  if((UIButton*)sender == m_btnGetParking)
  {
    if(m_bOkayToContinueToMap)
      return YES;
    else
      return NO;
  }
  else
  {
    NSLog(@"This should not get hit identifier is %@",identifier);
    return false;
  }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  id destinationController=[segue destinationViewController];
  if([destinationController isKindOfClass:[MapViewController class]])
  {
    MapViewController *targetController = destinationController;
    [targetController setParkingFiltersPointer:m_pMyFilters];
  }
  else if([destinationController isKindOfClass:[ParkInputVCLandscape class]])
  {
    ParkInputVCLandscape *targetController=destinationController;
    [targetController setParkingFiltersPointer:m_pMyFilters];
  }
  else
  {
    NSLog(@"Should not get here");
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  m_bKeyboardOnScreen=FALSE;
  m_btnGetParking.hidden=FALSE;
  m_bInStartTime=FALSE;
  return NO;
}

- (IBAction)editingDidEnd:(UITextField *)sender
{
  m_bInSearch=TRUE;
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
  
  if(!m_pMyFilters.useMyLocation)
  {
    pDestination=m_uiDestinationTextField.text;
    if([pDestination isEqualToString:@""])
    {
      [m_pMyFilters setParkLocationValid:FALSE];
      m_bInSearch=FALSE;
      return;
    }
    
    pDestination=[SharedVCFunctions addChicagoILText: pDestination];

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
      
      m_bInSearch=FALSE;
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

//Orientation Code

-(BOOL) shouldAutorotate
{
  [UIView setAnimationsEnabled:FALSE];
  return TRUE;
}
   
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [UIView setAnimationsEnabled:FALSE];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [UIView setAnimationsEnabled:TRUE];
  UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
  if(UIDeviceOrientationIsLandscape(deviceOrientation))
    [self performSegueWithIdentifier:@"goToLandscape" sender:self];
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

- (void) setParkingFiltersPointer: (ParkingSearchFilters *)searchFilters
{
  m_pMyFilters=searchFilters;
}

@end

