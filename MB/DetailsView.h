//
//  DetailsView.h
//  Practice3
//
//  Created by Mike on 11/20/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParkingPolygons.h"

@interface DetailsView : UIViewController<UIAlertViewDelegate>
{
  ParkingPolygons *m_pCurrentPark;
}

@property (weak, nonatomic) IBOutlet UILabel *SchoolZoneText;
@property (weak, nonatomic) IBOutlet UILabel *AreaZoneText;
@property (weak, nonatomic) IBOutlet UILabel *PermitNumText;
@property (weak, nonatomic) IBOutlet UILabel *ParkingInsuranceText;
@property (weak, nonatomic) IBOutlet UILabel *SpecialNotesText;
@property (weak, nonatomic) IBOutlet UIButton *m_parkInsuranceBtn;

- (void) setCurrentParking : (ParkingPolygons*) pParkSpot;
- (IBAction)GetParkInsurance:(id)sender;
- (void) showConfirmAlert : (float) fInsuranceCost;
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
