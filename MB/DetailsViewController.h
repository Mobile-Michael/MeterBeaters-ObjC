//
//  DetailsViewController.h
//  Practice3
//
//  Created by Mike on 1/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParkingPolygons;
@class ParkTimeInfo;

@interface DetailsViewController : UITableViewController
{
    ParkingPolygons *m_pCurrentPark;
    ParkTimeInfo *m_pEndTime;
    NSDateFormatter *m_pDateFormatter;
}

@property (weak, nonatomic) IBOutlet UILabel *SchoolZoneText;
@property (weak, nonatomic) IBOutlet UILabel *AreaZoneText;
@property (weak, nonatomic) IBOutlet UILabel *PermitNumText;
@property (weak, nonatomic) IBOutlet UITextView *ExceptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFeedback;
@property (strong, nonatomic) IBOutlet UIButton *m_btnBack;
@property (weak,nonatomic) NSURLSessionConfiguration *defaultConfigObject;
@property (weak,nonatomic) NSURLSession *defaultSession;


- (IBAction)feedBackClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

- (void) setCurrentParking : (ParkingPolygons*) pParkSpotAnd :(ParkTimeInfo*) pEndTime;

@end
