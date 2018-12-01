//
//  DetailsViewController.m
//  Practice3
//
//  Created by Mike on 1/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "DetailsViewController.h"
#import "UICommentsPage.h"
#import "UIGlobals.h"
#import "LoginPage.h"
#import "meterbeater.pch"
#import "ParkingPolygons.h"
#import "ParkTimeInfo.h"
#import "font_changer.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController
@synthesize SchoolZoneText,AreaZoneText,PermitNumText,ExceptionTextField;
@synthesize m_btnFeedback,defaultConfigObject,defaultSession;

typedef NS_ENUM(NSInteger, DV_ROW_INFO)
{
    ROW_TITLE,
    ROW_FEEDBACK,
    ROW_AREA,
    ROW_PERMIT,
    ROW_SCHOOL,
    ROW_EXCEPTION,
    ROW_NUM_ROWS//must be least
};

//feed back uialert
typedef NS_ENUM(NSInteger, SUGGESTION_ROWS)
{
    BAD_SPOT_INDEX = 0,
    PARKED_INDEX,
    LEAVE_SUGGESTIONS_INDEX,
    DISMISS_INDEX,
};

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        LogBeater(@"detail view");
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initColorScheme
{
    self.view.backgroundColor      = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor  = [UIColor clearColor];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{
    [self initColorScheme];
    self.tableView.delegate = self;
    
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
    
    if(![[m_pCurrentPark exceptionText] isEqualToString:@""])
    {
        NSString *pNotes=[[NSString alloc]initWithFormat:@"Parking Exception: %@",m_pCurrentPark.exceptionText];
        ExceptionTextField.text=pNotes;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
    [self initColorScheme];
    self->m_pDateFormatter = [[NSDateFormatter alloc] init];
    
    //Make TextFields non editable;
    ExceptionTextField.editable = NO;
    [self.tableView setAllowsSelection: YES];
}

-(NSDate*) convertEndTimeToNSDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:[m_pEndTime getDayOfMonth]];
    [components setMonth:[m_pEndTime getMonth]];
    [components setYear:[m_pEndTime getYear]];
    [components setHour:[m_pEndTime getHour]];
    [components setMinute:[m_pEndTime getMinute]];
    
    return [calendar dateFromComponents:components];
}


- (IBAction)BackClicked:(id)sender
{
    [self goBack];
}

-(UIAlertAction *) createAlertAction:(SUGGESTION_ROWS)nIndex andStyle:(UIAlertActionStyle)style andAlert:(NSString*)alert andInfo:(NSString*)info
{
    UIAlertAction *action   =         [UIAlertAction
                                       actionWithTitle: NSLocalizedString( alert, info)
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *action)
                                       {
                                           [self feedbackHelper: nIndex];
                                       }];
    
    return action;
}

- (IBAction)feedBackClicked:(id)sender
{
    UIAlertAction *badSpotAction     = [self createAlertAction: BAD_SPOT_INDEX andStyle: UIAlertActionStyleDefault andAlert: @"Bad Spot!" andInfo: @"Bad Spot button"];
    UIAlertAction *parkedAction      = [self createAlertAction: PARKED_INDEX   andStyle: UIAlertActionStyleDefault andAlert: @"Parked!!" andInfo: @"Parked button"];
    UIAlertAction *suggestionsAction = [self createAlertAction: LEAVE_SUGGESTIONS_INDEX andStyle: UIAlertActionStyleDefault andAlert: @"Leave Suggestions/Comments!" andInfo: @"Suggestions,Comments Button"];
    UIAlertAction *dismissAction     = [self createAlertAction: DISMISS_INDEX andStyle: UIAlertActionStyleCancel  andAlert: @"No Thanks" andInfo: @"No thanks button"];
    
    /* UIAlertAction *badSpotAction   = [UIAlertAction
     actionWithTitle: NSLocalizedString( @"Bad Spot!", @"Bad Spot button" )
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     [self feedbackHelper: BAD_SPOT_INDEX];
     }];  //DEVTEST delete all of htese
     
     UIAlertAction *parkedAction   = [UIAlertAction
     actionWithTitle: NSLocalizedString( @"Parked!", @"Parked button" )
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     [self feedbackHelper: PARKED_INDEX];
     }];
     
     UIAlertAction *suggestionsAction   = [UIAlertAction
     actionWithTitle: NSLocalizedString( @"Leave Suggestions/Comments!", @"Leave Suggestions/Comments button" )
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     [self feedbackHelper: LEAVE_SUGGESTIONS_INDEX];
     }];
     
     
     UIAlertAction *dismissAction   = [UIAlertAction
     actionWithTitle: NSLocalizedString( @"No Thanks", @"No thanks button" )
     style:UIAlertActionStyleCancel
     handler:^(UIAlertAction *action)
     {
     [self feedbackHelper: DISMISS_INDEX];
     }];*/
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Feedback" message: @"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction: badSpotAction];
    [alertController addAction: parkedAction];
    [alertController addAction: suggestionsAction];
    [alertController addAction: dismissAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)backClicked:(id)sender
{
    [self goBack];
}

- (void) setCurrentParking : (ParkingPolygons*) pParkSpotAnd :(ParkTimeInfo*) pEndTime
{
    m_pCurrentPark = pParkSpotAnd;
    m_pEndTime = pEndTime;
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    if(indexPath.row == ROW_EXCEPTION)
    {
        NSString *test = [m_pCurrentPark exceptionText];
        if( ![test isEqualToString : @""])
            height = self.ExceptionTextField.frame.size.height;
        else
            height = 0.0f;
    }
    
    return height;
}

-(void) pushToCommentsView
{
    UIStoryboard *storyboard  = [UIStoryboard storyboardWithName : @"MainStoryboard" bundle : nil];
    UICommentsPage *pComments = [storyboard instantiateViewControllerWithIdentifier : @"CommentsView"];
    
    [pComments setModalPresentationStyle : UIModalPresentationFullScreen];
    [self presentViewController: pComments animated:YES completion:nil];
}


#warning implemnt your own url backend
-(void) feedbackHelper : (NSInteger) nRowClicked __deprecated
{
    NSURL *url = nil;
    switch( nRowClicked)
    {
        case BAD_SPOT_INDEX:
        {
            url   = [NSURL URLWithString: @"NIL_BAD_SPOT_REPORTED_FILL THIS IN"];
            break;
        }
        case PARKED_INDEX:
        {
            url   = [NSURL URLWithString:@"NIL_BAD_SPOT_REPORTED_FILL THIS IN"];
            break;
        }
        case LEAVE_SUGGESTIONS_INDEX:
        {
            [self pushToCommentsView];
            break;
        }
        case DISMISS_INDEX:
        default:
        {
            break;
        }
    }
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *pEmail=  [UIGlobals getEmail];
    if(!pEmail)
    {
        pEmail = @"Not Set";
    }
    
    NSString *newID = [LoginPage uuid];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    NSString *params=[NSString stringWithFormat:@"device_id=%@&db_id=%@&start_time=%@&end_time=%@&email=%@&newID=%@", uniqueIdentifier,m_pCurrentPark.dataBaseID,m_pCurrentPark.startTime,m_pCurrentPark.stopTime,pEmail,newID];
    // Create url connection and fire request
    // Start NSURLSession
    if(!defaultConfigObject)
        defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    if(!defaultSession)
        defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    // POST parameters
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                      {
                                          // Remove progress window
                                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                          NSInteger statusCode = [httpResponse statusCode];
                                          if(error == nil)
                                          {
                                              if (statusCode == 200)
                                              {
                                              }
                                          }
                                          else
                                          {
                                              
                                          }}];
    
    if( dataTask)
        [dataTask resume];
    
}

-(void) goBack
{
    [self dismissViewControllerAnimated: YES completion : nil];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROW_NUM_ROWS;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == ROW_TITLE)
    {
        [self goBack];
    }
    
    return NO;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated: NO];
}


@end
