//
//  DetailsView.m
//  Practice3
//
//  Created by Mike on 11/20/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "DetailsView.h"

@interface DetailsView ()

@end

@implementation DetailsView
@synthesize SchoolZoneText,AreaZoneText,PermitNumText,ParkingInsuranceText,SpecialNotesText,m_parkInsuranceBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  NSString *pParkInsurance=nil;
  float fParkInsurance=[m_pCurrentPark getParkingInsurance];
  if(fParkInsurance<=0.0f)
  {
    pParkInsurance= [[NSString alloc] initWithFormat:@"Parking Insurance: Not Available Here"];
    m_parkInsuranceBtn.hidden=YES;
  }
  else
  {
    m_parkInsuranceBtn.hidden=NO;
    pParkInsurance= [[NSString alloc] initWithFormat:@"Parking Insurance: $%.2f",fParkInsurance];
  }
  
  ParkingInsuranceText.text=pParkInsurance;
  NSString *pAreaTxt=[[NSString alloc]initWithFormat:@"Area: %@",m_pCurrentPark.areaName];
  AreaZoneText.text=pAreaTxt;
  
  NSString *pPermitNum=[[NSString alloc]initWithFormat:@"Permit Number: %@",m_pCurrentPark.permitNum];
  PermitNumText.text=pPermitNum;
  
  NSString *pSchoolZone=[[NSString alloc] init];
  bool bSchoolZone=[m_pCurrentPark.schoolZone boolValue];
  if(bSchoolZone)
    pSchoolZone=@"School Zone: Yes";
  else
      pSchoolZone=@"School Zone: No";
  SchoolZoneText.text=pSchoolZone;
  
  NSString *pNotes=[[NSString alloc]initWithFormat:@"Parking Exception: %@",m_pCurrentPark.exceptionText];
  SpecialNotesText.text=pNotes;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)GetParkInsurance:(id)sender
{
  [self showConfirmAlert:[m_pCurrentPark getParkingInsurance]];
}

- (void)showConfirmAlert :(float) fInsuranceCost
{
  NSString *pMessage =[[NSString alloc] initWithFormat:@"Purchase Park Insurance for $%.2f?",fInsuranceCost];
  
  UIAlertView *alert = [[UIAlertView alloc] init];
  [alert setTitle:@"Confirm"];
  [alert setMessage:pMessage];
  [alert setDelegate:self];
  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"No"];
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0)
  {
    // Yes, do something
  }
  else if (buttonIndex == 1)
  {
    // No
  }
}

- (void) setCurrentParking : (ParkingPolygons*) pParkSpot
{
  m_pCurrentPark=pParkSpot;
}
@end
